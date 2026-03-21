# LexForge: The Bar Readiness Engine

**LexForge** is a lightweight, data-driven study environment designed for law students mastering complex legal scenarios. Unlike traditional Q&A tools, LexForge challenges users with high-difficulty "Bar-style" questions stripped of subject-matter spoilers, demanding pure issue-spotting and rigorous analysis.

## 🚀 Overview
Built on the **ALA Framework** (Answer, Legal Basis, Application), this tool bridges the gap between rote memorization and professional legal reasoning. It provides a clean, minimalist interface for testing your knowledge of the law through realistic, fact-rich scenarios.

## ✨ Key Features
- **Anti-Spoiler Design:** No category names or title numbers. Test your ability to spot the issue from the facts alone.
- **ALA Answer Structure:** 
    - **A**nswer: Direct conclusion.
    - **L**egal Basis: Specific statutory or case law citations.
    - **A**pplication: Detailed mapping of legal elements to factual "clues."
- **AI-Content Pipeline:** Includes a specialized instruction manual for generating high-fidelity study data using LLMs.
- **Privacy-First:** Serverless architecture. Your data stays on your machine; just upload a JSON file and start studying.

## 🛠️ Usage
1. Open `Bar_Study_Tool.html` in any modern web browser.
2. Select a compatible JSON study file (e.g., `title7_study_data.json`).
3. Tackle the scenarios, reveal the ALA answers, and master the law.

## 🤖 Generating New Data
LexForge is designed to be content-agnostic. Use the provided `LLM_Generation_Instructions.md` as a prompt for any LLM (like Gemini, GPT-4, or Claude) to generate new question sets from your own lecture notes or textbooks.

---
*Keep grinding. The Bar is waiting!*
