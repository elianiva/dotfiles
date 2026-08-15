/**
 * Shared cell-run protocol types for the eval tool (both languages).
 */

export interface CellRunOptions {
  /** Wall-clock budget for the cell, including bridge calls (ms). */
  timeoutMs: number;
  /**
   * Abort the cell when this signal fires (user cancel). Destructive: the
   * guest process is killed and state is lost.
   */
  signal?: AbortSignal;
  /**
   * Host-side handler for guest bridge calls (`tool.<name>(...)` / `tool_<name>(...)`,
   * `env`). Must return a JSON-serializable value or throw.
   */
  bridge: (name: string, args: unknown) => Promise<unknown>;
}

export interface CellRunResult {
  ok: boolean;
  error?: string;
  stdout: string;
  stderr: string;
  /** Values emitted via display() / captured from the trailing expression. */
  displays: unknown[];
  durationMs: number;
  timedOut?: boolean;
}
