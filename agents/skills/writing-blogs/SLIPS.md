# Slips

The mechanical families this corpus actually breaks, with real offenders. Work every family over the whole draft. A candidate is a slip only if it fails the **defend test** from `SKILL.md` and has exactly one fix.

Offenders below are quoted from the corpus, mostly from the working draft of `on-llms-and-the-graveyard-of-projects` (2026). They are here because the families recur, not because the old posts need editing.

## Agreement

Fix the verb. The verbs slip when a clause separates the subject from it.

- `There's many labs` → **There are many labs**
- `Not everyone have the means` → **Not everyone has the means**
- `the projects ... follows the same pattern` → **follow**
- `many things that uses libghostty` → **use**
- `they genuinely wants to help` → **want**
- `I'm always a guy who finds themself` → **myself** (first person singular throughout)

Watch `there's` + plural, `everyone` + base verb, and `people who lives` → **live**.

## Word choice

A wrong word or a near-miss misspelling. Fix the word; keep the sentence.

- `a complain against the pricing` → **a complaint**
- `a helpful assistent` → **assistant**
- `almost two yeras` → **years**
- `Althought I must say` → **Although**
- `spending yay much` → **spending that much**
- `that's your hardwork` → **hard work**
- `how to breakdown the problem` → **break down**

## Articles and countability

- `in the shape of bot` → **in the shape of a bot**
- `It's a whole another topic` → **a whole other topic**
- `there's less chances` → **fewer chances** (`less` for uncountable, `fewer` for countable)

## Prepositions and idiom

Read the line aloud; the wrong preposition is the one the mouth trips on.

- `I regret for not locking in` → **I regret not locking in**
- `as an exchange for my contributions` → **in exchange for**
- `different shape` → **a different shape**

## Broken and abandoned sentences

Half-written lines are the loudest signal a draft is not done. Fix or cut; never leave them.

- `The time from ideas to execution has now eliminated to near zero.` → **has now shrunk to near zero**
- `It was such a simple yet revolutionary, it can read a repo` → the noun is missing; supply it or rewrite
- `back when GPT 5 was just got released` → **had just been released** (doubled auxiliary)
- `You'd do stupid things like:` followed by a code block that is the example, not the stupid thing. Check that filler introductions still point at what follows.

## Placeholders

Every placeholder is a slip, and the claim it props up is unfinished work.

- `(tbd, unsure about this phrasing)`
- `(link to articles later)`
- `// TODO: finish the article`

Fill it or delete the sentence. Do not ship a post with a note to self in it.

## Capitalization

- `Since then i've been using them daily` → **I've**. The pronoun `I` is capitalized mid-sentence, in voice or not.

## Frontmatter and house style

The schema is enforced at build time by `content-collections.config.ts`; the rest is the renderer.

- `date` matches `YYYY-MM-DD` exactly.
- `tags` is a non-empty array of lowercase strings. Five or fewer: the OG card prints the first five.
- `title` under 85 characters; the OG card truncates there. Current max is 50.
- `description` under 155 characters; the OG card truncates with an ellipsis there. Current range is 42–114.
- `hidden: true` only when the post is meant to stay off the index.
- Body headings start at `##`. The frontmatter title renders as the page `<h1>`; a `#` in the body makes a second one. The 2026 posts follow this; older posts use `#`.
- MDX imports go at the top of the body, directly after the frontmatter.
- The slug is the filename: lowercase, hyphenated.

## Links and claims

Every factual claim about an external thing links to its primary source. This corpus's standard is high; match it.

- A placeholder or dead link is a slip.
- A number without a source is a slip. The salary math and the VAT rate in the LLM post each carry a link.
- A quoted tweet is an embed (`<TwitterEmbed>`), not a screenshot or a paraphrase.
- Coined or domain jargon gets a `<TermPopover>` with a definition, as in `what-i-like-about-jj`.
