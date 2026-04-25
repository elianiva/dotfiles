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

const isTextContent = (item: unknown): item is { type: "text"; text: string } =>
  typeof item === "object" &&
  item !== null &&
  (item as Record<string, unknown>).type === "text" &&
  typeof (item as Record<string, unknown>).text === "string";

const unwrapTextResult = (data: unknown): unknown => {
  if (
    typeof data === "object" &&
    data !== null &&
    "content" in data &&
    Array.isArray((data as { content?: unknown[] }).content)
  ) {
    const first = (data as { content: unknown[] }).content.find(isTextContent);
    if (first) return first.text;
  }
  return data;
};

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
            const data = unwrapTextResult(result);
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