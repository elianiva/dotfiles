# pi-cute architecture

## Scope
- Override **only** pi's built-in `bash` tool.
- Keep normal pi tool surface.
- Goal: safer bash + RTK-style output filtering.

## Core pattern
- **Block**: inspect bash AST before execution, block unsafe/unwanted commands.
- **Rewrite**: rewrite commands at spawn time to match local toolchain patterns.
- **Execute**: delegate to pi's normal bash tool.
- **Filter**: apply RTK-style command filters after execution.
- **Preserve exit**: never change underlying bash exit semantics.

## Bash lifecycle
1. **Parse**: parse `bash.command` with `just-bash` AST.
2. **Block**: reject commands like `rm -rf`, direct lint binaries, dev/build scripts.
3. **Rewrite**:
   - `npm` → `bun`/`pnpm`
   - `npx` → `bunx`/`pnpm dlx`
   - `python`/`python3` → `uv run`
   - `grep` → `rg`
4. **Execute**: run through pi's standard bash tool.
5. **Filter**: split the rewritten command input into segments and apply matching filters in order.
6. **Return**: hand filtered text back to pi.

## Module layout
- `index.ts`
  - registers guarded bash override only
- `bash/guarded-bash-tool.ts`
  - bash tool override
  - tool-call blocking hook
  - rewrite + post-exec filtering integration
- `bash/command-ast.ts`
  - AST parse/serialize helpers
  - AST walkers
- `bash/blockers/`
  - `define-blocker.ts` blocker API
  - `types.ts` blocker contracts
  - one file per block rule
  - `index.ts` built-in blocker registry + sequential AST dispatch
- `bash/rewrite-pipeline.ts`
  - fail-safe rewrite application
- `bash/rewriters/`
  - `define-rewriter.ts` rewriter API
  - `types.ts` rewriter contracts
  - one file per rewrite rule
  - `index.ts` built-in rewriter registry + sequential AST dispatch
- `bash/package-manager.ts`
  - lockfile-based manager detection
- `bash/filter-engine.ts`
  - RTK-style 8-stage filter pipeline
  - stages: strip ANSI → replace → match output → line filtering → line truncation → head/tail → max lines → on-empty
- `bash/filter-pipeline.ts`
  - fail-safe filter application
  - composable multi-segment filtering for `|`, `&&`, `||`, `;`
- `bash/filters/`
  - `define-filter.ts` filter API
  - `types.ts` filter contracts
  - `shared.ts` command-segment splitter
  - one file per RTK filter port
  - `index.ts` built-in filter registry + first-match lookup

## Block architecture
Each blocker file declares:
- `name`
- `description`
- `checkCommand(command, context)`

Lookup model:
- parse once into AST
- visit each simple command in order
- run blockers sequentially
- first blocker reason wins

This makes blocking modular and composable across pipelines/chains.

## Rewrite architecture
Each rewriter file declares:
- `name`
- `description`
- `rewriteCommand(command, context)`

Lookup model:
- parse once into AST
- visit each simple command in order
- run all rewriters sequentially
- serialize only if any rule changed the AST

This makes rewrites granular and composable across pipelines/chains.

## Filter architecture
RTK built-in filters are ported as plain TypeScript modules.

Each filter file declares:
- `name`
- `description`
- `matchCommand: RegExp`
- `filters` pipeline config

Lookup model:
- rewritten command input is split into top-level segments
- each segment gets **first matching filter**
- matched filters are applied sequentially to the final tool output
- if no filter matches, output passes through unchanged

This makes filters composable across pipelines/chains.

Example:
- `cmd1 | cmd2 | cmd3`
- rewrite(cmd1) → rewrite(cmd2) → rewrite(cmd3)
- filter(cmd1) → filter(cmd2) → filter(cmd3)

## Built-in filter coverage
Ported from `~/Repositories/rtk/src/filters/*.toml` into TS modules, including:
- ansible-playbook
- basedpyright
- biome
- brew-install
- composer-install
- df
- dotnet-build
- du
- fail2ban-client
- gcc
- gcloud
- hadolint
- helm
- iptables
- jj
- jq
- make
- markdownlint
- mix-compile
- mix-format
- mvn-build
- oxlint
- ping
- pio-run
- poetry-install
- pre-commit
- ps
- quarto-render
- rsync
- shellcheck
- shopify-theme
- skopeo
- sops
- ssh
- stat
- swift-build
- systemctl-status
- terraform-plan
- tofu-fmt
- tofu-init
- tofu-plan
- tofu-validate
- trunk-build
- ty
- uv-sync
- xcodebuild
- yamllint

## Reliability rules
- If AST parse fails, execution still proceeds unless blocking depended on parse.
- If rewriting fails, run original input.
- If filtering fails, return raw output.
- Filtering is presentation-only; it must not affect exit behavior.
- Keep architecture modular: one blocker/rewriter/filter per file, registry dispatch.
