---
name: to-wiki
description: Take knowledge from the current conversation and compound it into a living wiki in the personal Obsidian vault. The agent scouts existing pages via QMD first, proposes what to write, quizzes the user, then upserts.
disable-model-invocation: true
---

# To Wiki

Turn what you and the user have been discussing into a **living wiki** — a persistent, interlinked collection of markdown pages that grows richer with every conversation. You do the reading, writing, and cross-referencing; the user curates what's worth keeping.

Everything lives in the personal vault at `~/Development/personal/notes/`. The only variable is **which directory** within it:

| Directory | When |
|-----------|------|
| `Vault/<topic>/` | General knowledge — concepts, techniques, definitions, reference material. |
| `Projects/<project>/` | Knowledge about a specific project — architecture decisions, domain concepts, code patterns, findings. |

The skill picks the directory based on context. If the conversation is about code in a known project, it goes in `Projects/<project>/`. If it's general, it goes in `Vault/<topic>/`. When ambiguous, it asks.

## Conventions

### Frontmatter

```yaml
---
tags:
  - <kebab-case-tag>
  - <topic-area>
created_at: <YYYY-MM-DD>
aliases: []
id: <Title as in filename>
---
```

Rules:
- **id** matches the filename (minus `.md`). This is how `[[Wiki-Links]]` resolve.
- **created_at** is set once on creation. Add `updated_at` on subsequent edits.
- **Tags** are kebab-case. Reuse existing tags from the vault where possible.
- **`#public` is never added automatically.** Only when the user explicitly confirms a page is for the digital garden. Everything is private by default.

### Writing style

- Structured markdown with `###` subsections.
- Bullet lists for takeaways or enumerations.
- Code blocks with language tags for technical content.
- Every page links to at least one other page. A page with zero links is an orphan — orphan pages get lost. Link from new pages to existing ones, and offer to add backlinks from existing pages to new ones.

### Inside Projects/

Each project gets its own directory under `Projects/`:

```
notes/
└── Projects/
    └── <project-name>/
        ├── index.md          # Catalog — auto-updated on every upsert
        └── <Topic>.md        # Knowledge pages
```

The project name matches the directory name you use for the project (e.g. `remix-app`, `lutra`). The agent figures out which project you're working on from the current working directory, the files in context, or your conversation.

## Process

### 1. Scout the terrain

Search the existing wiki before writing anything. Do this autonomously — don't ask the user first.

Use QMD to search broadly first — it covers the whole vault:
```bash
qmd query "<topic>" -c vault
```

Then narrow down based on what you find:
- If the knowledge relates to a project, also search within `Projects/<project>/` using QMD or by reading the directory.
- If the topic has an obvious home (e.g. `Vault/Software Engineering/` for a dev concept), scan that directory too.
- Read any relevant pages in full with `qmd get` or the `read` tool.

Also assess the conversation context to determine **which directory** the content belongs in:
- Is the conversation about code in a specific project (visible from cwd, open files, or what you're discussing)? → `Projects/<project>/`
- Is it a general concept, technique, or reference? → `Vault/<topic>/`
- If `Vault/<topic>/` has an existing subdirectory that matches the content (e.g. `Islam/`, `Motorsports/`, `Software Engineering/`), use it. If none fits and there's no clear project, place it in `Vault/` directly.

**Completion criterion:** You know what exists (or that nothing does), have identified the right directory for the new content, and can articulate whether this is a creation, revision, or cross-reference addition.

### 2. Formulate

Based on scouting, determine the shape of the work:

- **Create** — a new concept not yet in the wiki. Choose a title distinct from existing pages.
- **Update** — an existing page needs new sections, revised content, or corrected facts. Changing `updated_at` is required.
- **Cross-reference** — existing pages should link to each other, or a new page needs links to existing ones. Every page needs at least one link.

Also determine:
- **Title** — concise, matches the concept name the user used.
- **Target** — `Projects/<project>/` or `Vault/<topic>/`. For project content, also determine the project name (from cwd, git remote, or files in context).
- **Key information** — distil what matters from the conversation. The wiki is compiled knowledge, not a transcript. Keep the essential, drop the ephemeral.

**Completion criterion:** You have a concrete proposal: what page(s) to touch, where they go, and what changes to make.

### 3. Present to the user

Show your proposal concisely:

```
→ **<Page Title>** in Projects/<project>/
  New page: <1-2 sentence summary>
  Links to: [[Existing Page]], [[Another Page]]
```

Or for general content:

```
→ **<Page Title>** in Vault/<topic>/
  New page: <1-2 sentence summary>
  Links to: [[Existing Page]], [[Another Page]]
```

Ask only what the user needs to decide:
- "The title I'm thinking is *X* — does that work?"
- "This is related to *Y* which already has a page — merge or keep separate?"
- "I found these existing cross-references — should I add backlinks?"

Keep it tight. One round of confirmation resolves most cases. If the proposal is straightforward (new page, no ambiguity), a single "This looks right — write it" from the user is enough.

**Completion criterion:** The user has confirmed the plan. If there was ambiguity, one exchange resolves it.

### 4. Upsert

Write or update the pages with the agreed conventions.

**New page** — use the `write` tool to create the file with full frontmatter, content, and wiki-links.

**Existing page** — read it first with `read`, then use `edit` to update specific sections, or rewrite the whole file if changes are extensive. Always update `updated_at` in frontmatter.

**Cross-references are a two-way street.** After writing, check if pages you linked to should link back. Offer this to the user rather than doing it silently.

**Update the index.** If `index.md` exists, add or update the entry for every page you touched. If it doesn't exist and this is the first real page, create it:

```markdown
# Wiki Index

## <Category>

- [[<Page Title>]] — <one-line summary>
```

Append to the appropriate category section. Create a new category if none fits.

**Never touch:**
- `Daily/` or `Inbox/` — they are private and ephemeral by design.
- `Articles/` or `People/` — they are for source summaries and profiles, not wiki knowledge. Only write there if the user explicitly asks.
- `Templates/`, `Images/`, `Music/` — each has a specialised purpose. The wiki lives in `Vault/` and `Projects/`.

**Never overwrite without confirmation.** If a page already exists and you're proposing significant changes, show the diff to the user before applying.

**Completion criterion:** All approved pages are written or updated, with proper frontmatter, cross-references, and an updated index. The wiki is internally consistent — no orphan pages created, no stale index entries left.

### 5. Confirm

Summarise what was done:

```
Done. Created [[<Page>]] in project wiki, linked from [[<Related Page>]]. Index updated.
```

If anything is noteworthy — new tags created, a subdirectory was created for a dense topic, an existing page was significantly revised — mention it briefly.

**Completion criterion:** The user knows what happened and can verify the result.

## What makes this different

- **Scout before write.** Never assume the wiki is empty. Never overwrite knowledge that already exists.
- **Compile, don't transcribe.** The wiki is distilled knowledge, not a chat log. If the user said something in passing that isn't worth keeping, leave it out.
- **Link or be orphaned.** Every page connects to at least one other. The wiki's value is in the cross-references.
- **Index as table of contents.** Without the index, the agent has to grep for everything. Maintain it on every upsert.
