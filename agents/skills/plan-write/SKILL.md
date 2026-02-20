---
name: plan-write
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans: Implementation Blueprint

## 1. Overview & Setup
* **Purpose:** Create a zero-context, multi-step implementation plan for a developer.
* **Storage:** Always save to `docs/plans/YYYY-MM-DD-<feature-name>.md`.
* **Announce:** "I'm using the writing-plans skill to create the implementation plan."
* **Context:** Assume the developer is skilled but knows nothing of the codebase, domain, or good test design.

## 2. Core Principles
* **TDD Lifecycle:** Failing test -> Verify fail -> Minimal code -> Verify pass -> Commit.
* **Granularity:** Each task should take 2–5 minutes.
* **DRY/YAGNI:** Keep it lean; no unnecessary abstractions.
* **Reference:** Use `@` syntax for relevant skills/docs.

## 3. Required Plan Header
```markdown
# [Feature Name] Implementation Plan

> **IMPORTANT**: Use plan-execute skill to implement this plan task-by-task.

**Goal:** [One sentence goal]
**Architecture:** [2-3 sentences on approach]
**Tech Stack:** [Key libraries/tools]
---
