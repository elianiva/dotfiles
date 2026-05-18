import type { Executor } from "@executor-js/sdk";
import { acquireSandbox, type SandboxDelegates } from "./sandbox-cache.js";
import { CodemodeTraceRecorder } from "./trace.js";
import type { ImageContent } from "@mariozechner/pi-ai";
import type { CodemodeTrace, ToolResultSnapshot } from "./types.js";

const DEFAULT_TIMEOUT_MS = 30_000;
const MAX_CODE_SIZE = 100_000;

type RuntimeOptions = {
  code: string;
  cwd: string;
  executor: Executor;
  timeoutMs?: number;
  signal?: AbortSignal;
  onUpdate?: () => void;
};

export type CodemodeExecutionResult = {
  value?: unknown;
  trace: CodemodeTrace;
  logs: string[];
};

const formatError = (cause: unknown): string => {
  if (cause instanceof Error) {
    const message = cause.message.trim();
    return message.length > 0 ? message : cause.name;
  }
  if (typeof cause === "string") return cause;
  if (typeof cause === "object" && cause !== null) {
    if ("message" in cause && typeof cause.message === "string") {
      const message = cause.message.trim();
      if (message.length > 0) return message;
    }
    try {
      return JSON.stringify(cause);
    } catch {
      return String(cause);
    }
  }
  return String(cause);
};

const isToolResult = (value: unknown): value is { content: unknown[] } =>
  typeof value === "object" &&
  value !== null &&
  "content" in value &&
  Array.isArray((value as { content?: unknown[] }).content);

const extractText = (value: unknown): string => {
  if (typeof value === "string") return value;
  if (typeof value === "undefined") return "";
  if (value === null) return "null";

  if (isToolResult(value)) {
    return value.content
      .filter(
        (entry): entry is { type?: unknown; text?: unknown } =>
          typeof entry === "object" && entry !== null,
      )
      .map((entry) => {
        if (entry.type === "text" && typeof entry.text === "string") return entry.text;
        return "";
      })
      .filter((line) => line.length > 0)
      .join(" ")
      .trim();
  }

  return "";
};

const extractImages = (value: unknown): ImageContent[] => {
  if (!isToolResult(value)) return [];
  return value.content.filter(
    (entry): entry is ImageContent =>
      typeof entry === "object" &&
      entry !== null &&
      (entry as Record<string, unknown>).type === "image" &&
      typeof (entry as Record<string, unknown>).data === "string" &&
      typeof (entry as Record<string, unknown>).mimeType === "string",
  );
};

const toSnapshot = (value: unknown, isError = false): ToolResultSnapshot => ({
  value,
  text: extractText(value),
  images: extractImages(value),
  isError,
});

const CODE_PREFIX = [
  '"use strict";',
  "",
  "const __invokeTool = SecureExec.bindings.invokeTool;",
  "const __emitLog = SecureExec.bindings.emitLog;",
  "const __emitResult = SecureExec.bindings.emitResult;",
  'const __formatArg = (value) => typeof value === "string" ? value : JSON.stringify(value);',
  'const __formatLine = (args) => args.map(__formatArg).join(" ");',
  "",
  "const __makeToolsProxy = (path = []) => new Proxy(() => undefined, {",
  "  get(_target, prop) {",
  '    if (prop === "then" || typeof prop === "symbol") return undefined;',
  "    return __makeToolsProxy([...path, String(prop)]);",
  "  },",
  "  apply(_target, _thisArg, args) {",
  '    const toolPath = path.join(".");',
  '    if (!toolPath) throw new Error("Tool path missing in invocation");',
  "    return Promise.resolve(__invokeTool(toolPath, args[0])).catch((err) => {",
  '      throw new Error(err?.error || err?.message || "Tool invocation failed");',
  "    });",
  "  },",
  "});",
  "const tools = __makeToolsProxy();",
  "",
  "const console = {",
  '  log: (...args) => __emitLog("log", __formatLine(args)),',
  '  warn: (...args) => __emitLog("warn", __formatLine(args)),',
  '  error: (...args) => __emitLog("error", __formatLine(args)),',
  '  info: (...args) => __emitLog("info", __formatLine(args)),',
  '  debug: (...args) => __emitLog("debug", __formatLine(args)),',
  "};",
  "",
  "(async () => {",
  "try {",
  "const value = await (async () => {",
].join("\n");

