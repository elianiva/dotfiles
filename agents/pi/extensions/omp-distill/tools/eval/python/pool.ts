/**
 * Python eval sessions backed by pydantic/monty — a minimal, secure Python
 * interpreter written in Rust (see docs/research-monty-python-eval.md).
 *
 * One Monty pool + one checkout per pi session, mirroring the JS side
 * (vm.ts). Cells are `feedRun` calls: variables, functions and classes
 * persist across cells and tool calls (unlike the JS side, `let`/`const`
 * persistence caveats don't apply — everything persists).
 *
 * Sandbox policy:
 * - project cwd mounted read-write at /workspace (open()/pathlib work)
 * - no network, no subprocesses, no third-party packages (stdlib subset only)
 * - env vars only through the allowlisted `env()` / `os.getenv` bridge
 * - host tool calls via `tool_<name>(...)` external lookups
 *
 * A per-cell wall-clock timeout (or user abort) closes the session, killing
 * the worker — state is lost, matching the JS REPL's semantics. After a kill
 * the PyRepl is dead and the caller must start a new one (see pool.ts).
 */

import {
  CollectString,
  Monty,
  MontyCrashedError,
  MontyError,
  MontySession,
  MountDir,
  NOT_HANDLED,
} from "@pydantic/monty/node";
import type { FeedOptions, OsCallback } from "@pydantic/monty/node";
import { join } from "node:path";
import { BRIDGE_TOOL_NAMES, ENV_ALLOWLIST } from "../bridge";
import type { CellRunOptions, CellRunResult } from "../types";

const SCRIPT_NAME = "cell.py";
const WORKSPACE_PATH = "/workspace";

export interface PyEvalSession {
  cwd: string;
  pool: Monty;
  repl: PyRepl;
}

const sessions = new Map<string, PyEvalSession>();

/** Thrown inside runCell to signal the wall-clock budget was hit. */
class CellKilled extends Error {
  constructor(readonly reason: "timeout" | "abort") {
    super(`cell ${reason}`);
    this.name = "CellKilled";
  }
}

function raceWithTimeout<T>(promise: Promise<T>, timeoutMs: number, signal?: AbortSignal): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    let settled = false;
    const finish = (fn: () => void) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      signal?.removeEventListener("abort", onAbort);
      fn();
    };
    const timer = setTimeout(() => finish(() => reject(new CellKilled("timeout"))), timeoutMs);
    const onAbort = () => finish(() => reject(new CellKilled("abort")));
    if (signal) {
      if (signal.aborted) {
        onAbort();
        return;
      }
      signal.addEventListener("abort", onAbort, { once: true });
    }
    // Handlers are attached immediately so a late rejection (e.g. the worker
    // dying after we already settled on timeout) is consumed, never unhandled.
    promise.then(
      (v) => finish(() => resolve(v)),
      (e) => finish(() => reject(e)),
    );
  });
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

/**
 * Monty passes `**kwargs` to an external function as a trailing plain-object
 * argument. Split them off when there is a real positional argument before
 * them; a lone object argument is treated as the positional argument (or as
 * a kwargs-only call — for the tools below both spellings land on the same
 * args object shape).
 */
function splitArgs(args: unknown[]): { positional: unknown[]; kwargs: Record<string, unknown> } {
  if (args.length >= 2) {
    const last = args[args.length - 1];
    if (isRecord(last)) {
      return { positional: args.slice(0, -1), kwargs: last };
    }
  }
  return { positional: args, kwargs: {} };
}

function buildToolArgs(name: string, positional: unknown[], kwargs: Record<string, unknown>): unknown {
  const merge = (obj: Record<string, unknown>) => ({ ...obj, ...kwargs });
  // A single record argument is the full args object (covers both
  // `tool_read({'path': '/x'})` and `tool_read(path='/x')`).
  if (positional.length === 1 && isRecord(positional[0])) {
    return merge(positional[0]);
  }
  const second = positional.length > 1 && isRecord(positional[1]) ? positional[1] : {};
  switch (name) {
    case "read":
      return merge({ path: positional[0], ...second });
    case "write":
      return merge({ path: positional[0], content: positional[1] });
    case "edit":
      return merge({ path: positional[0], edits: positional[1] });
    case "grep":
    case "find":
      return merge({ pattern: positional[0], ...second });
    case "ls":
      return merge({ path: positional[0] });
    case "web_search":
      return merge({ query: positional[0], ...second });
    default:
      return positional;
  }
}

/** Allowlisted host env access, mirroring the JS guest's `env()` helper. */
function envView(name?: unknown): unknown {
  if (typeof name === "string") {
    return ENV_ALLOWLIST.includes(name) ? (process.env[name] ?? null) : null;
  }
  const view: Record<string, string> = {};
  for (const key of ENV_ALLOWLIST) {
    const value = process.env[key];
    if (value !== undefined) view[key] = value;
  }
  return view;
}

/** OS-call handler: serve the allowlisted env, deny everything else. */
const pythonOsCallback: OsCallback = (name, args) => {
  if (name === "os.getenv") {
    const [key, def] = args as [string, unknown];
    if (typeof key === "string" && ENV_ALLOWLIST.includes(key)) {
      return process.env[key] ?? def ?? null;
    }
    return NOT_HANDLED;
  }
  if (name === "os.environ") {
    return envView();
  }
  return NOT_HANDLED;
};

/**
 * Host-side REPL for python cells. One MontySession (one worker) per pi
 * session; one cell at a time.
 */
export class PyRepl {
  private dead = false;

  private constructor(
    private readonly pool: Monty,
    private readonly session: MontySession,
    private readonly mount: MountDir,
  ) {}

