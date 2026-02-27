/**
 * Agent Profiles Extension
 *
 * Define agent personas in markdown files with frontmatter.
 * Content is appended to system prompt each turn.
 *
 * Location:
 * - ~/.pi/agent/agents/*.md (global)
 * - .pi/agents/*.md (project-local, overrides)
 *
 * Format:
 * ```markdown
 * ---
 * name: my-agent
 * description: What this agent does
 * tools: [read, bash, edit, write]  # whitelist (omit for all)
 * disabledTools: [grep]             # blacklist (omit for none)
 * ---
 *
 * Your system prompt additions here...
 * ```
 *
 * Usage:
 * - `pi --agent plan` - start with plan agent
 * - `/agent` - show selector
 * - `/agent plan` - switch to plan agent
 * - `/agent default` - reset to default
 */

import { existsSync, readFileSync, readdirSync } from "node:fs";
import { homedir } from "node:os";
import { join, basename, extname } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import { DynamicBorder } from "@mariozechner/pi-coding-agent";
import {
  Key,
  Container,
  type SelectItem,
  SelectList,
  Text,
} from "@mariozechner/pi-tui";

interface AgentProfile {
  name: string;
  description: string;
  tools?: string[];
  disabledTools?: string[];
  provider?: string;
  content: string; // appended to system prompt
}

const DEFAULT_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// Hardcoded default agent - always available as fallback
const DEFAULT_AGENT: AgentProfile = {
  name: "default",
  description: "Default agent with full capabilities",
  tools: DEFAULT_TOOLS,
  content:
    "You are pi, a minimal terminal coding agent. Use the tools available to help the user.",
};

/**
 * Parse frontmatter from markdown content
 */
function parseFrontmatter(content: string): {
  frontmatter: Record<string, unknown>;
  body: string;
} {
  const match = content.match(/^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/);
  if (!match) {
    return { frontmatter: {}, body: content };
  }

  const yamlText = match[1];
  const body = match[2].trim();

  const frontmatter: Record<string, unknown> = {};
  for (const line of yamlText.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx === -1) continue;

    const key = line.slice(0, colonIdx).trim();
    let value: unknown = line.slice(colonIdx + 1).trim();

    // Parse arrays: [item1, item2]
    if (
      typeof value === "string" &&
      value.startsWith("[") &&
      value.endsWith("]")
    ) {
      value = value
        .slice(1, -1)
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean);
    }

    frontmatter[key] = value;
  }

  return { frontmatter, body };
}

/**
 * Load agent profiles from directory
 */
function loadAgentsFromDir(dir: string): Map<string, AgentProfile> {
  const agents = new Map<string, AgentProfile>();

  if (!existsSync(dir)) return agents;

  const entries = readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isFile()) continue;
    if (extname(entry.name) !== ".md") continue;

    const filepath = join(dir, entry.name);
    try {
      const content = readFileSync(filepath, "utf-8");
      const { frontmatter, body } = parseFrontmatter(content);

      const name = (frontmatter.name as string) || basename(entry.name, ".md");

      agents.set(name, {
        name,
        description: (frontmatter.description as string) || "",
        tools: frontmatter.tools as string[] | undefined,
        disabledTools: frontmatter.disabledTools as string[] | undefined,
        provider: frontmatter.provider as string | undefined,
        content: body,
      });
    } catch {
      // skip invalid files
    }
  }

  return agents;
}

/**
 * Load all agents (global + project, project overrides)
 * Default agent is always available as fallback
 */
function loadAgents(cwd: string): Map<string, AgentProfile> {
  const globalDir = join(homedir(), ".pi", "agent", "agents");
  const projectDir = join(cwd, ".pi", "agents");

  // Start with default agent
  const agents = new Map<string, AgentProfile>();
  agents.set("default", DEFAULT_AGENT);

  // Load global agents (can override default if explicitly defined)
  const globalAgents = loadAgentsFromDir(globalDir);
  for (const [name, agent] of globalAgents) {
    agents.set(name, agent);
  }

  // Load project agents (override global)
  const projectAgents = loadAgentsFromDir(projectDir);
  for (const [name, agent] of projectAgents) {
    agents.set(name, agent);
  }

  return agents;
}

/**
 * Get effective tools list for an agent
 */
function getEffectiveTools(agent: AgentProfile | undefined): string[] {
  if (!agent) return DEFAULT_TOOLS;

  // Explicit whitelist
  if (agent.tools) {
    return agent.tools.filter((t) => DEFAULT_TOOLS.includes(t));
  }

  // Blacklist mode
  if (agent.disabledTools) {
    return DEFAULT_TOOLS.filter((t) => !agent.disabledTools?.includes(t));
  }

  return DEFAULT_TOOLS;
}

