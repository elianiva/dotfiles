---
name: pi-improvements
description: When encountering pi tool limitations, propose focused extensions that solve one problem each.
---

## Rules
- When edit fails due to whitespace/indentation, propose line-based editing
- When file changes between read and write are detected, propose stale-file guarding
- When bash output is noisy, propose structured output parsing
- When edits apply blindly, propose preview diffs
- Each extension must solve exactly one problem
- Prefer `~/.pi/extensions/name.ts` over folders

## Extension Patterns

**Edit by Line**: Replace exact-text matching with line numbers
```typescript
edit_line({ path: "foo.tsx", start: 45, end: 52, replacement: "..." })
```

**Edit Preview**: Intercept `edit` tool, show unified diff in TUI overlay

**Bash Summarize**: Parse known tools (vp check, npm test), return structured errors

**File Stale Guard**: Store mtime on `read`, warn on `write` if changed

## When to Propose
- After 2+ failed edit attempts due to formatting
- When user manually pipes bash output through grep/head
- When user discovers wrong edit only after running checks
- When formatter modifies files between read and write
