# Delegation Strategy with subagent

Use `subagent` to parallelize independent work. The tool spawns a separate pi process per task — use it to split exploration and implementation.

## When to delegate

| Scenario | How |
|----------|-----|
| **Codebase recon** | Delegate a `scout` to map files/conventions while you work |
| **Parallel exploration** | Fire multiple `scout`s — each explores a different area |
| **Independent review** | Delegate `reviewer` to audit code while you continue coding |
| **Parallel implementation** | Split large tasks into parallel `worker` subtasks |

## Modes

- **Single `{ task, agent }`** — fire-and-forget. Result steers back when done. Fire multiple in quick succession for concurrency.
- **`{ tasks: [{agent, task}, ...] }`** — parallel, blocking. All tasks run concurrently, results returned when all complete. Use when you need all answers before proceeding.

## Guidelines

- Delegate exploration to `scout` (read-only, fast model) — it costs less and frees your context
- For truly independent sub-tasks, prefer parallel `tasks` mode over sequential calls
- Avoid delegating work that depends on results from another delegation — chain them manually instead
