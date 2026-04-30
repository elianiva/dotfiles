import {
  definePlugin,
  ToolRegistration,
  ToolId,
  ToolInvocationResult,
  type PluginContext,
} from "@executor-js/sdk";
import { createBuiltinToolset } from "./builtins.js";
import { builtinToolNames, type BuiltinToolName } from "./types.js";
import { formatError } from "./util.js";

export const piPlugin = (cwd: string) =>
  definePlugin({
    key: "pi",
    init: async (ctx: PluginContext) => {
      const tools = createBuiltinToolset(cwd);

      await ctx.tools.registerInvoker("pi", {
        invoke: async (toolId: string, args: unknown) => {
          const name = toolId.split(".").pop() as BuiltinToolName | undefined;
          if (!name || !(name in tools)) {
            return new ToolInvocationResult({ data: null, error: `Unknown pi tool: ${toolId}` });
          }

          const tool = tools[name];
          try {
            const result = await tool.execute(toolId, args ?? {}, undefined, () => {});
            return new ToolInvocationResult({ data: result, error: null });
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