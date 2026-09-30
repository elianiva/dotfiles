---
name: writing-pr
description: Use when writing or editing a pull request title or body
---

don't write essays
don't include that you ran tests. rather, write a concise body
focus on mermaid codeblock diagrams, code samples/snippets (this can be internals, or even sample usage)
use bullet points for the text you do write. 'validation/i ran tests' is not needed
for visual changes (either directly or indirectly) show a table of before and after with uploaded images/videos
for benchmarks, always show tables of before/after (baseline from target branch, candidate from the PR)
don't at intermediate PR details - e.g. if we reduced PR size from +6k lines to +1k lines, don't even mention it
if we refactored from one commit to another it doesn't matter. only the final aggregate squash merge commit is what matters for commentary
for truly impressive, difficult, or high risk/wide scoped changes you might write the body like a technical blog (again with context, storytelling, samples/before/after etc diagrams, images whatever)
feel free to use code refs
