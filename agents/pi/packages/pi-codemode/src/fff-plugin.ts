import {
  definePlugin,
  ToolRegistration,
  ToolId,
  ToolInvocationResult,
  type PluginContext,
} from "@executor-js/sdk";
import { createFffBuiltinToolset, initFinder } from "./fff.js";
import { fffToolNames, type FffToolName } from "./types.js";
import { formatError } from "./util.js";

export const fffPlugin = (cwd: string) =>
  definePlugin({
    key: "fff",
    init: async (ctx: PluginContext) => {
      // Eagerly initialize finder on plugin load
      await initFinder(cwd);

      const tools = createFffBuiltinToolset(cwd);

      // Register fff.* SIMD-accelerated search tools
      await ctx.tools.registerInvoker("fff", {
        invoke: async (toolId: string, args: unknown, _options: unknown) => {
          const name = toolId.split(".").pop() as FffToolName | undefined;
          if (!name || !(name in tools)) {
            return new ToolInvocationResult({ data: null, error: "Unknown fff tool: " + toolId });
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
        fffToolNames.map((name) => {
          const tool = tools[name];
          return new ToolRegistration({
            id: ToolId.make("fff." + name),
            pluginKey: "fff",
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