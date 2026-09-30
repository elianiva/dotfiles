---
name: writing-blogs
description: Proofread and judge a blog post against this author's own corpus. Use when the user asks to proofread or fix a draft in src/content/posts, or for a review, critique, or publish-readiness call on a blog post.
---

# Writing blogs

Two jobs, two branches:

- **Proofread** — hunt **slips**, fix them, leave the voice alone.
- **Judge** — walk every beat of the arc and return a **ship / fix / rework** call.

A **slip** is an unintended error with exactly one fix. **Voice** is an intentional habit the author would defend in an argument. The whole skill hangs on that distinction, because the failure mode is **flattening**: rewriting raw, self-undercutting, digressive prose into tidy generic text. It already happened once. The committed draft of `on-llms-and-the-graveyard-of-projects` was tight and tidy; the author rewrote it back into his own voice, longer and looser. Do not undo that.

## Baseline

- `VOICE.md` — what to preserve, and what flattening looks like. Read every run.
- `SLIPS.md` — the mechanical families this corpus actually breaks, with real offenders from the posts. Work it in the proofread pass.
- `RUBRIC.md` — the arc: seven beats to walk in order, the beat scale, and a worked example. Load it in the judge pass.

The corpus is `src/content/posts/*.mdx` (39 posts). The 2026 posts are the calibration set; the 2020–2022 archive is looser and is not the target. When the voice drifts, update `VOICE.md` and name the post that moved it.

Slop patterns live in the **unslop** skill. Scope it to this voice: unslop's tells that still apply are AI vocabulary, rule-of-three, chatbot phrasing, and generic conclusions. Parenthetical asides, emoticons, fragments, and first person are voice here, not tells.

## Procedure

1. **Read the draft.** The file the user named; else the newest `src/content/posts/*.mdx` by mtime, preferring one modified in `git status`. If several are modified, review the newest and name the rest. If the cwd has no `src/content/posts`, locate the blog repo first. Read the whole file, frontmatter included. Done when every line is read.

2. **Calibrate.** Read `VOICE.md`. Sample the two most recent published posts so you hear the live voice rather than a description of it. Done when you can name three markers of the current voice and one house rule.

3. **Hunt slips.** Open `SLIPS.md` and work every family over the whole draft. For each candidate run the **defend test**: would the author defend this in an argument? Yes → voice, drop it. No → record it with the exact fix. Done when every family has been worked and every candidate classified.

4. **Judge.** Open `RUBRIC.md` and walk the arc in order, largest beat first: spine, hook, claim, proof, steelman, close, voice. Stop at the first beat that fails and report that, because the later beats cannot be judged until it is fixed. Verdict each reached beat with a quoted passage or `none found`. Done when the spine sentence is written, every reached beat has a verdict, and there is a ship / fix / rework call.

5. **Report.** Use the format below. Lead with the spine and the verdict. Done when the report carries the spine, the slips, every reached beat's verdict, a ranked fix order, and a keep-list.

6. **Apply**, only when the user asks. Apply the listed slips verbatim and touch nothing else. Re-read the diff: if a sentence lost a hedge, an aside, or a joke, you flattened it, so put it back. Done when every listed slip is applied and no other line moved.

A review runs steps 1–5. A proofread-only run skips step 4. Step 6 happens only when the user asks for edits.

## Report format

```
## Review: <slug>

**Spine:** And <context> / But <complication> / Therefore <claim and consequence>
**Claim:** <the one sentence, quoted from the post, or "none found">
**Verdict:** ship | fix | rework

### Slips

| Where | Slip | Fix |
| ----- | ---- | --- |
| <quoted fragment> | <what is wrong> | <exact replacement> |

### Judgment

| Beat     | Verdict | Evidence |
| -------- | ------- | -------- |
| spine    |         |          |
| hook     |         |          |
| claim    |         |          |
| proof    |         |          |
| steelman |         |          |
| close    |         |          |
| voice    |         |          |

### Fix order

1. <the one change that matters most>
2. <next>
3. <next, at most>

### Keep

<two or three working passages, quoted, so the next pass does not flatten them>
```

The **Keep** section is not decoration. Name the passages where the voice is doing real work, so a later edit pass knows what it is protecting.
