import { appendFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { randomUUID } from "node:crypto";
import { dirname } from "node:path";

export interface SessionEntry {
  type: string;
  id: string;
  parentId?: string;
  [key: string]: unknown;
}

export interface MessageEntry extends SessionEntry {
  type: "message";
  message: {
    role: "user" | "assistant" | "toolResult";
    content: Array<{ type: string; text?: string; [key: string]: unknown }>;
  };
}

export type SeedMode = "fork" | "lineage-only";

/**
 * Seed a child session file with parent context.
 * - `fork`: copy all non-session entries up to the last user message
 * - `lineage-only`: write only the session header with parent linkage
 */
export function seedSessionFile(params: {
  mode: SeedMode;
  parentSessionFile: string;
  childSessionFile: string;
  childCwd: string;
}): void {
  const header = {
    type: "session",
    version: 3,
    id: randomUUID(),
    timestamp: new Date().toISOString(),
    cwd: params.childCwd,
    parentSession: params.parentSessionFile,
  };

  const contentLines = params.mode === "fork" ? getForkContent(params.parentSessionFile) : [];

  const lines = [JSON.stringify(header), ...contentLines];

  mkdirSync(dirname(params.childSessionFile), { recursive: true });
  writeFileSync(params.childSessionFile, lines.join("\n") + "\n", "utf8");
}

function getForkContent(parentSessionFile: string): string[] {
  if (!existsSync(parentSessionFile)) return [];

  const raw = readFileSync(parentSessionFile, "utf8");
  const lines = raw.split("\n").filter((line) => line.trim());

  // Find the last user message — truncate at that point so the child
  // sees the conversation up to (but not including) the parent's latest
  // user input, which is replaced by the task prompt.
  let truncateAt = lines.length;
  for (let i = lines.length - 1; i >= 0; i--) {
    try {
      const entry = JSON.parse(lines[i]);
      if (entry.type === "message" && entry.message?.role === "user") {
        truncateAt = i;
        break;
      }
    } catch {
      // skip malformed
    }
  }

  // Filter out session headers (only keep message entries)
  return lines.slice(0, truncateAt).filter((line) => {
    try {
      return JSON.parse(line).type !== "session";
    } catch {
      return true;
    }
  });
}

/** Read new entries added after `afterLine`. */
export function getNewEntries(sessionFile: string, afterLine: number): SessionEntry[] {
  if (!existsSync(sessionFile)) return [];
  const raw = readFileSync(sessionFile, "utf8");
  return raw
    .split("\n")
    .filter((line) => line.trim())
    .slice(afterLine)
    .map((line) => JSON.parse(line) as SessionEntry);
}

/** Find the last assistant message text in a list of entries. */
export function findLastAssistant(entries: SessionEntry[]): string | null {
  for (let i = entries.length - 1; i >= 0; i--) {
    const entry = entries[i];
    if (entry.type !== "message") continue;
    const msg = entry as MessageEntry;
    if (msg.message.role !== "assistant") continue;

    const texts = msg.message.content
      .filter(
        (block) =>
          block.type === "text" && typeof block.text === "string" && block.text.trim() !== "",
      )
      .map((block) => block.text as string);

    if (texts.length > 0 && texts.join("").trim()) return texts.join("\n");

    // Check for error stop reason
    const sr = (msg.message as { stopReason?: unknown }).stopReason;
    const em = (msg.message as { errorMessage?: unknown }).errorMessage;
    if (sr === "error" && typeof em === "string" && em.trim()) {
      return `Subagent error: ${em.trim()}`;
    }
  }
  return null;
}

/** Count lines in a session file. */
export function countLines(sessionFile: string): number {
  if (!existsSync(sessionFile)) return 0;
  return readFileSync(sessionFile, "utf8")
    .split("\n")
    .filter((line) => line.trim()).length;
}

/** Append entries from source to target, return appended entries. */
export function mergeEntries(
  sourceFile: string,
  targetFile: string,
  afterLine: number,
): SessionEntry[] {
  const entries = getNewEntries(sourceFile, afterLine);
  for (const entry of entries) {
    appendFileSync(targetFile, JSON.stringify(entry) + "\n", "utf8");
  }
  return entries;
}
