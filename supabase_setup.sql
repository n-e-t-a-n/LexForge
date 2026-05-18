-- LexForge Supabase setup
-- Run this once in your Supabase project's SQL editor.

create extension if not exists pgcrypto;

-- Main store. `id` is the short share code, `hash` is sha256 of the JSON
-- text (used for dedup), `data` is the parsed JSON array.
create table if not exists study_sets (
    id          text primary key,
    hash        text not null unique,
    name        text not null,
    data        jsonb not null,
    created_at  timestamptz not null default now()
);

-- Separate IP log so the public study_sets table never exposes uploader IPs.
-- Pruned naturally by the rate-limit query window (24h).
create table if not exists upload_log (
    ip          inet not null,
    created_at  timestamptz not null default now()
);
create index if not exists upload_log_ip_recent_idx
    on upload_log (ip, created_at desc);

-- Lock down direct table access; everything goes through SECURITY DEFINER functions.
alter table study_sets enable row level security;
alter table upload_log enable row level security;

-- Read by short ID. Returns 0 or 1 row.
create or replace function get_study_set(p_id text)
returns table (id text, name text, data jsonb)
language sql
security definer
set search_path = public
as $$
    select s.id, s.name, s.data
    from study_sets s
    where s.id = p_id;
$$;

-- Look up an existing set by content hash. Lets the client skip the name prompt
-- (and the rate-limit window) when a file is already in the library.
create or replace function lookup_by_hash(p_hash text)
returns table (id text, name text, data jsonb)
language sql
security definer
set search_path = public
as $$
    select s.id, s.name, s.data
    from study_sets s
    where s.hash = p_hash;
$$;

-- Upload + dedup + rate-limit in one call.
-- Returns the short id (existing or newly created).
create or replace function upload_study_set(
    p_hash text,
    p_name text,
    p_data jsonb
) returns text
language plpgsql
security definer
set search_path = public
as $$
declare
    v_existing_id text;
    v_ip          inet;
    v_count       int;
    v_new_id      text;
    v_attempts    int := 0;
begin
    -- Dedup: if this exact content was uploaded before, return its id and skip everything else.
    select id into v_existing_id from study_sets where hash = p_hash;
    if found then
        return v_existing_id;
    end if;

    -- Validate inputs
    if p_name is null or length(trim(p_name)) = 0 or length(p_name) > 100 then
        raise exception 'Name must be 1-100 characters';
    end if;
    if jsonb_typeof(p_data) <> 'array' then
        raise exception 'Data must be a JSON array';
    end if;
    if octet_length(p_data::text) > 1048576 then
        raise exception 'Data exceeds 1MB limit';
    end if;

    -- Pull client IP from PostgREST request headers (first hop of x-forwarded-for).
    begin
        v_ip := nullif(trim(split_part(
            current_setting('request.headers', true)::json->>'x-forwarded-for',
            ',', 1
        )), '')::inet;
    exception when others then
        v_ip := null;
    end;

    -- Rate limit: 10 uploads per IP per 24h. Skipped if we couldn't resolve an IP.
    if v_ip is not null then
        select count(*) into v_count
        from upload_log
        where ip = v_ip
          and created_at > now() - interval '24 hours';
        if v_count >= 10 then
            raise exception 'Rate limit reached: 10 uploads per day. Try again tomorrow.';
        end if;
    end if;

    -- Insert with retry on (extremely rare) short-id collision.
    loop
        v_attempts := v_attempts + 1;
        -- pgcrypto lives in the `extensions` schema on Supabase; qualify explicitly
        -- since SECURITY DEFINER pins search_path to `public`.
        v_new_id := encode(extensions.gen_random_bytes(4), 'hex');  -- 8 hex chars
        begin
            insert into study_sets (id, hash, name, data)
            values (v_new_id, p_hash, p_name, p_data);
            exit;
        exception
            when unique_violation then
                -- Could be a hash race (someone uploaded same content concurrently)
                -- or an id collision. Re-check hash first.
                select id into v_existing_id from study_sets where hash = p_hash;
                if found then return v_existing_id; end if;
                if v_attempts >= 5 then
                    raise exception 'Could not allocate unique id after 5 attempts';
                end if;
        end;
    end loop;

    if v_ip is not null then
        insert into upload_log (ip) values (v_ip);
    end if;

    return v_new_id;
end;
$$;

-- Allow anonymous (anon key) clients to call the two RPCs.
grant execute on function get_study_set(text)                       to anon;
grant execute on function lookup_by_hash(text)                      to anon;
grant execute on function upload_study_set(text, text, jsonb)       to anon;
