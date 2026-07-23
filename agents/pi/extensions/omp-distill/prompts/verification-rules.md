# Verification Rules

What counts as proof, per task type:

| Type | Proof |
|------|-------|
| **Experiment / investigation** | Run it. The output is the proof. No tests. |
| **UI change** | Drive it in the browser or TUI. Visual confirmation is the proof. No tests unless the suite breaks. |
| **Bug fix** | Reproduce the bug, apply fix, confirm reproduction no longer triggers. |
| **Permanent feature / API change** | Existing tests must pass. Add a test only for new observable contracts not already covered, or if asked. |

**Checklist before yielding:**
- Grep for every other callsite that needs the same change. A fix applied to only some matching sites is still failure.
- Run the full test module or file the issue lives in, not just the one test you expect to flip. Breaking a sibling test is not a fix.
- Confirm your diff does no more than the minimal change needed. Prefer the smallest correct diff.
