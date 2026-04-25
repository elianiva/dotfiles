import { createInMemoryFileSystem, createKernel, createNodeRuntime, type Kernel } from "secure-exec";

export type SandboxBindings = {
  invokeTool: (path: unknown, argsJson: unknown) => Promise<string>;
  emitLog: (level: unknown, line: unknown) => void;
};

export type SandboxEntry = {
  kernel: Kernel;
  bindings: SandboxBindings;
};

export const createSandbox = async (cwd: string): Promise<SandboxEntry> => {
  const kernel = createKernel({ filesystem: createInMemoryFileSystem(), cwd });
  const bindings: SandboxBindings = {
    invokeTool: async () => "",
    emitLog: () => {},
  };
  await kernel.mount(createNodeRuntime({ bindings }));
  return { kernel, bindings };
};

export const disposeSandbox = async (entry: SandboxEntry): Promise<void> => {
  await entry.kernel.dispose();
};