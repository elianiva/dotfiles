import {
  definePlugin,
  ToolRegistration,
  ToolId,
  ToolInvocationResult,
  type PluginContext,
} from "@executor-js/sdk";
import { spawn } from "node:child_process";
import { formatError } from "./util.js";

const run = async (args: string[], cwd: string, signal?: AbortSignal) =>
  await new Promise((resolve, reject) => {
    const child = spawn("jj", args, { cwd, signal, stdio: ["ignore", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (d) => (stdout += d.toString()));
    child.stderr.on("data", (d) => (stderr += d.toString()));
    child.on("error", reject);
    child.on("close", (code) =>
      resolve({ code: code ?? 0, stdout, stderr, command: ["jj", ...args] }),
    );
  });
const summarize = (r: any) =>
  [
    "$ " + r.command.join(" "),
    r.stdout?.trim(),
    r.stderr?.trim() ? "stderr: " + r.stderr.trim() : "",
    "exit " + r.code,
  ]
    .filter(Boolean)
    .join(" ");
const text = (s: string) => [{ type: "text", text: s }];

export const jjPlugin = (cwd: string) =>
  definePlugin({
    key: "jj",
    init: async (ctx: PluginContext) => {
      const tools = {
        status: {
          description: "Show jj status",
          parameters: { type: "object", properties: {}, additionalProperties: false },
          execute: async () => {
            const r = await run(["status"], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        diff: {
          description: "Show jj diff",
          parameters: { type: "object", properties: {}, additionalProperties: false },
          execute: async () => {
            const r = await run(["diff"], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        log: {
          description: "Show jj log",
          parameters: { type: "object", properties: {}, additionalProperties: false },
          execute: async () => {
            const r = await run(["log"], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        new: {
          description: "Create a new jj change",
          parameters: { type: "object", properties: {}, additionalProperties: false },
          execute: async () => {
            const r = await run(["new"], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        describe: {
          description: "Describe the current jj change",
          parameters: {
            type: "object",
            properties: { description: { type: "string" } },
            required: ["description"],
            additionalProperties: false,
          },
          execute: async (_id: string, args: any) => {
            const description = String(args?.description ?? "");
            if (!description) throw new Error("Missing description");
            const r = await run(["describe", "-m", description], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        commit: {
          description: "Commit with jj",
          parameters: {
            type: "object",
            properties: { message: { type: "string" } },
            required: ["message"],
            additionalProperties: false,
          },
          execute: async (_id: string, args: any) => {
            const message = String(args?.message ?? "");
            if (!message) throw new Error("Missing message");
            const r = await run(["commit", "-m", message], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
      } as const;
      await ctx.tools.registerInvoker("jj", {
        invoke: async (toolId: string, args: unknown) => {
          const name = toolId.split(".").pop() as keyof typeof tools | undefined;
          if (!name || !(name in tools))
            return new ToolInvocationResult({ data: null, error: "Unknown jj tool: " + toolId });
          try {
            return new ToolInvocationResult({
              data: await tools[name].execute(toolId, args ?? {}),
              error: null,
            });
          } catch (cause) {
            return new ToolInvocationResult({ data: null, error: formatError(cause) });
          }
        },
      });
      await ctx.tools.register(
        Object.entries(tools).map(
          ([name, tool]) =>
            new ToolRegistration({
              id: ToolId.make("jj." + name),
              pluginKey: "jj",
              sourceId: "pi",
              name,
              description: tool.description,
              inputSchema: tool.parameters as Record<string, unknown>,
            }),
        ),
      );
      return { extension: {} };
    },
  });
