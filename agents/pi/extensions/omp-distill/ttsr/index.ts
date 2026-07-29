/**
 * TTSR (Time-Traveling Stream Rules) hook setup.
 *
 * Registers tool_result and turn_end hooks to check edited/written files
 * against ast-grep rules and inject violation reminders as steers.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isAbsolute, join as pathJoin, relative as pathRelative } from "node:path";
import { homedir } from "node:os";
import { loadConfig, resolveRules } from "./config";
import { checkFile } from "./checker";
import { isNapiAvailable } from "./napi";
import type { Violation } from "./types";

// ─── Constants ───

const GLOBAL_RULES_DIR = pathJoin(homedir(), ".pi", "agent", "ttsr-rules");

// ─── Public API ───

let setupDone = false;

/**
 * Reset internal state so TTSR can be re-initialized on the next session_start.
 * Called from session_shutdown to support /reload, /new, /fork, etc.
 */
export function resetTtsr(): void {
  setupDone = false;
}

/**
 * Set up TTSR hooks on the pi extension API.
 *
 * Must be called during extension initialization (session_start or earlier).
 * Idempotent — subsequent calls are no-ops.
 * Gated on @ast-grep/napi availability — silently no-ops if unavailable.
 */
export function setupTtsr(pi: ExtensionAPI, cwd: string): void {
  if (setupDone) return;
  if (!isNapiAvailable()) {
    console.warn(
      "[omp-distill/ttsr] @ast-grep/napi not loaded — TTSR disabled for this session",
    );
    setupDone = true;
    return;
  }

  const projectRulesDir = pathJoin(cwd, ".pi", "ttsr-rules");
  const ruleDirs = [GLOBAL_RULES_DIR, projectRulesDir];

  // Resolve config at startup
  const config = loadConfig(GLOBAL_RULES_DIR, projectRulesDir);
  if (config.defaults?.enabled === false) {
    setupDone = true;
    return;
  }

  const resolvedRules = resolveRules(config, cwd);

  // Per-turn violation accumulator
  const turnViolations = new Map<string, Violation[]>();
  // Dedup key set within a single turn: "ruleId:filePath"
  const seenInTurn = new Set<string>();

  // ─── tool_result hook: check written/edited files ───

  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName !== "write" && event.toolName !== "edit") return;

    // Get the file path from the tool input
    const input = event.input as { path?: string; filePath?: string };
    const rawPath = input?.path ?? input?.filePath;
    if (!rawPath) return;

    // Resolve relative paths against cwd
    const filePath = isAbsolute(rawPath) ? rawPath : pathJoin(ctx.cwd, rawPath);

    // Check the file after it's been written
    const violations = checkFile(filePath, ruleDirs, resolvedRules);

    if (violations.length > 0) {
      turnViolations.set(filePath, violations);
    }
  });

  // ─── turn_end hook: flush accumulated violations as a steer ───

  pi.on("turn_end", async (_event, _ctx) => {
    if (turnViolations.size === 0) return;

    // Flatten and deduplicate within this turn
    const allViolations: Violation[] = [];
    seenInTurn.clear();

    for (const violations of turnViolations.values()) {
      for (const v of violations) {
        const key = `${v.ruleId}:${v.filePath}`;
        if (seenInTurn.has(key)) continue;
        seenInTurn.add(key);
        allViolations.push(v);
      }
    }

    // Clear the accumulator for next turn
    turnViolations.clear();

    if (allViolations.length === 0) return;

    // Build the reminder message with paths relative to cwd
    const message = formatViolations(allViolations, cwd);
    if (!message) return;

    // Inject as a steer so it lands before the next model turn
    pi.sendUserMessage(message, { deliverAs: "steer" });
  });

  setupDone = true;
}

// ─── Message formatting ───

function formatViolations(violations: Violation[], cwd: string): string | null {
  if (violations.length === 0) return null;

  // Group by file, using relative paths
  const byFile = new Map<string, Violation[]>();
  for (const v of violations) {
    const relPath = v.filePath.startsWith(cwd)
      ? pathRelative(cwd, v.filePath)
      : v.filePath;
    const existing = byFile.get(relPath) ?? [];
    existing.push(v);
    byFile.set(relPath, existing);
  }

  const lines: string[] = [];
  const totalCount = violations.length;

  lines.push(`⚠ TTSR found ${totalCount} issue(s):`);

  for (const [relPath, fileViolations] of byFile) {
    const parts = fileViolations.map(
      (v) => `${v.ruleId} (${v.message})`,
    );
    lines.push(`  ${relPath} — ${parts.join(", ")}`);
  }

  return lines.join("\n");
}
