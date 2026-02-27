---
name: wydt
description: Ask AI's opinion on code - identify improvements, code smells, anti-patterns, and quality issues. Suggest fixes in structured format with Problem/Solution/Why triplets. Read-only, makes no changes.
---

# WYDT - What You Doing There?

## Overview

Quick code quality check. Get AI's eyes on your code to spot issues you might have missed. Shorter version of code review.

**Use when:**
- Before committing code
- After finishing a feature
- When something "feels off" but you can't pinpoint it
- Code review prep
- Learning a new codebase

## Core Principle

**Read only. Suggest only. Never modify code.**
This skill identifies issues and describes solutions. It does not implement fixes.

## The WYDT Process

### List of files to check:

$ARGUMENTS

### Phase 1: Read & Understand

1. **Read the code completely** - don't skim
2. **Identify the purpose** - what is this code trying to do?
3. **Note context** - where does it fit in the architecture?

### Phase 2: Analyze

Check for:

| Category | What to Look For |
|----------|------------------|
| **Code Smells** | Duplication, long methods, large classes, feature envy |
| **Anti-patterns** | God objects, singleton abuse, premature abstraction |
| **Quality** | Error handling, edge cases, null safety, type safety |
| **Performance** | Unnecessary loops, repeated operations, memory leaks |
| **Readability** | Naming, comments, complexity, organization |
| **Maintainability** | Coupling, testability, single responsibility |
| **Security** | Injection risks, exposed secrets, unsafe operations |
| **Idioms** | Language patterns missed, unconventional style |

### Phase 3: Structure Findings

**Format each finding as:**

```
N. **Problem**: [clear description of the issue]
   **Solution**: [concrete, actionable fix description]
   **Why**: [impact of the issue - bugs, maintenance, readability, etc.]
```

**Severity indicators (prefix with emoji):**
- 🔴 **Critical** - Bug risk, security issue, broken behavior
- 🟡 **Warning** - Code smell, maintenance burden, tech debt
- 🟢 **Suggestion** - Style, minor improvement, nice-to-have

### Phase 4: Prioritize

Order findings by:
1. Critical issues first
2. Quick wins second
3. Architectural concerns last (with discussion prompt)

## Example Output

```
🔴 Critical
1. **Problem**: No validation on `userId` parameter before database query
   **Solution**: Add input validation - check type, format, and sanitize before use
   **Why**: Unvalidated input can lead to injection attacks or unexpected crashes

🟡 Warning
2. **Problem**: Function `processData` does 4 different things (parse, validate, transform, save)
   **Solution**: Split into 4 focused functions, compose them in a pipeline
   **Why**: Multi-purpose functions are harder to test, debug, and modify without side effects

3. **Problem**: Duplicate logic for formatting dates in 3 files
   **Solution**: Extract to shared utility function and import where needed
   **Why**: Duplication means fixes must happen in multiple places - inevitable inconsistency

🟢 Suggestion
4. **Problem**: Variable `x` doesn't describe what it holds
   **Solution**: Rename to `activeUserCount` or similar descriptive name
   **Why**: Code is read 10x more than written; unclear names slow down every future reader
```

## Universal Red Flags

Always mention if found:

- No error handling for operations that can fail
- Silent failures (empty catch blocks, swallowed errors)
- Type assertions without validation
- Mutable shared state without clear ownership
- Logic mixed with presentation/data access
- Operations that should be batched but are done one-by-one
- Hardcoded values that should be configurable
- Missing input validation on boundaries
- Resource leaks (unclosed connections, unsubscribed listeners)
- Boolean parameters that control significant behavior changes

## When NOT to Use

- Code you don't understand at all (ask for explanation first)
- Generated/boilerplate code (unless customizing)
- Third-party library internals
- During active debugging (use debugging skill instead)

## Output Limits

- Maximum 10 findings per run
- If more exist, prioritize critical/warning over suggestions
- Mention at end if additional issues were found beyond the limit
