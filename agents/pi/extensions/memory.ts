/**
 * Memory Extension - Save and recall session learnings to Obsidian vault
 *
 * Commands:
 * - `/save` - Extract key learnings from current session and save to vault
 * - `/recall <query>` - Search saved learnings using qmd
 *
 * Configuration:
 * - VAULT_PATH: ~/Development/personal/notes (hardcoded)
 * - Notes stored in: Sessions Learnings/ subdirectory
 */

import { complete, type Message } from "@mariozechner/pi-ai";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@mariozechner/pi-coding-agent";
import { homedir } from "node:os";
import path from "node:path";
import fs from "node:fs/promises";
import { existsSync } from "node:fs";

// Configuration
const VAULT_PATH = path.join(homedir(), "Development", "personal", "notes");
const NOTES_FOLDER = "Sessions Learnings";

// Maximum messages to include in extraction (avoid token explosion)
const MAX_MESSAGES = 50;

// Maximum title length for filename
const MAX_TITLE_LENGTH = 40;

// YAML frontmatter separator
const YAML_SEP = "---";

/**
 * Entry from session manager
 */
interface SessionEntry {
  id: string;
  type: string;
  customType?: string;
  parentId?: string;
  timestamp: string;
  data?: unknown;
  message?: {
    role: string;
    content?: Array<{ type: string; text?: string }>;
  };
}

/**
 * Build conversation text from recent session entries
 */
function buildConversation(entries: SessionEntry[]): string {
  // Get user and assistant messages
  const messages: Array<{ role: string; text: string }> = [];

  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message) continue;

    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;

    // Extract text content
    let text = "";
    if (entry.message.content && Array.isArray(entry.message.content)) {
      for (const part of entry.message.content) {
        if (part.type === "text" && part.text) {
          text += part.text;
        }
      }
    }

    if (text.trim()) {
      messages.push({ role, text: text.trim() });
    }
  }

  // Take last N messages (most recent)
  const recent = messages.slice(-MAX_MESSAGES);

  return recent
    .map((m) => `${m.role.toUpperCase()}: ${m.text.slice(0, 500)}`) // Truncate each message
    .join("\n\n---\n\n");
}

/**
 * Safe filename from title
 */
function sanitizeFilename(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "") // Remove special chars except spaces and hyphens
    .replace(/\s+/g, "-")         // Spaces to hyphens
    .replace(/-+/g, "-")          // Collapse multiple hyphens
    .slice(0, MAX_TITLE_LENGTH)
    .replace(/^-+|-+$/g, "");      // Trim hyphens from ends
}

/**
 * Generate timestamp suffix
 */
