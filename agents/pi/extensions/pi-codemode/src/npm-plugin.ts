import {
  definePlugin,
  ToolRegistration,
  ToolId,
  ToolInvocationResult,
  type PluginContext,
} from "@executor-js/sdk";
import { spawn } from "node:child_process";
import { promises as fs } from "node:fs";
import { join } from "node:path";
import { formatError } from "./util.js";

const readMaybe = async (path: string) => {
  try {
    return await fs.readFile(path, "utf8");
  } catch {
    return null;
  }
};

const pmCache = new Map<string, { bin: string; args: readonly string[] }>();

const detectPackageManager = async (cwd: string) => {
  const cached = pmCache.get(cwd);
  if (cached) return cached;

  let result: { bin: string; args: readonly string[] };
  if ((await readMaybe(join(cwd, "pnpm-lock.yaml"))) !== null)
    result = { bin: "pnpm", args: ["add"] as const };
  else if ((await readMaybe(join(cwd, "bun.lockb"))) !== null)
    result = { bin: "bun", args: ["add"] as const };
  else if ((await readMaybe(join(cwd, "bun.lock"))) !== null)
    result = { bin: "bun", args: ["add"] as const };
  else if ((await readMaybe(join(cwd, "package-lock.json"))) !== null)
    result = { bin: "npm", args: ["install"] as const };
  else
    result = { bin: "npm", args: ["install"] as const };

  pmCache.set(cwd, result);
  return result;
};

const run = async (cmd: string, args: string[], cwd: string, signal?: AbortSignal) =>
  await new Promise((resolve, reject) => {
    const child = spawn(cmd, args, { cwd, signal, stdio: ["ignore", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (d) => (stdout += d.toString()));
    child.stderr.on("data", (d) => (stderr += d.toString()));
    child.on("error", reject);
    child.on("close", (code) =>
      resolve({ code: code ?? 0, stdout, stderr, command: [cmd, ...args] }),
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

export const npmPlugin = (cwd: string) =>
  definePlugin({
    key: "npm",
    init: async (ctx: PluginContext) => {
      const tools = {
        run: {
          description: "Run npm scripts",
          parameters: {
            type: "object",
            properties: { name: { type: "string" } },
            required: ["name"],
            additionalProperties: false,
          },
          execute: async (_id: string, args: any) => {
            const name = String(args?.name ?? "");
            if (!name) throw new Error("Missing script name");
            const r = await run("npm", ["run", name], cwd);
            return { content: text(summarize(r)), details: { result: r } };
          },
        },
        install: {
          description: "Install packages with lockfile-aware package manager",
          parameters: {
            type: "object",
            properties: { packages: { type: "array", items: { type: "string" } } },
            required: ["packages"],
            additionalProperties: false,
          },
          execute: async (_id: string, args: any) => {
            const packages = Array.isArray(args?.packages)
              ? args.packages.map(String).filter(Boolean)
              : [];
            if (!packages.length) throw new Error("Missing packages");
            const pm = await detectPackageManager(cwd);
            const r = await run(pm.bin, [...pm.args, ...packages], cwd);
            return { content: text(summarize(r)), details: { result: r, packageManager: pm.bin } };
          },
        },
      } as const;
      await ctx.tools.registerInvoker("npm", {
        invoke: async (toolId: string, args: unknown) => {
          const name = toolId.split(".").pop() as keyof typeof tools | undefined;
          if (!name || !(name in tools))
            return new ToolInvocationResult({ data: null, error: "Unknown npm tool: " + toolId });
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
              id: ToolId.make("npm." + name),
              pluginKey: "npm",
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