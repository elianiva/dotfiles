---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The active transcript is `$PI_SESSION_FILE`. Use it directly when present. To choose an earlier transcript for this working directory, call `pstack_sessions` with `action: "list"` and read only a returned path. Never glob Pi's global session directory. If no session file resolves, write a tight digest of the current session and pass that instead.

### 2. Spawn three reviewers in parallel

One parallel `subagent` call with three tasks, each using `agent: "poteto-agent"`, `role: "reflect judgment, divergent, synthesizer"`, and a prompt that forbids file writes. Reviewers may use MCPs available to their Pi child process for cited context lookups. The parent applies edits.

| Lens | `model` | Prompt template |
|---|---|---|
| Judgment | your configured reflect-judgment model (default `inherit-parent`) | `references/judgment-reviewer.md` |
| Tooling | your configured reflect-tooling model (default `inherit-parent`) | `references/tooling-reviewer.md` |
| Divergent | your configured reflect-judgment model (default `inherit-parent`) | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `subagent` result.

### 3. Synthesize

One `subagent` call using `agent: "poteto-agent"` and `role: "reflect judgment, divergent, synthesizer"`. The synthesizer may use MCPs available to its Pi child process to spot-check citations. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the Pi Agent Skills standard and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to the Pi Agent Skills standard and run its description-optimization loop.
- `new skill via Pi skill authoring: <kebab-name>`: hand creation to the Pi Agent Skills standard. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