function getTimestamp(): string {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  const hh = String(now.getHours()).padStart(2, "0");
  const mi = String(now.getMinutes()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}T${hh}-${mi}`;
}

const SAVE_PROMPT = `Extract generalizable learnings from this coding session.

Focus on insights, patterns, and practices that apply across projects - not project-specific details.

Output simple markdown with these sections:
- ## DOs: General best practices, things that worked well
- ## DONTs: General pitfalls to avoid, common mistakes
- ## Key Learnings: General insights, patterns, or principles discovered

Keep it practical and concise. Use bullet points. Make it applicable to future projects.

Session conversation:
{{conversation}}

Output format:
# <short title>

## DOs
- General best practice
- Another good approach

## DONTs
- General pitfall to avoid
- Common mistake

## Key Learnings
- General insight
- Transferable principle`;

/**
 * Parse title from markdown H1 or generate from first line
 */
function parseTitle(content: string): string {
  // Try to find H1
  const match = content.match(/^#\s+(.+)$/m);
  if (match) return match[1]?.trim() ?? "Untitled";

  // Use first non-empty line as title
  const firstLine = content.split("\n").find((line) => line.trim());
  if (firstLine) return firstLine.trim().slice(0, MAX_TITLE_LENGTH);

  return "Untitled";
}

/**
 * Parse tags from content (extract technical terms)
 */
function extractTags(content: string): string[] {
  const techTerms = [
    "typescript", "javascript", "react", "effect", "schema", "layer",
    "api", "database", "testing", "git", "docker", "kubernetes",
    "frontend", "backend", "performance", "security", "refactoring",
    "architecture", "design", "obsidian", "qmd", "python", "rust",
    "go", "bun", "node", "deno", "sql", "nosql", "redis", "kafka"
  ];

  const lower = content.toLowerCase();
  return techTerms.filter(term => lower.includes(term)).slice(0, 5);
}

const RECALL_PROMPT = `Based on these search results from your memory vault, synthesize a helpful response.

Search query: {{query}}

Results:
{{results}}

If results are relevant, summarize what was found. If nothing is relevant, say so clearly.`;

export default function memoryExtension(pi: ExtensionAPI) {
  // Check vault exists at startup
  async function checkVault(): Promise<boolean> {
    return existsSync(VAULT_PATH);
  }

  // Ensure Sessions Learnings folder exists
  async function ensureNotesFolder(): Promise<string> {
    const folderPath = path.join(VAULT_PATH, NOTES_FOLDER);
    if (!existsSync(folderPath)) {
      await fs.mkdir(folderPath, { recursive: true });
    }
    return folderPath;
  }



  // Register /save command
  pi.registerCommand("save", {
    description: "Extract and save key learnings from current session to Obsidian vault",
    handler: async (_args, ctx: ExtensionCommandContext) => {
      // Check vault
      if (!(await checkVault())) {
        ctx.ui.notify(
          `Vault not found at ${VAULT_PATH}`,
          "error",
        );
        return;
      }

      // Get session entries
      const entries = ctx.sessionManager.getEntries() as SessionEntry[];
      if (entries.length === 0) {
        ctx.ui.notify("No session history to save", "warning");
        return;
      }

      // Build conversation from entries
      const conversation = buildConversation(entries);
      if (!conversation) {
        ctx.ui.notify("No meaningful conversation to extract from", "warning");
        return;
      }

      // Use oneshot complete for extraction (like handoff)
      ctx.ui.notify("Extracting insights...", "info");

      try {
        const apiKey = await ctx.modelRegistry.getApiKey(ctx.model!);

        const userMessage: Message = {
          role: "user",
          content: [
            {
              type: "text",
              text: SAVE_PROMPT.replace("{{conversation}}", conversation),
            },
          ],
          timestamp: Date.now(),
        };

        const response = await complete(
          ctx.model!,
          { systemPrompt: "You extract key learnings from coding sessions into markdown format.", messages: [userMessage] },
          { apiKey },
        );

        const content = response.content
          .filter((c): c is { type: "text"; text: string } => c.type === "text")
          .map((c) => c.text)
          .join("\n");

        if (!content) {
          ctx.ui.notify("Failed to extract insights", "error");
          return;
        }

        // Parse title and save
        const title = parseTitle(content);

        const folderPath = await ensureNotesFolder();
        const safeTitle = sanitizeFilename(title);
        const filename = `${getTimestamp()}-${safeTitle}.md`;
        const filepath = path.join(folderPath, filename);

        const tags = extractTags(content);

        // Build markdown with YAML frontmatter + LLM content
        const fileContent = `${YAML_SEP}
date: ${new Date().toISOString()}
source: pi-session
${tags.length > 0 ? `tags:\n${tags.map((t) => `  - ${t}`).join("\n")}` : ""}
---

${content}

---
*Saved from pi session*
`;

        await fs.writeFile(filepath, fileContent, "utf-8");
        ctx.ui.notify(`Saved to ${path.join(NOTES_FOLDER, filename)}`, "success");
      } catch (err) {
        ctx.ui.notify(
          `Failed to save: ${err instanceof Error ? err.message : String(err)}`,
          "error",
        );
      }
    },
  });

  // Register /recall command
  pi.registerCommand("recall", {
    description: "Search saved learnings: /recall <query>",
    handler: async (args, ctx: ExtensionCommandContext) => {
      const query = args?.trim();
      if (!query) {
        ctx.ui.notify("Usage: /recall <search query>", "error");
        return;
      }

      // Check vault
      if (!(await checkVault())) {
        ctx.ui.notify(`Vault not found at ${VAULT_PATH}`, "error");
        return;
      }

      // Check qmd is available
      const { code: qmdCheck } = await pi.exec("which", ["qmd"], { cwd: ctx.cwd });
      if (qmdCheck !== 0) {
        ctx.ui.notify(
          "qmd not found in PATH. Install from https://github.com/yourusername/qmd",
          "error",
        );
        return;
      }

      const notesPath = path.join(VAULT_PATH, NOTES_FOLDER);
      if (!existsSync(notesPath)) {
        ctx.ui.notify("No saved learnings found (Sessions Learnings folder missing)", "warning");
        return;
      }

      // Run qmd search
      ctx.ui.notify(`Searching: "${query}"...`, "info");

      const { stdout, stderr, code } = await pi.exec(
        "qmd",
        ["-d", notesPath, "-n", "5", query],
        { cwd: ctx.cwd },
      );

      if (code !== 0) {
        ctx.ui.notify(`qmd search failed: ${stderr || "unknown error"}`, "error");
        return;
      }

      if (!stdout.trim()) {
        pi.sendUserMessage(`No results found for "${query}" in your saved learnings.`);
        return;
      }

      // Send recall prompt with results
      const recallPrompt = RECALL_PROMPT
        .replace("{{query}}", query)
        .replace("{{results}}", stdout);

      pi.sendUserMessage(recallPrompt);
    },
  });
}
