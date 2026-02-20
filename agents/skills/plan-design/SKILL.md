---
name: plan-design
description: Use when creating or developing, before writing code or implementation plans - refines rough ideas into fully-formed designs through collaborative questioning, alternative exploration, and incremental validation. Don't use during clear 'mechanical' processes
---

# Idea to Design

## 1. Initial Setup (Mandatory)
* **Create Plan Immediately:** Before any dialogue, create `.claude/docs/plans/<topic>-design.md`.
* **Initial Content:** Problem statement, goals, and known requirements.
* **The Golden Rule:** Update this file **after every user response**. Do not wait until the end.

## 2. Discovery Phase
* **Context Check:** Review existing files, docs, and commits first.
* **Batch Questions:** Use the ask tool to group up to 4 related questions (purpose, constraints, success metrics).
* **Preference:** Use multiple-choice or multi-select options in the tool whenever possible.
* **Loop:** Question -> Answer -> Edit Plan -> Follow-up.

## 3. Design Exploration
* **Propose Alternatives:** Present 2–3 approaches with trade-offs.
* **Recommend:** Lead with a preferred option and explain the "Why."
* **Keep it Lean:** Apply **YAGNI** (You Ain't Gonna Need It) to prune scope.

## 4. Presentation & Validation
* **Chunking:** Present the design in 200–300 word sections (Architecture, Data Flow, etc.).
* **Incremental Approval:** Use `AskUserQuestion` after *each* section to confirm alignment.
* **Scope:** High-level conceptual flow only (e.g., "Use React Query for state").

## 5. Strict Boundaries (Design vs. Implementation)
| In Scope (Design) | Out of Scope (Implementation) |
| :--- | :--- |
| High-level architecture & tech stack | Specific file paths & directory structures |
| Component responsibilities | Numbered implementation phases/steps |
| Data flow logic | Complete code snippets or Git commands |
| Trade-offs & assumptions | "Files to create/modify" lists |

> **CAUTION:** If you start writing "Phase 1: Setup" or specific file paths, **STOP**. Transition to the plan-write skill instead.

## 6. Closing
* **Final Review:** Ensure the `.claude/docs/plans/` file is polished and complete.
* **Next Step:** Ask: "Ready to set up for implementation?"
    * **If Yes:** Transition to `plan-write`.