const CODE_POSTFIX = [
  "})();",
  "__emitResult(value);",
  "} catch (error) {",
  'const message = error && typeof error === "object" ? (error.stack || error.message || String(error)) : String(error);',
  'process.stderr.write(message + "\\n");',
  "process.exitCode = 1;",
  "}",
  "})();",
].join("\n");

const buildExecutionSource = (code: string): string =>
  CODE_PREFIX + "\n" + code + "\n" + CODE_POSTFIX;

const invokeExecutorApi = async (
  executor: Executor,
  path: string,
  args: unknown,
): Promise<{ handled: true; data: unknown } | { handled: false }> => {
  switch (path) {
    case "list":
    case "tools.list":
      return { handled: true, data: await executor.tools.list(args ?? {}) };
    case "schema":
    case "tools.schema":
      return { handled: true, data: await executor.tools.schema(String(args)) };
    case "definitions":
    case "tools.definitions":
      return { handled: true, data: await executor.tools.definitions() };

    case "sources.list":
      return { handled: true, data: await executor.sources.list() };
    case "sources.remove":
      return { handled: true, data: await executor.sources.remove(String(args)) };
    case "sources.refresh":
      return { handled: true, data: await executor.sources.refresh(String(args)) };
    case "sources.detect":
      return { handled: true, data: await executor.sources.detect(String(args)) };

    case "policies.list":
      return { handled: true, data: await executor.policies.list() };
    case "policies.add":
      return { handled: true, data: await executor.policies.add(args as any) };
    case "policies.remove":
      return { handled: true, data: await executor.policies.remove(String(args)) };

    case "secrets.list":
      return { handled: true, data: await executor.secrets.list() };
    case "secrets.resolve":
      return { handled: true, data: await executor.secrets.resolve(String(args)) };
    case "secrets.status":
      return { handled: true, data: await executor.secrets.status(String(args)) };
    case "secrets.set":
      return { handled: true, data: await executor.secrets.set(args as any) };
    case "secrets.remove":
      return { handled: true, data: await executor.secrets.remove(String(args)) };
    case "secrets.addProvider":
      return { handled: true, data: await executor.secrets.addProvider(args as any) };
    case "secrets.providers":
      return { handled: true, data: await executor.secrets.providers() };

    default:
      return { handled: false };
  }
};

// --- Tool invocation bridge (host side) ---
// Uses structured clone via secure-exec bindings — no JSON serialization.

const createInvokeTool =
  (executor: Executor, recorder: CodemodeTraceRecorder, onStep?: () => void) =>
    async (path: unknown, args: unknown): Promise<unknown> => {
      const toolPath = String(path);
      const step = recorder.startStep({ label: `tools.${toolPath}`, toolPath, input: args });

      try {
        const direct = await invokeExecutorApi(executor, toolPath, args);
        let data: unknown;

        if (direct.handled) {
          data = direct.data;
        } else {
          const invoked = await executor.tools.invoke(toolPath, args, {
            onElicitation: "accept-all",
          });
          if (invoked.error != null) {
            const message = formatError(invoked.error);
            recorder.finishStep(step, undefined, message);
            onStep?.();
            throw { error: message };
          }
          data = invoked.data;
        }

        const snapshot = toSnapshot(data);
        recorder.finishStep(step, snapshot);
        onStep?.();

        // pi and fff tools return ToolResult objects ({ content: [...] }) — extract text
        // for backwards compat. Other tools (MCP, OpenAPI, GraphQL) return objects as-is.
        if ((toolPath.startsWith("pi.") || toolPath.startsWith("fff.")) && isToolResult(data)) {
          return extractText(data);
        }
        return data;
      } catch (cause) {
        const message = formatError(cause);
        recorder.finishStep(step, undefined, message);
        onStep?.();
        throw { error: message };
      }
    };

// --- Sequential per-cwd execution queue ---

const executionQueues = new Map<string, Promise<unknown>>();

