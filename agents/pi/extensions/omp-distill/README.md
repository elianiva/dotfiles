# omp-distill

A pi extension that distills the best ideas from [oh-my-pi](https://github.com/can1357/oh-my-pi) into portable, reusable enhancements.

> **Credits:** These features are adapted from [oh-my-pi](https://github.com/can1357/oh-my-pi) by [can1357](https://github.com/can1357). Some are verbatim ports, others are modified to fit a standalone extension model. Huge thanks to can1357 for the original design.

---

## Features

### 1. Enhanced `read` Tool — Multi-Protocol Reader

(`read/index.ts`, `read/handlers/`, `fetch/`)

Replaces the built-in `read` with a router that dispatches to protocol handlers:

| Protocol | Description | Source |
|---|---|---|
| `https://` | Web pages (Readability extraction, UA rotation, LRU cache, 429 retry) | From oh-my-pi |
| `skill://<name>` | Read a skill's SKILL.md | From oh-my-pi |
| `pi://[path]` | Browse pi documentation (README, docs/, examples/) | From oh-my-pi |
| `issue://<N>` | GitHub issue via `gh` CLI (disk-cached) | From oh-my-pi |
| `pr://<N>` | GitHub PR via `gh` CLI (disk-cached) | From oh-my-pi |
| `conflict://[path]` | Git/jj conflict information | From oh-my-pi |
| `vault://[path]` | Obsidian vault files + QMD search | Modified from omp |
| `file://` | Explicit local file prefix | From oh-my-pi |
| URL selectors | `:raw`, `:N`, `:N-M`, `:N+K` | From oh-my-pi |

Directory paths delegate to an `ls` tool for listing.

### 2. Enhanced `web_search` Tool

(`tools/web-search.ts`, `tools/search.ts`)

Web search powered by Exa with two modes:
- **REST API** — requires `EXA_API_KEY` env var, uses Exa's answer/search endpoints
- **MCP** — free, no auth needed, uses Exa's MCP endpoint

Supports multi-query search (2-4 varied angles), domain filtering, recency filtering, and rich TUI rendering (progress bar, source list, metadata).

### 3. Enhanced Tool Descriptions

(`tools/write-tool.ts`, `tools/edit-tool.ts`, `tools/grep-tool.ts`, `tools/bash-tool.ts`, `tools/wrap-builtin.ts`)

Each built-in tool (`write`, `edit`, `grep`, `bash`) is overridden with:
- A **description** that explicitly tells the LLM to use the specialized tool instead of shell commands
- A **promptSnippet** and **promptGuidelines** that appear in the system prompt

### 4. Bash Interceptor

(`tools/interceptor.ts`, `tools/bash-tool.ts`)

Runtime enforcement: blocks shell commands that shadow dedicated pi tools:

| Blocked commands | Redirect to |
|---|---|
| `grep`, `rg`, `ag`, `ack` | `grep` tool |
| `cat`, `head`, `tail`, `less`, `more` | `read` tool |
| `find`, `fd`, `locate` | `find` tool |
| `sed -i`, `perl -i`, `awk -i inplace` | `edit` tool |
| `echo >`, `printf >`, `cat <<` redirections | `write` tool |

Each block returns a helpful message explaining which tool to use instead.

### 5. Prompt Enhancer

(`prompt-enhancer.ts`, `prompts/`)

Injects dynamic sections into the system prompt on `before_agent_start`:
1. **Specialized Tools** — auto-generated section mapping file operations to the correct tool, with a litmus test for `bash`. Only includes mappings for currently active tools.
2. **Static prompt files** — `delivery-contract.md`, `execution-workflow.md`, `verification-rules.md` from `prompts/`
3. **Delegation Strategy** — injected when the `subagent` tool is active

Avoids double-injection via anchor text detection.

### 6. Subagent Tool — Parallel Delegation

(`subagent/`, `subagent-child/`)

Spawns child pi agents in new herdr tabs for parallel task execution:

- **Single mode** (fire-and-forget) — result steers back when done
- **Parallel mode** (blocking) — runs N tasks concurrently, returns aggregated results
- **Agent definitions** — `worker`, `scout`, `reviewer` with tool/behavior configuration via markdown frontmatter
- **Status monitoring** — tracks agent state (starting/active/waiting/stalled) via activity file snapshots
- **TUI widget** — shows running delegates in the pi UI
- **Session forking** — can seed child sessions with parent conversation context
- **Child tools** — `subagent_done` and `caller_ping` for child-parent communication
- **Auto-exit** — agent shuts down automatically when task completes
- **Self-spawn prevention** — blocks recursive subagent spawning
- **Deny tools** — per-agent tool restrictions

### 7. GitHub Integration

(`fetch/github-repo.ts`, `fetch/gh-utils.ts`)

Automatic GitHub URL handling in the read tool:
- Parses GitHub URLs and clones repos to `~/Development/repos/`
- Fetches file trees, READMEs, and individual file contents
- Falls back to `gh` API when cloning fails or is too expensive
- Skips repos over 350MB (uses API instead)
- Handles SHA refs (API-only, no clone)
- Caches `gh` binary location

### 8. Conflict Resolution

(`read/handlers/conflict.ts`)

Inspect git and jj conflicts without shelling out manually:
- `conflict://` — lists all conflicted files
- `conflict://<path>` — shows conflict markers + staged versions (ours/theirs for git, `jj file show` for jj)
- Auto-detects VCS type

### 9. Obsidian Vault Integration

(`read/handlers/vault.ts`)

Read files from an Obsidian vault:
- `vault://path/to/file.md` — read a vault file
- `vault://path/to/dir/` — directory listing
- `vault://tree` — full recursive tree
- `vault://search?q=<query>` — search using QMD (optional)
- `vault://collections` — list QMD collections
- Supports `.qmd` files (YAML frontmatter stripping)

### 10. HTTP Fetch Pipeline

(`fetch/content.ts`, `fetch/cache.ts`, `fetch/http-client.ts`)

Shared HTTP infrastructure used by the read tool's web handler:
- **Readability extraction** — article content extraction via `@mozilla/readability`
- **Markdown conversion** — via `turndown`
- **User-agent rotation** — 3 UAs (Chrome, Firefox, Safari) to avoid bot blocking
- **LRU cache** — 50-entry in-memory cache keyed by URL
- **Rate-limit parsing** — extracts retry hints from response headers and body text
- **Timeout handling** — combined abort signals with 30s default timeout
- **Size limits** — 5MB max response body

---

## Configuration

| Env var | Default | Description |
|---|---|---|
| `EXA_API_KEY` | — | Exa API key for web search (falls back to free MCP endpoint) |
| `PI_VAULT_DIR` | `~/Development/personal/notes` | Path to Obsidian vault |
| `PI_SUBAGENT_SHELL_READY_DELAY_MS` | `500` | Delay before running command in new herdr tab |
| `PI_DENY_TOOLS` | — | Comma-separated tools to disable for subagent spawning |
