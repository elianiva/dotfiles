import { createExecutor, type Executor } from "@executor-js/sdk";
import { piPlugin } from "./pi-plugin.js";

const cache = new Map<string, Executor>();

export const getExecutor = async (cwd: string): Promise<Executor> => {
  const cached = cache.get(cwd);
  if (cached) return cached;

  const executor = await createExecutor({
    scope: { name: `pi-codemode-${cwd}` },
    plugins: [piPlugin(cwd)] as const,
  });

  cache.set(cwd, executor);
  return executor;
};

export const disposeExecutor = async (cwd: string): Promise<void> => {
  const executor = cache.get(cwd);
  if (!executor) return;
  await executor.close();
  cache.delete(cwd);
};

export const disposeAllExecutors = async (): Promise<void> => {
  await Promise.all(Array.from(cache.values()).map((executor) => executor.close()));
  cache.clear();
};
