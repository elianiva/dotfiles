/**
 * Shared gh CLI utilities.
 *
 * Provides cached gh binary detection and both sync/async execution.
 * Both github.ts and github-repo.ts use these instead of rolling their own.
 */
import { execFile, execSync } from "node:child_process";

export const GH_NOT_FOUND =
  "gh CLI not found. Install it from https://cli.github.com/ and authenticate with `gh auth login`.";

let ghPath: string | undefined;

/** Find gh binary path (sync, cached). Throws if not found. */
export function findGhSync(): string {
  if (ghPath !== undefined) return ghPath;
  try {
    const out = execSync("which gh", { encoding: "utf-8", timeout: 5000 });
    ghPath = out.trim();
    return ghPath;
  } catch {
    throw new Error(GH_NOT_FOUND);
  }
}

/** Check if gh is available (async, cached). */
export async function isGhAvailable(): Promise<boolean> {
  try { findGhSync(); return true; }
  catch { return false; }
}

/** Execute gh command synchronously. Returns stdout. */
export function execGhSync(
  args: string[],
  options?: { cwd?: string; timeout?: number; maxBuffer?: number },
): string {
  const gh = findGhSync();
  const shellSafe = [gh, ...args].map((a) => (a.includes(" ") ? `"${a}"` : a)).join(" ");
  try {
    return execSync(shellSafe, {
      encoding: "utf-8",
      cwd: options?.cwd,
      timeout: options?.timeout ?? 30_000,
      maxBuffer: options?.maxBuffer ?? 10 * 1024 * 1024,
    });
  } catch (err: any) {
    const msg = err.stderr?.toString() || err.message || String(err);
    throw new Error(`gh command failed: ${msg}`);
  }
}

/** Execute gh command asynchronously. Returns stdout. */
export function execGhAsync(
  args: string[],
  options?: { cwd?: string; timeout?: number; signal?: AbortSignal; maxBuffer?: number },
): Promise<string> {
  return new Promise((resolve, reject) => {
    execFile(
      "gh",
      args,
      {
        cwd: options?.cwd,
        timeout: options?.timeout ?? 30_000,
        maxBuffer: options?.maxBuffer ?? 10 * 1024 * 1024,
        signal: options?.signal,
      },
      (err, stdout) => {
        if (err) {
          const msg = err.stderr?.toString() || err.message || String(err);
          reject(new Error(`gh command failed: ${msg}`));
        } else {
          resolve(stdout);
        }
      },
    );
  });
}