  static async start(pool: Monty, cwd: string): Promise<PyRepl> {
    const session = await pool.checkout({ scriptName: SCRIPT_NAME });
    const mount = new MountDir({ hostPath: cwd, virtualPath: WORKSPACE_PATH, mode: "read-write" });
    return new PyRepl(pool, session, mount);
  }

  isDead(): boolean {
    return this.dead;
  }

  /** Kill the worker (used for timeout, abort and reset). The pool survives. */
  kill(): void {
    if (this.dead) return;
    this.dead = true;
    void this.session.close().catch(() => {
      // Worker already gone — nothing to clean up.
    });
  }

  async runCell(code: string, opts: CellRunOptions): Promise<CellRunResult> {
    const started = Date.now();
    const result: CellRunResult = { ok: false, stdout: "", stderr: "", displays: [], durationMs: 0 };
    if (this.dead) {
      result.error = "python session is not running";
      return result;
    }
    const stdout = new CollectString();
    const stderr = new CollectString();
    const feedOptions: FeedOptions = {
      mount: this.mount,
      printCallback: (stream, text) => {
        const sink = stream === "stdout" ? stdout : stderr;
        sink.write(stream, text);
      },
      externalLookup: this.buildLookup(opts.bridge, result.displays),
      os: pythonOsCallback,
    };
    try {
      const value = await raceWithTimeout(this.session.feedRun(code, feedOptions), opts.timeoutMs, opts.signal);
      // The trailing expression value is the cell's structured result.
      if (value !== undefined && value !== null) result.displays.push(value);
      result.ok = true;
    } catch (e) {
      if (e instanceof CellKilled) {
        this.kill();
        const timedOut = e.reason === "timeout";
        result.timedOut = timedOut;
        result.error = timedOut
          ? `timed out after ${opts.timeoutMs}ms (python session state was reset)`
          : "eval aborted (python session state was reset)";
      } else if (e instanceof MontyCrashedError) {
        // Worker died (hard crash or watchdog kill) — session is gone.
        this.dead = true;
        result.error = `python worker crashed: ${e.message}`;
      } else if (e instanceof MontyError) {
        // Sandbox error (SyntaxError, RuntimeError, TypeError, ...). The
        // session survives — globals are intact for the next cell.
        result.error = e.display("type-msg");
      } else {
        result.error = e instanceof Error ? e.message : String(e);
      }
    }
    result.stdout = stdout.output;
    result.stderr = stderr.output;
    result.durationMs = Date.now() - started;
    return result;
  }

  /** External lookups: `tool_<name>(...)` bridge calls, `display`, `env`. */
  private buildLookup(bridge: CellRunOptions["bridge"], displays: unknown[]): Record<string, unknown> {
    const lookup: Record<string, unknown> = {};
    for (const name of BRIDGE_TOOL_NAMES) {
      lookup[`tool_${name}`] = (...args: unknown[]) => {
        const { positional, kwargs } = splitArgs(args);
        return bridge(name, this.hostify(buildToolArgs(name, positional, kwargs)));
      };
    }
    lookup["display"] = (value: unknown) => {
      displays.push(value);
      // Return None so the trailing-expression capture doesn't duplicate it.
      return null;
    };
    lookup["env"] = (...args: unknown[]) => envView(args[0]);
    return lookup;
  }

  /**
   * Translate virtual `/workspace/...` paths in bridge args to the real host
   * directory (the host tools only know host paths).
   */
  private hostify(args: unknown): unknown {
    if (!isRecord(args) || typeof args.path !== "string") return args;
    const p = args.path;
    if (p === WORKSPACE_PATH) return { ...args, path: this.mount.hostPath };
    if (p.startsWith(`${WORKSPACE_PATH}/`)) {
      return { ...args, path: join(this.mount.hostPath, p.slice(WORKSPACE_PATH.length + 1)) };
    }
    return args;
  }
}

/**
 * Get the live python session for a pi session, booting the Monty pool +
 * worker on first use. A session whose worker died (timeout kill, crash) is
 * automatically respawned from the SAME pool — the pool itself is kept, so
 * a wedged worker being reaped by the request timeout never blocks the next
 * cell.
 */
export async function getPySession(sessionId: string, cwd: string): Promise<PyEvalSession> {
  const existing = sessions.get(sessionId);
  if (existing && existing.cwd === cwd && !existing.repl.isDead()) {
    return existing;
  }
  if (existing && existing.cwd === cwd) {
    // Worker died (timeout kill or crash) — reuse the pool, fresh session.
    existing.repl = await PyRepl.start(existing.pool, cwd);
    return existing;
  }
  if (existing) {
    await disposePySession(sessionId);
  }
  const pool = await Monty.create({ minProcesses: 1, requestTimeout: 120 });
  const repl = await PyRepl.start(pool, cwd);
  const session: PyEvalSession = { cwd, pool, repl };
  sessions.set(sessionId, session);
  return session;
}

/** Wipe a session's python state: kill the worker and start a fresh one. */
export async function resetPySession(session: PyEvalSession): Promise<void> {
  session.repl.kill();
  session.repl = await PyRepl.start(session.pool, session.cwd);
}

/** Tear down a session's python pool entirely. */
export async function disposePySession(sessionId: string): Promise<void> {
  const session = sessions.get(sessionId);
  if (!session) return;
  sessions.delete(sessionId);
  session.repl.kill();
  try {
    await session.pool.close();
  } catch (e) {
    // Pool may already be gone during shutdown — ignore.
    void e;
  }
}

/** Tear down every python pool (used defensively; session events cover normal use). */
export async function disposeAllPySessions(): Promise<void> {
  const ids = [...sessions.keys()];
  await Promise.all(ids.map((id) => disposePySession(id)));
}
