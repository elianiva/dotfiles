/**
 * Session-scoped VM manager.
 *
 * One secure-exec VM + resident REPL per pi session, keyed by session id.
 * VMs boot lazily on first eval call (~500ms) and are disposed on
 * `session_shutdown`. The project cwd is mounted read-write at /workspace;
 * the project's node_modules is projected (read-only) so cells can
 * `await import("pkg")`.
 */

import { NodeRuntime } from "secure-exec";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { Repl } from "./repl";

export interface EvalSession {
  cwd: string;
  runtime: NodeRuntime;
  repl: Repl;
}

const sessions = new Map<string, EvalSession>();

function buildMounts(cwd: string): Array<{ guestPath: string; hostPath: string; readOnly: boolean }> {
  const mounts = [{ guestPath: "/workspace", hostPath: cwd, readOnly: false }];
  const nodeModules = join(cwd, "node_modules");
  if (existsSync(nodeModules)) {
    // Mount the whole node_modules tree at a path on the guest resolution
    // path (guest programs live under /tmp, so node walks /tmp/node_modules).
    // The pnpm symlink store (node_modules/.pnpm) is covered by this mount,
    // so packages resolve through their symlink chains without a nested mount.
    //
    // Do NOT add a nested mount for node_modules/.pnpm: the bundled sidecar
    // (agent-os < 0.2.8) unmounts previously configured mounts parent-first
    // on the second configure_vm call, so a child mount under
    // /tmp/node_modules makes every VM create fail with
    // "EBUSY: mount point has child mounts: /tmp/node_modules".
    mounts.push({ guestPath: "/tmp/node_modules", hostPath: nodeModules, readOnly: true });
  }
  return mounts;
}

/**
 * Get the live eval session for a pi session, booting the VM + REPL on first
 * use. A session whose REPL died (timeout kill) is automatically respawned —
 * the VM survives, only the guest process is restarted, so state is lost but
 * boot latency stays low.
 */
export async function getEvalSession(sessionId: string, cwd: string): Promise<EvalSession> {
  const existing = sessions.get(sessionId);
  if (existing && existing.cwd === cwd && !existing.repl.isDead()) {
    return existing;
  }
  if (existing) {
    await disposeEvalSession(sessionId);
  }
  const runtime = await NodeRuntime.create({
    cwd: "/workspace",
    mounts: buildMounts(cwd),
  });
  const repl = await Repl.start(runtime);
  const session: EvalSession = { cwd, runtime, repl };
  sessions.set(sessionId, session);
  return session;
}

/** Wipe a session's VM state: kill the REPL and start a fresh one. */
export async function resetEvalSession(session: EvalSession): Promise<void> {
  session.repl.kill();
  session.repl = await Repl.start(session.runtime);
}

/** Tear down a session's VM entirely. */
export async function disposeEvalSession(sessionId: string): Promise<void> {
  const session = sessions.get(sessionId);
  if (!session) return;
  sessions.delete(sessionId);
  session.repl.kill();
  try {
    await session.runtime.dispose();
  } catch (e) {
    // Sidecar may already be gone during shutdown — ignore.
    void e;
  }
}

/** Tear down every VM (used defensively; session events cover normal use). */
export async function disposeAllEvalSessions(): Promise<void> {
  const ids = [...sessions.keys()];
  await Promise.all(ids.map((id) => disposeEvalSession(id)));
}
