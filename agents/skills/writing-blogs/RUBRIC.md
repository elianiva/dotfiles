# Rubric: the arc

An ordered audit, large to small. Walk the beats in order and stop as soon as one fails: a missing spine makes every later beat unanswerable. Each beat gets `strong`, `thin`, or `missing`, and a quote.

The order is not invented. It is where three traditions agree:

- **Classical oration** (Cicero, Quintilian): exordium, narratio, divisio, confirmatio, refutatio, peroratio.
- **SCQA** (Barbara Minto): situation, complication, question, answer. The mechanism is that you earn the question before you answer it.
- **Toulmin**: claim, grounds, warrant, qualifier, rebuttal. The warrant, the step that says why the grounds prove the claim, is the one most checklists skip.

Above them sits **ABT** (Randy Olson): and, but, therefore. First drafts default to "and then, and then"; revision replaces the ands with a but and a therefore.

STAR's lesson applies too: its discipline is the **ratio**, not the letters. Situation and task take about a quarter, action and result the rest. Here, the hook takes about a tenth and the proof takes the bulk.

## 0. Spine (ABT)

Compress the whole post into one sentence: **And** (the shared context), **But** (what complicates it), **Therefore** (the claim and its consequence).

- **strong** — one sentence, and it is the post.
- **thin** — you can write it, but it describes a section, not the whole.
- **missing** — you get "and then, and then". The post is a list.

A post that is not arguing — a "what I like", a walkthrough — still has a spine; it is the change in the author. *And I used X. But it surprised me here. Therefore this is what I'd tell you.* Do not fail a post for not being an argument.

If the spine is thin or missing, stop and name it. Quote the sentence you found, and the sentence the post should have.

## 1. Hook

Situation, then Complication, then Question. Does the first screen give the reader ground they already stand on, disturb it, and leave them asking the question the post answers?

- **strong** — by the end of the first screen, the reader's question is the post's claim.
- **thin** — the situation is there but the complication is weak, or the question never forms.
- **missing** — the post opens on a topic.

**Ratio check.** The hook is roughly the first tenth. A draft that "takes a while to get going" is spending Situation on ground the reader already has.

## 2. Claim

The Answer, in one sentence. Quote it.

- **strong** — the post says it, and it is the spine's Therefore.
- **thin** — the post circles it, or holds two.
- **missing** — a topic, not an argument.

**Shape check.** Test every section against the claim. A section that would survive being cut is a different post.

## 3. Proof

Grounds and Warrant. The receipts, and whether they actually prove the claim.

- **strong** — numbers with sources, primary links, screenshots, code, lived specifics, **and** the sentence that says why the evidence supports the claim.
- **thin** — grounds without warrant: the evidence sits next to the claim instead of under it.
- **missing** — assertion.

Count the two separately. Most drafts have grounds; few have the warrant.

## 4. Steelman

Qualifier and Rebuttal. Does the post state its scope and answer the strongest objection?

- **strong** — the post argues against itself at least once, and says where it does not apply.
- **thin** — a token "of course, this is subjective".
- **missing** — one-sided.

In this corpus the steelman is a signature, not a formality: "it's a bit of a cop-out", "it's a rich-country answer", "In all fairness". Find the sentence where the author undercuts himself.

## 5. Close

Peroratio. Does the ending resolve the Question the hook raised?

- **strong** — the last section answers the question, or deliberately leaves it open and says so.
- **thin** — it restates.
- **missing** — it trails off, or stops.

An unresolved ending is allowed. A trailed-off one is not.

## 6. Voice

The throughline. The markers in `VOICE.md` are present and unforced.

- **strong** — it could only be this author.
- **thin** — present but diluted by tidy prose.
- **missing** — it reads like a model wrote it.

The proofread pass protects voice sentence by sentence; this beat asks whether the whole thing sounds like him.

## Verdict

- **ship** — the spine holds, the beats are strong, only slips remain.
- **fix** — the spine holds and one or two beats are thin. Name them in the fix order.
- **rework** — the spine is thin or missing, or the post is two posts.

## Worked example

`on-llms-and-the-graveyard-of-projects.mdx`, the working-tree draft, 2026-07-24, 5,569 words.

- **spine: strong, then broken.** *And LLMs made building cheap for me / But the cheapness only reaches people who can already pay / Therefore the graveyard is a privilege and the tool is a gate.* That is the post. Then it bolts on three more spines: "Social aspects of LLMs" (imposter syndrome, reviewing AI code), "The building block economy" (block-based architecture), and "Intelligence must be open" (control, never joined to price).
- **hook: thin.** Situation runs to 1,116 words (20%), and the Complication arrives there: "There's a paradox in this situation: LLMs make starting frictionless." The ratio wants that at about 10%.
- **claim: strong.** The Answer does not land until 1,844 words (33%): "The same tool that creates my graveyard is someone else's scarcity."
- **proof: strong.** Proof starts at 2,378 words and runs to the end, which is the right bulk. Grounds and warrant are both present: the salary math, the currency-rate link, the VAT link, the price table, and "the _reason_ I can afford to iterate through bad ideas while someone else can't even start is structural."
- **steelman: strong.** "it's a bit of a cop-out"; "it's a rich-country answer"; "In all fairness, these providers can't provide regional pricing either."
- **close: thin.** "Where does that leave us?" gets 84 words (98% onwards) of maybe-maybe-maybe. It leaves the question open without saying that it means to.
- **voice: strong.** The markers are everywhere and unforced.

**Verdict: fix.** Cut or split the two off-spine sections, join the control argument to the access one, pull the Complication into the first tenth, and fill the two placeholders. The slips (`a complain against`, `assistent`, `yeras`, `Althought`) put an obvious error inside the first 500 words.
