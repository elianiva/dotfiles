import { createExecutor, type Executor } from "@executor-js/sdk";
import { mcpPlugin } from "@executor-js/plugin-mcp";
import { openApiPlugin } from "@executor-js/plugin-openapi";
import { graphqlPlugin } from "@executor-js/plugin-graphql";
import { piPlugin } from "./pi-plugin.js";
import { fffPlugin } from "./fff-plugin.js";
import { loadSourcesFromConfig } from "./source-config.js";
import { hydrateExecutorSources } from "./source-hydrate.js";

type CachedExecutor = {
  executor: Executor;
  fingerprint: string;
};

const cache = new Map<string, CachedExecutor>();

export const getExecutor = async (cwd: string): Promise<Executor> => {
  const loaded = await loadSourcesFromConfig();
  const cached = cache.get(cwd);
  if (cached && cached.fingerprint === loaded.fingerprint) return cached.executor;

  if (cached) {
    await cached.executor.close();
    cache.delete(cwd);
  }

  const executor = await createExecutor({
    scope: { name: "pi-codemode-" + cwd },
    plugins: [piPlugin(cwd), fffPlugin(cwd), mcpPlugin(), openApiPlugin(), graphqlPlugin()] as const,
  });

  await hydrateExecutorSources(executor, loaded.sources, {
    configPath: loaded.configPath,
    unsupported: loaded.unsupported,
  });

  cache.set(cwd, { executor, fingerprint: loaded.fingerprint });
  return executor;
};

export const disposeExecutor = async (cwd: string): Promise<void> => {
  const cached = cache.get(cwd);
  if (!cached) return;
  await cached.executor.close();
  cache.delete(cwd);
};

export const disposeAllExecutors = async (): Promise<void> => {
  await Promise.allSettled(Array.from(cache.values()).map((entry) => entry.executor.close()));
  cache.clear();
};
