---
name: deslop
description: Remove all AI-generated slop like useless comments, try/catch blocks, and casts
disable-model-invocation: true
---

Remove all AI-generated slop, this includes:

## Focus Areas

- Extra comments that a human wouldn't add or is inconsistent with the rest of the file, remove the what, keep the why
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