export const runCodemode = async (options: RuntimeOptions): Promise<CodemodeExecutionResult> => {
  const key = options.cwd;
  const prev = executionQueues.get(key);
  const next = (async (): Promise<CodemodeExecutionResult> => {
    if (prev) {
      try {
        await prev;
      } catch {
        /* ignore previous execution errors */
      }
    }
    return _runCodemode(options);
  })();
  executionQueues.set(key, next);
  try {
    return await next;
  } finally {
    if (executionQueues.get(key) === next) {
      executionQueues.delete(key);
    }
  }
};

// --- Core execution ---

const noopDelegates: SandboxDelegates = {
  invokeTool: async () => undefined,
  emitLog: () => { },
  emitResult: () => {},
};

const _runCodemode = async (options: RuntimeOptions): Promise<CodemodeExecutionResult> => {
  const code = options.code;
  const timeoutMs = Math.max(100, options.timeoutMs ?? DEFAULT_TIMEOUT_MS);
  const recorder = new CodemodeTraceRecorder({ cwd: options.cwd, code });
  const logs: string[] = [];

  if (code.length > MAX_CODE_SIZE) {
    const message = `Code exceeds ${MAX_CODE_SIZE} bytes`;
    const trace = recorder.finish({ status: "error", error: message });
    return { trace, logs };
  }

  const sandbox = await acquireSandbox(options.cwd);

  // Wire up delegates for this execution
  sandbox.delegates.invokeTool = createInvokeTool(options.executor, recorder, options.onUpdate);
  sandbox.delegates.emitResult = (value: unknown) => {
    capturedResult = value;
  };
  sandbox.delegates.emitLog = (level: unknown, line: unknown) => {
    const entry = `[${String(level)}] ${String(line)}`;
    logs.push(entry);
    recorder.log(entry);
  };

  let capturedResult: unknown = undefined;

  try {
    let aborted = false;
    let timedOut = false;

    const source = buildExecutionSource(code);

    const stdoutDecoder = new TextDecoder();
    const stderrDecoder = new TextDecoder();
    let stdout = "";
    let stderr = "";

    const proc = sandbox.kernel.spawn("node", ["-e", source], {
      cwd: options.cwd,
      onStdout: (data) => {
        stdout += stdoutDecoder.decode(data, { stream: true });
      },
      onStderr: (data) => {
        stderr += stderrDecoder.decode(data, { stream: true });
      },
    });

    const timeoutId = setTimeout(() => {
      timedOut = true;
      proc.kill(9);
    }, timeoutMs);

    let abortHandler: (() => void) | undefined;
    if (options.signal) {
      abortHandler = () => {
        aborted = true;
        proc.kill(9);
      };
      if (options.signal.aborted) abortHandler();
      else options.signal.addEventListener("abort", abortHandler, { once: true });
    }

    let exitCode: number;
    try {
      exitCode = await proc.wait();
    } finally {
      clearTimeout(timeoutId);
      if (options.signal && abortHandler) options.signal.removeEventListener("abort", abortHandler);
      stdout += stdoutDecoder.decode();
      stderr += stderrDecoder.decode();
    }

    const value = capturedResult;

    if (timedOut) {
      const trace = recorder.finish({
        status: "error",
        error: `Execution timed out after ${timeoutMs}ms`,
      });
      return { trace, logs };
    }

    if (aborted || options.signal?.aborted) {
      const trace = recorder.finish({ status: "aborted", value, error: "Execution aborted" });
      return { value, trace, logs };
    }

    if (exitCode !== 0) {
      const adjustedStderr = stderr.trim();
      const error = adjustedStderr || stdout.trim() || `Process exited with code ${exitCode}`;
      const trace = recorder.finish({ status: "error", value, error });
      return { value, trace, logs };
    }

    const trace = recorder.finish({ status: "ok", value });
    return { value, trace, logs };
  } catch (cause) {
    const message = formatError(cause);
    const trace = recorder.finish({
      status: options.signal?.aborted ? "aborted" : "error",
      error: message,
    });
    return { trace, logs };
  } finally {
    // Reset delegates to no-ops so next execution starts clean
    sandbox.delegates.invokeTool = noopDelegates.invokeTool;
    sandbox.delegates.emitLog = noopDelegates.emitLog;
    sandbox.delegates.emitResult = noopDelegates.emitResult;
  }
};
