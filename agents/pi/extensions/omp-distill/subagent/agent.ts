import { existsSync, readFileSync, readdirSync } from "node:fs";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const BUNDLED_AGENTS_DIR = join(__dirname, "agents");

export type SessionMode = "standalone" | "lineage-only" | "fork";

export interface AgentDefinition {
  name: string;
  description: string;
  model?: string;
  tools?: string;
  skills?: string;
  autoExit: boolean;
  sessionMode: SessionMode;
  denyTools: string[];
  spawning: boolean;
  systemPrompt: string;
}

function getGlobalAgentDir(): string {
  return process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
}

function getVal(frontmatter: string, key: string): string | undefined {
  return frontmatter.match(new RegExp(`^${key}:\\s*(.+)$`, "m"))?.[1]?.trim();
}

function getBool(frontmatter: string, key: string, fallback: boolean): boolean {
  const v = getVal(frontmatter, key);
  if (v === undefined) return fallback;
  return v.toLowerCase() === "true";
}

function getList(frontmatter: string, key: string): string[] {
  const v = getVal(frontmatter, key);
  if (!v) return [];
  return v
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

function parseSessionMode(v: string | undefined): SessionMode {
  if (v === "fork") return "fork";
  if (v === "lineage-only") return "lineage-only";
  return "standalone";
}

function parseAgentFile(filePath: string): AgentDefinition | null {
  const content = readFileSync(filePath, "utf8");
  const match = content.match(/^---\n([\s\S]*?)\n---\n*([\s\S]*)$/);
  if (!match) return null;

  const frontmatter = match[1];
  const body = match[2].trim();
  const name = filePath.replace(/\.md$/, "").split("/").pop() ?? "unknown";

  return {
    name: getVal(frontmatter, "name") ?? name,
    description: getVal(frontmatter, "description") ?? "",
    model: getVal(frontmatter, "model"),
    tools: getVal(frontmatter, "tools"),
    skills: getVal(frontmatter, "skill") ?? getVal(frontmatter, "skills"),
    autoExit: getBool(frontmatter, "auto-exit", true),
    sessionMode: parseSessionMode(getVal(frontmatter, "session-mode")),
    denyTools: getList(frontmatter, "deny-tools"),
    spawning: getBool(frontmatter, "spawning", true),
    systemPrompt: body,
  };
}

/** Discover agent definitions: project → global → bundled. */
export function discoverAgents(): AgentDefinition[] {
  const seen = new Map<string, AgentDefinition>();

  const dirs = [
    join(process.cwd(), ".pi", "agents"),
    join(getGlobalAgentDir(), "agents"),
    BUNDLED_AGENTS_DIR,
  ];

  for (const dir of dirs) {
    if (!existsSync(dir)) continue;
    for (const file of readdirSync(dir)) {
      if (!file.endsWith(".md")) continue;
      const parsed = parseAgentFile(join(dir, file));
      if (parsed && !seen.has(parsed.name)) {
        seen.set(parsed.name, parsed);
      }
    }
  }

  return [...seen.values()];
}

/** Load a specific agent by name. Falls back to bundled agents dir only. */
export function loadAgent(name: string): AgentDefinition | null {
  return discoverAgents().find((a) => a.name === name) ?? null;
}

/** Resolve deny tools from agent definition + spawning flag. */
export function resolveDenyTools(agent: AgentDefinition | null): Set<string> {
  const denied = new Set<string>();
  if (!agent) return denied;

  if (!agent.spawning) {
    denied.add("subagent");
  }

  for (const tool of agent.denyTools) {
    denied.add(tool);
  }

  return denied;
}
