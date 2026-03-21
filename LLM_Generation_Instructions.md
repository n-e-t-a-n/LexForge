# Instructions for Generating Q&A Data for Bar Study Tool

This document serves as a prompt and structural guide for an LLM to generate high-quality, high-difficulty, scenario-based study data compatible with the **Bar Study Tool**.

## 1. Objective
Generate legal Q&A pairs based on provided lecture notes or textbooks. The output must be a valid JSON array of objects.

## 2. Question Format: The "Bar-Style" Scenario
Questions must be **scenario-based** and **high-difficulty**. Do not ask for simple definitions or obvious outcomes. Instead:
- **Complexity:** Create a short story (3-5 sentences) involving specific characters (e.g., Juan, Maria, SPO1 Cruz).
- **Nuance:** Include specific facts that trigger conflicting legal doctrines or exceptions (e.g., qualifying vs. aggravating circumstances, mistake of fact, or specific intent).
- **Test Understanding:** Design the facts to ensure the student must distinguish between similar crimes.
- **Open-Ended Inquiry:** Avoid simple "Yes/No" questions where possible. Use questions like "What is the specific crime committed?", "Determine the criminal liability of each party," or "If you were the judge, how would you rule?"
- **No Spoiling:** Do NOT include category names, title numbers, or subject headings in the output. The goal is to test the student's ability to identify the legal issue from the facts alone.

## 3. Answer Format: The ALA Format
Suggested answers MUST follow the **ALA** structure and be **legally certain**:
- **A**nswer: A direct, professional conclusion. If the answer is not binary, provide the specific designation of the crime or the exact legal status.
- **L**egal Basis: Cite the specific Article, Section, or Republic Act. **The LLM must be reasonably certain that this basis is correct and directly applicable to the core issue of the scenario.** Avoid broad or vague citations.
- **A**pplication: Explain *why* the legal basis applies to the facts. This is the most important part—break down the elements of the law and map them directly to the "clues" provided in the scenario. Prove why an alternative crime does *not* apply if the scenario is nuanced.

## 4. JSON Schema
The output must be a JSON array. Each object in the array must follow this schema:

```json
{
    "scenario": "The factual narrative...",
    "question": "The specific legal question...",
    "answer": "The direct conclusion...",
    "legal_basis": "The specific law/article citation...",
    "application": "The detailed reasoning connecting law to facts..."
}
```

### Example Entry
```json
{
    "scenario": "Juan, intending to kill his enemy Pedro, waited in a dark alley. When Pedro passed by, Juan fired a shot but missed Pedro and instead hit Maria, a passerby, killing her instantly.",
    "question": "Is Juan liable for the death of Maria?",
    "answer": "Yes, Juan is liable for Homicide.",
    "legal_basis": "Article 4 of the Revised Penal Code (Aberratio Ictus).",
    "application": "Under Article 4, criminal liability is incurred by any person committing a felony, although the wrongful act done be different from that which he intended. Even if Juan intended to kill Pedro, the resulting death of Maria makes him liable for Homicide through 'aberratio ictus' or mistake in the blow."
}
```

## 5. Quality Principles
1.  **Legal Certainty:** The cited law must be the definitive source for the answer. Do not guess or use outdated laws.
2.  **High Difficulty:** The tool is for Bar Exam preparation. Scenarios should challenge the student's ability to spot subtle legal issues ("issue spotting").
3.  **Accuracy:** Use only the provided materials as the source of truth.
4.  **No Hallucinations:** If the provided material does not cover a specific topic, do not invent law.

## 6. Prompt for the LLM
When asking a future LLM to generate data, use this prompt:
> "Please analyze the attached legal materials and generate [X] scenario-based, high-difficulty questions. Format the output as a JSON array according to the 'Instructions for Generating Q&A Data' document. Ensure answers follow the ALA (Answer, Legal Basis, Application) format and provide definitive legal certainty. Do not include any titles or category names."