export default function agentProfilesExtension(pi: ExtensionAPI) {
  let agents = new Map<string, AgentProfile>();
  let activeAgent: AgentProfile | undefined;
  let baseSystemPrompt = ""; // captured at session start

  // Register --agent CLI flag
  pi.registerFlag("agent", {
    description: "Agent profile to use",
    type: "string",
  });

  /**
   * Apply an agent profile
   */
  async function applyAgent(
    name: string,
    agent: AgentProfile | undefined,
    ctx: ExtensionContext,
  ): Promise<void> {
    activeAgent = agent;

    // Emit event for other extensions (e.g., starship-prompt)
    pi.events.emit("agent-profile:changed", {
      name: agent?.name ?? "default",
      description: agent?.description ?? "",
    });

    if (!agent) {
      // Reset to default
      pi.setActiveTools(DEFAULT_TOOLS);
      ctx.ui.notify("Reset to default agent", "info");
      updateStatus(ctx);
      return;
    }

    // Apply tools - this rebuilds the system prompt with correct tool descriptions
    const tools = getEffectiveTools(agent);
    pi.setActiveTools(tools);

    ctx.ui.notify(`Agent "${name}" activated (${tools.length} tools)`, "info");
    updateStatus(ctx);
  }

  /**
   * Build description for UI
   */
  function buildDescription(agent: AgentProfile): string {
    const parts: string[] = [];

    const tools = getEffectiveTools(agent);
    if (tools.length !== DEFAULT_TOOLS.length) {
      parts.push(`${tools.length} tools`);
    }

    if (agent.description) {
      const truncated =
        agent.description.length > 40
          ? `${agent.description.slice(0, 37)}...`
          : agent.description;
      parts.push(truncated);
    }

    return parts.join(" | ") || "Custom agent profile";
  }

  /**
   * Show agent selector UI
   */
  async function showAgentSelector(ctx: ExtensionContext): Promise<void> {
    const agentList = Array.from(agents.values()).sort((a, b) =>
      a.name.localeCompare(b.name),
    );

    if (agentList.length === 0) {
      ctx.ui.notify(
        "No agent profiles found. Create files in ~/.pi/agent/agents/ or .pi/agents/",
        "warning",
      );
      return;
    }

    const items: SelectItem[] = [
      {
        value: "default",
        label: "default",
        description: "Reset to default (all tools, no additions)",
      },
      ...agentList.map((agent) => ({
        value: agent.name,
        label:
          agent.name === activeAgent?.name
            ? `${agent.name} (active)`
            : agent.name,
        description: buildDescription(agent),
      })),
    ];

    const result = await ctx.ui.custom<string | null>(
      (tui, theme, _kb, done) => {
        const container = new Container();
        container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
        container.addChild(
          new Text(theme.fg("accent", theme.bold("Select Agent Profile"))),
        );

        const selectList = new SelectList(items, Math.min(items.length, 12), {
          selectedPrefix: (text) => theme.fg("accent", text),
          selectedText: (text) => theme.fg("accent", text),
          description: (text) => theme.fg("muted", text),
          scrollInfo: (text) => theme.fg("dim", text),
          noMatch: (text) => theme.fg("warning", text),
        });

        selectList.onSelect = (item) => done(item.value);
        selectList.onCancel = () => done(null);

        const k = (s: string) => theme.bold(theme.fg("accent", s));
        const l = (s: string) => theme.fg("dim", s);
        container.addChild(selectList);
        container.addChild(
          new Text(
            ` ${k("↑↓")}${l(" select")} · ${k("enter")}${l(" submit")} · ${k("esc")}${l(" dismiss")}`,
          ),
        );
        container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

        return {
          render(width: number) {
            return container.render(width);
          },
          invalidate() {
            container.invalidate();
          },
          handleInput(data: string) {
            selectList.handleInput(data);
            tui.requestRender();
          },
        };
      },
    );

    if (!result) return;

    if (result === "default") {
      await applyAgent("default", undefined, ctx);
    } else {
      const agent = agents.get(result);
      if (agent) {
        await applyAgent(result, agent, ctx);
      }
    }
  }

  /**
   * Update status in footer
   */
  function updateStatus(ctx: ExtensionContext) {
    if (activeAgent && activeAgent.name !== "default") {
      ctx.ui.setStatus(
        "agent",
        ctx.ui.theme.fg("accent", `agent:${activeAgent.name}`),
      );
    } else {
      ctx.ui.setStatus("agent", undefined);
    }
  }

  /**
   * Get ordered list of agent names for cycling
   */
  function getAgentOrder(): string[] {
    return [
      "default",
      ...Array.from(agents.keys())
        .filter((n) => n !== "default")
        .sort(),
    ];
  }

  /**
   * Cycle to next agent
   */
  async function cycleAgent(ctx: ExtensionContext): Promise<void> {
    const agentNames = getAgentOrder();
    if (agentNames.length <= 1) {
      ctx.ui.notify("No custom agents to cycle", "warning");
      return;
    }

    const currentName = activeAgent?.name ?? "default";
    const currentIndex = agentNames.indexOf(currentName);
    const nextIndex =
      currentIndex === -1 ? 0 : (currentIndex + 1) % agentNames.length;
    const nextName = agentNames[nextIndex];

    if (nextName === "default") {
      await applyAgent("default", undefined, ctx);
    } else {
      const agent = agents.get(nextName);
      if (agent) {
        await applyAgent(nextName, agent, ctx);
      }
    }
  }

  // Register keyboard shortcut to cycle agents
  pi.registerShortcut(Key.ctrl(";"), {
    description: "Cycle to next agent profile",
    handler: (ctx) => cycleAgent(ctx),
  });

  // Inject agent content into system prompt each turn
  // This appends to the base system prompt (which was already rebuilt with correct tools)
  pi.on("before_agent_start", async (event) => {
    if (activeAgent?.content) {
      return {
        systemPrompt: `${event.systemPrompt}\n\n${activeAgent.content}`,
      };
    }
  });

  // Initialize on session start
  pi.on("session_start", async (_event, ctx) => {
    // Load agents (includes hardcoded default)
    agents = loadAgents(ctx.cwd);

    // Set default as initial active agent
    activeAgent = DEFAULT_AGENT;

    // Capture base system prompt (for reference, not used directly)
    baseSystemPrompt = ctx.getSystemPrompt();

    // Emit initial state immediately so other extensions (e.g., starship-prompt) have valid state
    pi.events.emit("agent-profile:changed", {
      name: DEFAULT_AGENT.name,
      description: DEFAULT_AGENT.description,
      tools: DEFAULT_AGENT.tools,
    });

    // Check CLI flag first
    const agentFlag = pi.getFlag("agent");
    if (typeof agentFlag === "string" && agentFlag) {
      if (agentFlag === "default") {
        // Already default, just notify
        ctx.ui.notify("Using default agent", "info");
      } else {
        const agent = agents.get(agentFlag);
        if (agent) {
          await applyAgent(agentFlag, agent, ctx);
        } else {
          const available = ["default", ...Array.from(agents.keys())].join(
            ", ",
          );
          ctx.ui.notify(
            `Unknown agent "${agentFlag}". Available: ${available}`,
            "warning",
          );
        }
      }
      updateStatus(ctx);
      return;
    }

    // Restore from session state
    const entries = ctx.sessionManager.getEntries();
    const agentEntry = entries
      .filter(
        (e: { type: string; customType?: string }) =>
          e.type === "custom" && e.customType === "agent-profile",
      )
      .pop() as { data?: { name: string } } | undefined;

    if (agentEntry?.data?.name && agentEntry.data.name !== "default") {
      const agent = agents.get(agentEntry.data.name);
      if (agent) {
        await applyAgent(agentEntry.data.name, agent, ctx);
      }
    }

    updateStatus(ctx);
  });

  // Persist active agent
  pi.on("turn_start", async () => {
    if (activeAgent) {
      pi.appendEntry("agent-profile", { name: activeAgent.name });
    } else {
      pi.appendEntry("agent-profile", { name: "default" });
    }
  });

  // Register /agent command
  pi.registerCommand("agent", {
    description: "Switch agent profile",
    handler: async (args, ctx) => {
      const name = args?.trim();

      if (!name) {
        await showAgentSelector(ctx);
        return;
      }

      if (name === "default") {
        await applyAgent("default", undefined, ctx);
        return;
      }

      const agent = agents.get(name);
      if (!agent) {
        const available = ["default", ...Array.from(agents.keys())].join(", ");
        ctx.ui.notify(
          `Unknown agent "${name}". Available: ${available}`,
          "error",
        );
        return;
      }

      await applyAgent(name, agent, ctx);
    },
  });
}
