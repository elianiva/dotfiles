# pi-codemode

Executor plugins for codemode plus curated npm/jj commands and whitelisted bash.

## Tools
- `pi.*` builtins (filesystem, bash, webfetch)
- `fff.*` search tools
- `npm.run` run npm scripts
- `npm.install` install packages via lockfile-aware package manager selection
- `jj.status` / `jj.diff` / `jj.log` / `jj.new` / `jj.describe` / `jj.commit` for jj

## Bash whitelist
- Package managers: `npm`, `pnpm`, `bun`, `yarn`, `npx`, `node`
- File operations: `mkdir`, `touch`, `cp`, `mv`, `rm`, `ln`, `chmod`, `chown`
- Utilities: `pwd`, `echo`, `which`, `uname`, `date`, `sleep`
- Everything else is blocked with guidance to use the equivalent `tools.pi.*` tool

## Rules
- no full bash access — whitelisted package managers only
- use JS sandbox + named tools instead
- repo.install picks pnpm if pnpm-lock.yaml exists, bun if bun.lock/bun.lockb exists, else npm