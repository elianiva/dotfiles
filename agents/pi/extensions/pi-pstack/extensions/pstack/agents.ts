import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { CONFIG_DIR_NAME, getAgentDir, parseFrontmatter } from "@earendil-works/pi-coding-agent";

export type AgentScope = "bundled" | "user" | "project" | "both";
export type AgentSource = "bundled" | "user" | "project";

export interface AgentConfig {
  name: string;
  description: string;
  tools?: string[];
  model?: string;
  systemPrompt: string;
  source: AgentSource;
  filePath: string;
}

function loadDirectory(directory: string, source: AgentSource): AgentConfig[] {
  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(directory, { withFileTypes: true });
  } catch {
    return [];
  }

  const agents: AgentConfig[] = [];
  for (const entry of entries) {
    if (!entry.name.endsWith(".md") || (!entry.isFile() && !entry.isSymbolicLink())) continue;
    const filePath = path.join(directory, entry.name);
    try {
      const { frontmatter, body } = parseFrontmatter<Record<string, string>>(fs.readFileSync(filePath, "utf8"));
      if (!frontmatter.name || !frontmatter.description) continue;
      const tools = frontmatter.tools
        ?.split(",")
        .map((tool) => tool.trim())
        .filter(Boolean);
      agents.push({
        name: frontmatter.name,
        description: frontmatter.description,
        tools: tools?.length ? tools : undefined,
        model: frontmatter.model,
        systemPrompt: body,
        source,
        filePath,
      });
    } catch {
      // An invalid local agent must not prevent the package from loading.
    }
  }
  return agents;
}

function findProjectAgents(cwd: string): string | undefined {
  let directory = path.resolve(cwd);
  while (true) {
    const candidate = path.join(directory, CONFIG_DIR_NAME, "agents");
    try {
      if (fs.statSync(candidate).isDirectory()) return candidate;
    } catch {
      // Keep walking toward the filesystem root.
    }
    const parent = path.dirname(directory);
    if (parent === directory) return undefined;
    directory = parent;
  }
}

export function bundledAgentsDirectory(): string {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../agents");
}

/**
 * Pi's example subagent convention is supported unchanged:
 * ~/.pi/agent/agents/*.md and .pi/agents/*.md. Bundled agents are prepended so
 * this package works immediately after `pi install` without copying files into
 * the user's config directory. User and project agents override earlier names.
 */
export function discoverAgents(cwd: string, scope: AgentScope): AgentConfig[] {
  const byName = new Map<string, AgentConfig>();
  const add = (agents: AgentConfig[]) => agents.forEach((agent) => byName.set(agent.name, agent));

  if (scope === "bundled" || scope === "both") add(loadDirectory(bundledAgentsDirectory(), "bundled"));
  if (scope === "user" || scope === "both") add(loadDirectory(path.join(getAgentDir(), "agents"), "user"));
  if (scope === "project" || scope === "both") {
    const projectDirectory = findProjectAgents(cwd);
    if (projectDirectory) add(loadDirectory(projectDirectory, "project"));
  }
  return [...byName.values()];
}

export function projectAgentsDirectory(cwd: string): string | undefined {
  return findProjectAgents(cwd);
}
