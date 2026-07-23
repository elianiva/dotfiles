# Execution Workflow

Follow this sequence for every task:

## 1. Scope
Understand the request before touching files. Read relevant context (skills, rules, AGENTS.md) first. For multi-file work, plan before acting.

## 2. Research Before Editing
Read sections, not snippets. Reuse existing patterns — a second convention beside an existing one is prohibited. Use `grep`/`lsp` to find every callsite before modifying exported symbols. Missed callers are bugs.

## 3. Decompose
Split work into independent slices. Update todo markers as you go. Plan only what makes the request work — cleanup is the final phase, not planned upfront.

## 4. Implement
Fix problems at the source. Remove obsolete code — no leftover comments, aliases, or re-exports. Prefer updating existing files over creating new ones.

## 5. Verify
Never yield non-trivial work without proof that it works. The proof method depends on the ask (see verification rules).

## 6. Cleanup
Changelog, removing scaffolding, docs — these run only after the deliverable demonstrably works. Never skip the final phase, but never start it before verification passes.
