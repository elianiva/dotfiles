# Voice baseline

## Markers

Keep these. They are the author, not noise.

- **First person, doing things.** Narration of what the author tried, ran, bought, and felt. "Recently I've been using Jujutsu for a while, and I've grown to like it a lot."
- **Punctuation for the voice.** `hahah` (9), `lol` (15), `lmao` (4), `:)` (36), `:p` (20), `:D` (3), plus `boi`, `kinda`, `gonna`. Deliberate; leave them.
- **Long comma-spliced sentences, then a short punch.** A clause that carries a thought with its caveats, landed by "It's absurd." or "It felt like magic!". The mix is the rhythm.
- **Parenthetical asides.** "(still do honestly)". The aside is where the honest second thought lives.
- **Self-undercutting.** The author states the weakest part of his own argument: "it's a bit of a cop-out", "the graveyard is a privileged problem", "In all fairness, these providers can't provide regional pricing either". This is the best thing in the corpus. Never smooth it over.
- **Headings with a voice.** "No Need to Stash!", "A gate, not a boost", "It's _kinda_ weird", "Revisions are GOATed", "The L's hit different". A heading lands the point or the joke, not the topic.
- **Italics carry the load-bearing word** (_faster_, _why_, _the deepseek moment_); bold is rarer and marks a hard claim. 316 italics and 180 bold across the corpus.
- **Links everywhere.** Every factual claim about an external thing links to its primary source. Numbers become a table or a component. Jargon gets a `<TermPopover>`, quoted media gets a `<TwitterEmbed>`.
- **Mild profanity.** "shit ton", "damn".
- **Titles and descriptions are in-voice too.** The title is the post's own line ("I redesigned my website because why not", "What I like about Jujutsu"), not a label. The description is one hooking sentence in the same register.

## Punctuation target

Sentence-level dashes become commas and full stops. The corpus contains **zero em dashes**, and the author's own rewrite replaced them with commas and periods. `unslop` rule 13 owns the general rule; it matters here because a "helpful" proofread will want to add em dashes. Don't. In prose, the 2020–2022 posts wrote the same dash as `--`, which renders as two literal hyphens; don't revive that either. En dashes are correct and present in numeric ranges in the price table (`2.4–3.7%`), so leave those alone.

## What flattening looks like

The committed draft of `on-llms-and-the-graveyard-of-projects` was the flattened version. The author rewrote it. The rewrite is the direction of travel:

| Flattened (committed) | Voice (current) |
| --- | --- |
| `On LLMs and the graveyard of projects` | `Some thoughts on LLMs and stuff around it` |
| `## The Graveyard` then `The core paradox: LLMs make starting frictionless` | `## The graveyard` then `### The frictionless start` then `There's a paradox in this situation: LLMs make starting frictionless` |
| `Here's some numbers. A developer in Indonesia makes roughly Rp 7-10 million per month.` | Four paragraphs of hedging, a currency-rate link, and a table before the number lands |
| Em dashes throughout | Commas and full stops |

A fix that makes a sentence tidier but less like the author is wrong. When in doubt, leave the sentence.

## Values behind the shape

These are reasons, not rules; the checkable constraints live in `SLIPS.md`.

- **The post is a thinking tool.** The author says so: "Some of it I'd defend in an argument. Some of it I'm writing down to figure out what I think." A draft may end unresolved; that is a valid ending, not a missing conclusion.
- **Length is paid for by the argument.** A 5,500-word post is fine when every section pushes the claim.
- **The receipts go to primary sources.** Pricing pages, docs, official stats, the actual issue. Not a summary of a summary.
