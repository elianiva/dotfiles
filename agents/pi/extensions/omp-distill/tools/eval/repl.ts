/**
 * Host-side REPL manager.
 *
 * Owns one guest process (the embedded REPL source running inside the
 * secure-exec VM) and speaks the NDJSON frame protocol with it. One cell at a
 * time; a per-cell wall-clock timeout kills the guest process (destructive —
 * state is lost, matching omp's JS worker semantics). After a kill the Repl
 * is dead and the caller must start a new one (see vm.ts).
 */

import type { NodeRuntime, NodeRuntimeProcess } from "secure-exec";
import { GUEST_REPL_SOURCE } from "./guest";

const FRAME_PREFIX = "\u0000omp1:";
const READY_TIMEOUT_MS = 15_000;

export interface CellRunOptions {
  /** Wall-clock budget for the cell, including bridge calls (ms). */
  timeoutMs: number;
  /**
   * Abort the cell when this signal fires (user cancel). Destructive: the
   * guest process is killed and state is lost.
   */
  signal?: AbortSignal;
  /**
   * Host-side handler for guest bridge calls (`tool.<name>(...)`, `env`).
   * Must return a JSON-serializable value or throw.
   */
  bridge: (name: string, args: unknown) => Promise<unknown>;
}

export interface CellRunResult {
  ok: boolean;
  error?: string;
  stdout: string;
  stderr: string;
  /** Values emitted via display() / captured from top-level return. */
  displays: unknown[];
  durationMs: number;
  timedOut?: boolean;
}

interface PendingCell {
  result: CellRunResult;
  timer: NodeJS.Timeout;
  bridge: (name: string, args: unknown) => Promise<unknown>;
  resolve: (r: CellRunResult) => void;
}

export class Repl {
  readonly proc: NodeRuntimeProcess;
  private dead = false;
  private seq = 0;
  private current: PendingCell | null = null;
  private stdoutBuf = "";
  private stderrBuf = "";
  private readyResolve: (() => void) | null = null;

  private constructor(private runtime: NodeRuntime, proc: NodeRuntimeProcess) {
    this.proc = proc;
  }

  static async start(runtime: NodeRuntime): Promise<Repl> {
    const booted = Promise.withResolvers<void>();
    const repl = new Repl(runtime, await runtime.spawn(GUEST_REPL_SOURCE, {
      onStdout: (chunk: Uint8Array) => repl.onChunk(chunk, "stdout"),
      onStderr: (chunk: Uint8Array) => repl.onChunk(chunk, "stderr"),
    }));
    repl.readyResolve = booted.resolve;
    const timer = setTimeout(() => {
      booted.reject(new Error("eval VM failed to boot (guest did not report ready)"));
      repl.kill();
    }, READY_TIMEOUT_MS);
    try {
      await booted.promise;
    } finally {
      clearTimeout(timer);
    }
    return repl;
  }

  isDead(): boolean {
    return this.dead;
  }

  /** Kill the guest process (used for timeout and reset). The VM stays alive. */
  kill(): void {
    if (this.dead) return;
    this.dead = true;
    try {
      this.proc.kill("SIGKILL");
    } catch (e) {
      // Process already gone — nothing to clean up.
      void e;
    }
  }

  /**
   * Run one cell to completion. Resolves with `ok: false` for cell errors,
   * timeouts, and dead-VM conditions — it never throws for those.
   */
  runCell(code: string, opts: CellRunOptions): Promise<CellRunResult> {
    const pending = Promise.withResolvers<CellRunResult>();
    if (this.dead) {
      pending.resolve({ ok: false, error: "eval VM is not running", stdout: "", stderr: "", displays: [], durationMs: 0 });
      return pending.promise;
    }
    const id = `c${++this.seq}`;
    const started = Date.now();
    const result: CellRunResult = { ok: false, stdout: "", stderr: "", displays: [], durationMs: 0 };
    const abort = () => {
      if (this.current !== cell) return;
      this.kill();
      this.current = null;
      pending.resolve({
        ...result,
        ok: false,
        error: "eval aborted (VM state was reset)",
        durationMs: Date.now() - started,
      });
    };
    opts.signal?.addEventListener("abort", abort, { once: true });
    const timer = setTimeout(() => {
      this.kill();
      if (this.current === cell) this.current = null;
      pending.resolve({
        ...result,
        ok: false,
        error: `timed out after ${opts.timeoutMs}ms (VM state was reset)`,
        timedOut: true,
        durationMs: Date.now() - started,
      });
    }, opts.timeoutMs);
    const cell: PendingCell = {
      result,
      timer,
      bridge: opts.bridge,
      resolve: (r) => {
        clearTimeout(timer);
        opts.signal?.removeEventListener("abort", abort);
        if (this.current === cell) this.current = null;
        pending.resolve(r);
      },
    };
    this.current = cell;
    this.proc.writeStdin(`${JSON.stringify({ t: "cell", id, code })}\n`);
    return pending.promise;
  }

  private onChunk(chunk: Uint8Array, stream: "stdout" | "stderr"): void {
    if (this.dead) return; // stale output from a killed process
    const text = new TextDecoder().decode(chunk);
    const bufferKey = stream === "stdout" ? "stdoutBuf" : "stderrBuf";
    this[bufferKey] += text;
    const buffer = this[bufferKey];
    const lines = buffer.split("\n");
    this[bufferKey] = lines.pop() ?? "";
    for (const line of lines) {
      if (stream === "stdout") this.handleStdoutLine(line);
      else this.handleStderrLine(line);
    }
  }

  private handleStdoutLine(line: string): void {
    if (line.startsWith(FRAME_PREFIX)) {
      let frame: Record<string, unknown>;
      try {
        frame = JSON.parse(line.slice(FRAME_PREFIX.length)) as Record<string, unknown>;
      } catch {
        return;
      }
      this.handleFrame(frame);
      return;
    }
    if (this.current) this.current.result.stdout += `${line}\n`;
  }

  private handleStderrLine(line: string): void {
    if (this.current) this.current.result.stderr += `${line}\n`;
  }

  private handleFrame(frame: Record<string, unknown>): void {
    switch (frame.t) {
      case "ready": {
        this.readyResolve?.();
        this.readyResolve = null;
        return;
      }
      case "out": {
        if (this.current && typeof frame.s === "string") this.current.result.stdout += `${frame.s}\n`;
        return;
      }
      case "err": {
        if (this.current && typeof frame.s === "string") this.current.result.stderr += `${frame.s}\n`;
        return;
      }
      case "display": {
        this.current?.result.displays.push(frame.v);
        return;
      }
      case "cell_end": {
        const cell = this.current;
        if (!cell) return;
        cell.result.ok = frame.ok === true;
        if (typeof frame.error === "string") cell.result.error = frame.error;
        cell.resolve(cell.result);
        return;
      }
      case "bridge": {
        void this.handleBridgeFrame(frame);
        return;
      }
    }
  }

  private async handleBridgeFrame(frame: Record<string, unknown>): Promise<void> {
    const id = frame.id;
    const name = typeof frame.name === "string" ? frame.name : "";
    const args = frame.args;
    try {
      const cell = this.current;
      if (!cell) throw new Error("no cell is running");
      const value = await cell.bridge(name, args);
      if (!this.dead) {
        this.proc.writeStdin(`${JSON.stringify({ t: "bridge_result", id, ok: true, result: value })}\n`);
      }
    } catch (e) {
      if (!this.dead) {
        const message = e instanceof Error ? e.message : String(e);
        this.proc.writeStdin(`${JSON.stringify({ t: "bridge_result", id, ok: false, error: message })}\n`);
      }
    }
  }
}
