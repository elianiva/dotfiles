import type { Executor } from "@executor-js/sdk";
import type { SupportedSourceConfig, UnsupportedSourceConfig } from "./source-config.js";

type ExecutorWithPlugins = Executor & {
  mcp?: { addSource: (source: unknown) => Promise<unknown> };
  openapi?: { addSpec: (source: unknown) => Promise<unknown> };
  graphql?: { addSource: (source: unknown) => Promise<unknown> };
};

type HydrateOptions = {
  configPath: string;
  unsupported: UnsupportedSourceConfig[];
};

const sourceKey = (source: SupportedSourceConfig): string => {
  if (source.namespace) return source.kind + ":" + source.namespace;

  if (source.kind === "mcp") {
    if (source.transport === "remote") return "mcp:remote:" + source.endpoint;
    return "mcp:stdio:" + source.command + ":" + (source.args ?? []).join("\u0000") + ":" + (source.cwd ?? "");
  }

  if (source.kind === "openapi") return "openapi:" + source.spec;
  return "graphql:" + source.endpoint;
};

const summarize = (source: SupportedSourceConfig): string => {
  if (source.namespace) return source.kind + ":" + source.namespace;
  if (source.kind === "mcp") return source.transport === "remote" ? "mcp:" + source.endpoint : "mcp:" + source.command;
  if (source.kind === "openapi") return "openapi:" + source.spec;
  return "graphql:" + source.endpoint;
};

export const hydrateExecutorSources = async (
  executor: Executor,
  sources: SupportedSourceConfig[],
  options: HydrateOptions,
): Promise<void> => {
  if (options.unsupported.length > 0) {
    for (const entry of options.unsupported) {
      console.warn(
        "[codemode] Skipping unsupported source in " +
          options.configPath +
          " (#" +
          entry.index +
          "): " +
          entry.reason,
      );
    }
  }

  if (sources.length === 0) return;

  const ext = executor as ExecutorWithPlugins;
  const existing = await executor.sources.list();
  const existingIds = new Set(existing.map((source: { id: string }) => source.id));
  const seen = new Set<string>();

  for (const source of sources) {
    const key = sourceKey(source);
    if (seen.has(key)) continue;
    seen.add(key);

    if (source.namespace && existingIds.has(source.namespace)) continue;

    if (source.kind === "mcp") {
      if (!ext.mcp?.addSource) {
        throw new Error("Missing MCP plugin while hydrating " + summarize(source) + " from " + options.configPath);
      }
      await ext.mcp.addSource(source);
      continue;
    }

    if (source.kind === "openapi") {
      if (!ext.openapi?.addSpec) {
        throw new Error("Missing OpenAPI plugin while hydrating " + summarize(source) + " from " + options.configPath);
      }
      await ext.openapi.addSpec(source);
      continue;
    }

    if (!ext.graphql?.addSource) {
      throw new Error("Missing GraphQL plugin while hydrating " + summarize(source) + " from " + options.configPath);
    }
    await ext.graphql.addSource(source);
  }
};
