import { createInMemoryFileSystem, createKernel, createNodeRuntime, type Kernel } from "secure-exec";

// Bound once into secure-exec. Mutable delegates allow per-execution handler swap
// without recreating the kernel.
export type SandboxDelegates = {
  invokeTool: (path: unknown, args: unknown) => Promise<unknown>;
  emitLog: (level: unknown, line: unknown) => void;
  emitResult: (value: unknown) => void;
};

export type SandboxEntry = {
  kernel: Kernel;
  delegates: SandboxDelegates;
};

const noopDelegates: SandboxDelegates = {
  invokeTool: async () => undefined,
  emitLog: () => {},
  emitResult: () => {},
};

const cache = new Map<string, SandboxEntry>();

export const acquireSandbox = async (cwd: string): Promise<SandboxEntry> => {
  const existing = cache.get(cwd);
  if (existing) return existing;

  const delegates: SandboxDelegates = { ...noopDelegates };

  // Fixed bindings that forward through mutable delegates
  const bindings = {
    invokeTool: (path: unknown, args: unknown) => delegates.invokeTool(path, args),
    emitLog: (level: unknown, line: unknown) => delegates.emitLog(level, line),
    emitResult: (value: unknown) => delegates.emitResult(value),
  };

  const kernel = createKernel({ filesystem: createInMemoryFileSystem(), cwd });
  await kernel.mount(createNodeRuntime({ bindings }));

  const entry: SandboxEntry = { kernel, delegates };
  cache.set(cwd, entry);
  return entry;
};

export const disposeAll = async (): Promise<void> => {
  await Promise.allSettled(
    Array.from(cache.values()).map((entry) => entry.kernel.dispose()),
  );
  cache.clear();
};