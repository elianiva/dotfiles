---
name: root-cause-tracing
description: Use when errors occur deep in execution and you need to trace back to find the original trigger - systematically traces bugs backward through call stack, adding instrumentation when needed, to identify source of invalid data or incorrect behavior
---

# Root Cause Tracing: Trace to Source

## 1. Core Principle
* **Fix the Source, Not the Symptom:** Never just patch where the error appears. Trace backward through the call stack until you find the original trigger.

## 2. The Systematic Trace
1. **Observe Symptom:** Identify the exact failure point (e.g., git init failed).
2. **Immediate Cause:** Find the line of code executing the failing operation.
3. **Reverse Call Chain:** Use stack traces to see what called that function, and what called that (e.g., Test -> Project.create() -> Session.init() -> exec()).
4. **Data Origin:** Identify which variable was invalid (empty string, null, etc.) and find exactly where it was initialized or mutated.

## 3. Instrumentation (When Manual Tracing Fails)
If the origin is unclear, inject temporary debug logs **before** the failing operation:

```ts
// Example Instrumentation
console.error("DEBUG TRACE:", {
  input,
  cwd: process.cwd(),
  stack: new Error().stack
});
```

* **Pro Tip:** Use console.error in tests to bypass standard log suppression.

## 4. Defense-in-Depth
Once the source is fixed, apply multi-layer validation:
* **Layer 1:** Fix the original trigger (e.g., change variable to a getter that throws).
* **Layer 2:** Add input validation at the entry point of each intermediate function.
* **Layer 3:** Add environment guards (e.g., "Refuse to run in source directory").

## 5. Verification Strategy
* **Unit Test:** Write a deterministic test only for complex logic or data transformations.
* **Manual/Lint:** Skip tests for simple UI changes or CRUD; rely on type-checking and manual verification.

## 6. Tracing Flow
* **Found Cause?** -> Can you go one level up?
* **Yes:** Trace backward.
* **No (Reached Source):** Fix here **and** add validation at every layer below.
* **Result:** The bug becomes impossible to reproduce.

> **CRITICAL:** Fixing a symptom without finding the trigger is a "dead end" fix. Always hunt the original caller.
