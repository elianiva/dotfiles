---
name: commit
description: Conventional commit message generator for jj and git repos. Analyzes diffs and produces scoped, well-formed commit messages. Use whenever the user says "commit", "make a commit", "write commit message", or similar.
disable-model-invocation: true
---

# Commit Skill

## Detection

```bash
# returns "jj" or "git"
which jj 2>/dev/null && jj root 2>/dev/null && echo "jj" || (git rev-parse --show-toplevel 2>/dev/null && echo "git")
```

Prefer `jj` if both work — it's the user's primary VCS.

---

## jj

### Check state

```bash
jj status           # changed files
jj diff             # full diff
jj diff <file>      # specific file
```

### Commit (set message on working copy)

```bash
jj describe -m "<type>(<scope>): <subject>"
```

With body:

```bash
jj describe -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<body>
EOF
)"
```

### Drop unrelated files before committing

```bash
jj restore --from @- <file1> <file2>
```

---

## Git

```bash
git status                       # check state
git diff HEAD                    # all changes
git add <file>                   # stage
git commit -m "<type>(<scope>): <subject>"
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<body>
EOF
)"
```

---

## Conventional Commit Format

```
<type>(<scope>): <subject>

<body>
```

**Types**: `feat` `fix` `refactor` `perf` `style` `test` `docs` `chore` `revert`

**Scope**: module changed, 1-2 words

**Subject**: imperative, no period, ≤72 chars

**Body** (optional): *what* and *why*, not *how* (diff shows how)

**Breaking**: add `!` after type — `feat!(api): change pagination response`

---

## Writing the Message

1. **Read `jj diff` / `git diff`** — understand every change
2. **Identify primary intent** — feat? fix? refactor?
3. **Pick type + scope** from that
4. **Skim each hunk** — if any doesn't serve the primary intent, flag it
5. **Write imperative subject** — "add X", "remove Y", "fix Z in W"
6. **Body only when *why* isn't obvious** — platform quirk, perf trade-off, migration step

---

## Examples

### ✅ Right

| Change | Message |
|--------|---------|
| New API route | `feat(flights): add GET /api/flights/:id` |
| Modal bug | `fix(responsive-modal): stop blurring select on mobile after scroll` |
| Rename function | `refactor(utils): rename fetchWrapper to useFetchWrapper` |
| Bump dep | `chore(deps): bump radix-ui/react-select to 2.2.6` |
| Remove dead code | `chore(auth): remove legacy session shim` |
| Perf | `perf(table): memoize row renderer` |
| Breaking change | `refactor!(db): drop legacy fuel_storage table` |

### ❌ Wrong

| Message | Why |
|---------|-----|
| `fix: fix bug` | Zero info |
| `fixed the modal` | Past tense, no scope |
| `fix(modal):fixed` | Missing space after colon |
| `feat(auth): add login page with form validation, error handling, remember-me, password reset, OAuth buttons` | Subject >72 chars |
| `fix(cache): change gcTime from 5min to 30min in queryClient config` | Describes *how* (diff shows it), not *why* |
| `✨ feat(ui): add spinner` | Emojis are noise in terminal |
| `fix #1234` | No description |
| `Bump lodash to 4.17.21 (#4567)` | GitHub auto-suffix noise |

---

## Rules

- **One logical change per commit** — drop unrelated files before committing
- **Don't commit stray `pnpm-lock.yaml`** — restore them out unless the change intentionally modifies deps
- **Don't use `git add .` / `jj restore` blindly** — check what's in working copy first
- **Don't write subjects longer than 72 chars** — body exists for details
- **Don't omit scope** — `fix: ...` is ambiguous, `fix(tooltip): ...` is not
- **Don't use `chore: wip`** — either write a meaningful subject or leave undescribed
