import {
  definePlugin,
  ToolRegistration,
  ToolId,
  ToolInvocationResult,
  type PluginContext,
} from "@executor-js/sdk";
import { createBuiltinToolset } from "./builtins.js";
import { builtinToolNames, type BuiltinToolName } from "./types.js";

const formatError = (cause: unknown): string => {
  if (cause instanceof Error) return cause.message || cause.name;
  if (typeof cause === "string") return cause;
  try {
    return JSON.stringify(cause);
  } catch {
    return String(cause);
  }
};

export const piPlugin = (cwd: string) =>
  definePlugin({
    key: "pi",
    init: async (ctx: PluginContext) => {
      const tools = createBuiltinToolset(cwd);

      await ctx.tools.registerInvoker("pi", {
        invoke: async (toolId, args) => {
          const name = toolId.split(".").pop() as BuiltinToolName | undefined;
          if (!name || !(name in tools)) {
            return new ToolInvocationResult({ data: null, error: `Unknown pi tool: ${toolId}` });
          }

          const tool = tools[name];
          try {
            const data = await tool.execute(toolId, args ?? {}, undefined, () => {});
            return new ToolInvocationResult({ data, error: null });
          } catch (cause) {
            return new ToolInvocationResult({ data: null, error: formatError(cause) });
          }
        },
      });

      await ctx.tools.register(
        builtinToolNames.map((name) => {
          const tool = tools[name];
          return new ToolRegistration({
            id: ToolId.make(`pi.${name}`),
            pluginKey: "pi",
            sourceId: "pi",
            name,
            description: tool.description,
            inputSchema: tool.parameters as Record<string, unknown>,
          });
        }),
      );

      return { extension: {} };
    },
  });
