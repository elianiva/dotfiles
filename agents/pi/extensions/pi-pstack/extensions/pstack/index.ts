import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { StringEnum } from "@earendil-works/pi-ai";
import { SessionManager, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { ROLE_NAMES, configPath, defaultConfig, readConfig, writeConfig } from "./config.ts";

const MODE_ENTRY = "pstack-mode";

function packageRoot(): string {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
}

function knownExternalWrite(command: string): string | undefined {
  const patterns: Array<[RegExp, string]> = [
    [/\bgit\s+push\b/, "git push"],
    [/\bgh\s+pr\s+(create|edit|merge|close)\b/, "GitHub pull-request mutation"],
    [/\bgt\s+(submit|merge|create)\b/, "Graphite mutation"],
    [/\b(terraform|tofu)\s+(apply|destroy)\b/, "infrastructure mutation"],
    [/\bkubectl\s+(apply|delete|rollout)\b/, "Kubernetes mutation"],
    [/\b(vercel|flyctl|railway)\s+(deploy|promote)\b/, "deployment"],
    [/\brm\s+(-[A-Za-z]*r|--recursive)/, "recursive deletion"],
  ];
  return patterns.find(([pattern]) => pattern.test(command))?.[1];
}

export default function (pi: ExtensionAPI) {
  let potetoMode = false;
  let todos: string[] = [];

  pi.on("session_start", (_event, ctx) => {
    potetoMode = false;
    todos = [];
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "custom") continue;
      if (entry.customType === MODE_ENTRY) potetoMode = Boolean((entry.data as { enabled?: boolean }).enabled);
      if (entry.type === "custom" && entry.customType === "pstack-todo") {
        const items = (entry.data as { items?: unknown }).items;
        if (Array.isArray(items) && items.every((item) => typeof item === "string")) todos = items;
      }
    }
    if (ctx.mode === "tui") ctx.ui.setStatus("pstack-mode", potetoMode ? "pstack: poteto mode" : undefined);
  });

  pi.on("input", (event) => {
    if (/^\/skill:poteto-mode(?:\s|$)/.test(event.text)) {
      potetoMode = true;
      pi.appendEntry(MODE_ENTRY, { enabled: true });
    }
    return { action: "continue" } as const;
  });

  pi.on("before_agent_start", (event) => {
    const isPotetoSubagent = process.env.PI_SUBAGENT_AGENT === "poteto-agent";
    if (!potetoMode && !isPotetoSubagent) return;
    const skillPath = path.join(packageRoot(), "skills/poteto-mode/SKILL.md");
    if (isPotetoSubagent && !potetoMode) {
      return {
        systemPrompt: `${event.systemPrompt}\n\nYou are running as poteto-agent. Read the poteto-mode skill in full before any work, including its inline Principles index. The full skill is at ${skillPath}. Also read skill://poteto-mode via the read tool if available.`,
      };
    }
    return {
      systemPrompt: `${event.systemPrompt}\n\nPstack Poteto Mode is enabled for this session. Follow its persisted workflow: use pstack_todo for non-trivial work, select and read the matching playbook, delegate through the subagent tool (provided by omp-distill) when delegation helps, verify real behavior, and name only principles that changed a decision. The full skill is at ${skillPath}.`,
    };
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;
    const input = event.input as { command?: string };
    const operation = input.command ? knownExternalWrite(input.command) : undefined;
    if (!operation) return;
    if (!ctx.hasUI) return { block: true, reason: `${operation} requires explicit user confirmation; non-interactive Pi cannot request it.` };
    const approved = await ctx.ui.confirm("Confirm external or irreversible action", `Allow ${operation}?\n\n${input.command}`);
    if (!approved) return { block: true, reason: `User declined ${operation}.` };
  });

  pi.registerCommand("poteto-mode", {
    description: "Enable or disable sticky pstack Poteto Mode for this Pi session. Usage: /poteto-mode [task] | /poteto-mode off",
    handler: async (args, ctx) => {
      if (/^(off|disable|stop)$/i.test(args.trim())) {
        potetoMode = false;
        pi.appendEntry(MODE_ENTRY, { enabled: false });
        ctx.ui.setStatus("pstack-mode", undefined);
        ctx.ui.notify("Poteto Mode disabled for this session.", "info");
        return;
      }
      potetoMode = true;
      pi.appendEntry(MODE_ENTRY, { enabled: true });
      ctx.ui.setStatus("pstack-mode", "pstack: poteto mode");
      pi.sendUserMessage(`/skill:poteto-mode${args.trim() ? ` ${args.trim()}` : ""}`, { expandPromptTemplates: true });
    },
  });

  pi.registerCommand("setup-pstack", {
    description: "Interactively map pstack delegation roles to models available in Pi.",
    handler: async (_args, ctx) => {
      const config = await readConfig();
      const available = (ctx.scopedModels.length ? ctx.scopedModels.map((entry) => entry.model) : ctx.modelRegistry.getAvailable())
        .map((model) => `${model.provider}/${model.id}`);
      const choices = ["inherit-parent", ...new Set(available)];
      if (!ctx.hasUI) {
        await writeConfig(defaultConfig());
        return;
      }
      for (const role of ROLE_NAMES) {
        const current = config.roles[role];
        const selected = await ctx.ui.select(`Model for ${role}`, choices.map((model) => model === current ? `${model} (current)` : model));
        if (!selected) break;
        config.roles[role] = selected.replace(/ \(current\)$/, "");
      }
      await writeConfig(config);
      ctx.ui.notify(`Saved pstack model settings to ${configPath()}.`, "info");
    },
  });

  pi.registerTool({
    name: "pstack_todo",
    label: "Pstack Todo",
    description: "Maintain pstack's current task checklist. Use at the start of non-trivial multi-step work, then update it as work advances.",
    parameters: Type.Object({
      action: StringEnum(["get", "set", "add", "complete"] as const),
      items: Type.Optional(Type.Array(Type.String())),
      item: Type.Optional(Type.String()),
    }),
    async execute(_id, params) {
      if (params.action === "set") todos = params.items ?? [];
      if (params.action === "add" && params.item) todos = [...todos, params.item];
      if (params.action === "complete" && params.item) todos = todos.map((item) => item === params.item ? `[done] ${item}` : item);
      pi.appendEntry("pstack-todo", { items: todos });
      return { content: [{ type: "text", text: todos.length ? todos.map((item, index) => `${index + 1}. ${item}`).join("\n") : "No pstack todo items." }], details: { items: todos } };
    },
  });

  pi.registerTool({
    name: "pstack_sessions",
    label: "Pstack Sessions",
    description: "List Pi session files for the current working directory. Use before reading prior Pi transcripts; never glob other project session directories.",
    parameters: Type.Object({ action: StringEnum(["list"] as const) }),
    async execute(_id, _params, _signal, _update, ctx) {
      const sessions = await SessionManager.list(ctx.cwd);
      const files = sessions.map((session) => session.file);
      return { content: [{ type: "text", text: files.join("\n") || "No saved sessions for this working directory." }], details: { files } };
    },
  });

  pi.registerTool({
    name: "pstack_config",
    label: "Pstack Config",
    description: "Read or update pstack's role-to-model configuration. Use list-models before setting a model. inherit-parent makes a subagent use the parent session model.",
    parameters: Type.Object({
      action: StringEnum(["get", "list-models", "set"] as const),
      role: Type.Optional(Type.String()),
      model: Type.Optional(Type.String()),
      models: Type.Optional(Type.Array(Type.String(), { description: "Optional ordered model pool for a parallel review role." })),
    }),
    async execute(_id, params, _signal, _update, ctx) {
      if (params.action === "list-models") {
        const models = (ctx.scopedModels.length ? ctx.scopedModels.map((entry) => entry.model) : ctx.modelRegistry.getAvailable())
          .map((model) => `${model.provider}/${model.id}`);
        return { content: [{ type: "text", text: ["inherit-parent", ...models].join("\n") }], details: { models } };
      }
      const config = await readConfig();
      if (params.action === "set") {
        if (!params.role || (!params.model && !params.models?.length)) throw new Error("pstack_config set requires role plus model or models.");
        config.roles[params.role] = params.models?.length ? params.models : params.model!;
        await writeConfig(config);
      }
      return { content: [{ type: "text", text: JSON.stringify(config, null, 2) }], details: config };
    },
  });

  // subagent is provided by omp-distill — intentionally no duplicate registration here
}
