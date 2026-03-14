# pi-cute

Run-only extension for pi. Built around one tool: `run(command, timeout?)`.

## What it does
- Registers single `run` tool backed by `just-bash`.
- Disables **all** other pi tools via `setActiveTools(["run"])`.
- Adds hard `tool_call` guard to block any non-`run` tool when mode is ON.
- Re-asserts run-only mode before each agent turn (defense-in-depth).

## Command architecture
- Command modules live in `commands/`.
- Shared helper `definePiCommand()` supports:
  - progressive help (`--help`, no-args usage)
  - per-command output filters (rtk-inspired)
  - command-specific execution logic
- Current command overrides:
  - `commands/read.ts` -> `cat` (binary-aware, guided errors)
  - `commands/ls.ts` -> `ls` (simple list + `-a`/`-l`)
  - `commands/stat.ts` -> `stat` (metadata)
  - `commands/find.ts` -> `find` (recursive discovery)
  - `commands/write.ts` -> `write` (overwrite/append from args or stdin)
  - `commands/patch.ts` -> `patch` (apply unified diff with git apply)
  - `head`, `tail`, `wc`, `sort`, `cut`, `sed`, `awk` use just-bash built-ins directly
  - `commands/grep.ts` -> `grep` (FFF-backed live grep, progressive usage/help)
  - `commands/see.ts` -> `see` (image metadata helper)
  - `commands/proxy.ts` -> `proxy` (host command execution + pruning profiles)
  - specialized summarizers for TypeScript stack (`tsc`, `eslint`, `vitest`, `playwright`, `next`, `prisma`, `pnpm/npm/yarn`)
  - specialized summarizer for `jj` (`st/status`, `log`, `diff`)

## Proxy/rewrite layer
- `run(command)` is preprocessed by an rtk-breadth rewrite registry.
- Broad commands are rewritten to `proxy ...` (git/jj/npm/pnpm/yarn/npx/tsc/eslint/vitest/playwright/next/prisma/ruff/mypy/pip/go/golangci-lint/docker/kubectl/aws/gh/etc).
- `rg ...` is rewritten to `grep ...`.
- Supports chain-aware rewriting over `&&`, `||`, `;`, `|`.

## FFF integration
- Grep uses FFF native library via `koffi`.
- Index warmup starts on `session_start` (background scan).
- Binary is expected to be vendored locally in `bin/` (gitignored) or `../bin/`.
- Query style follows FFF constraints examples:
  - `git:modified src/**/*.rs !src/**/mod.rs user controller`
  - `*.md release notes`
  - single-file scope: `src/main.rs panic`

## Controls
- `/pi-cute status|on|off|toggle`
- `Ctrl+Shift+B` → toggle run-only/rescue mode

## Output model (LLM-friendly)
- Footer metadata always appended: `[exit:<code> | <duration>]`
- On failures, stderr is attached (`[stderr] ...`)
- Large output truncates at 200 lines / 50KB
- Full output saved to `/tmp/cmd-output/cmd-<n>.txt` with exploration hints

## Design alignment
Implements single-tool CLI flow + two-layer separation:
- Layer 1: raw Unix semantics inside just-bash
- Layer 2: binary guard, truncation/overflow, stderr guidance, metadata footer
