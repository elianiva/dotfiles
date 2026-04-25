import type { Executor } from "@executor-js/sdk";
import { createInMemoryFileSystem, createKernel, createNodeRuntime, type Kernel } from "secure-exec";
import type { SandboxBindings } from "./sandbox-cache.js";
import { CodemodeTraceRecorder } from "./trace.js";
import type { CodemodeTrace, ToolResultSnapshot } from "./types.js";

const IPC_RESULT_PREFIX = "@@codemode-result@@";
const DEFAULT_TIMEOUT_MS = 30_000;
const MAX_CODE_SIZE = 100_000;
const SANDBOX_ENTRY_PATH = "/entry.mjs";

type RuntimeOptions = {
  code: string;
  cwd: string;
  executor: Executor;
  timeoutMs?: number;
  signal?: AbortSignal;
};

type ToolEnvelope = { ok: true; value?: string; text?: string } | { ok: false; error: string };

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

const serializeJson = (value: unknown): string | undefined => {
  if (typeof value === "undefined") return undefined;
  return JSON.stringify(value);
};

const encodeEnvelope = (value: ToolEnvelope): string => {
  try {
    return JSON.stringify(value);
  } catch (cause) {
    return JSON.stringify({ ok: false, error: formatError(cause) } satisfies ToolEnvelope);
  }
};

const extractText = (value: unknown): string => {
  if (typeof value === "string") return value;
  if (typeof value === "undefined") return "";
  if (value === null) return "null";

  if (
    typeof value === "object" &&
    value !== null &&
    "content" in value &&
    Array.isArray((value as { content?: unknown[] }).content)
  ) {
    const content = (value as { content: unknown[] }).content;
    return content
      .filter((entry): entry is { type?: unknown; text?: unknown } => typeof entry === "object" && entry !== null)
      .map((entry) => {
        if (entry.type === "text" && typeof entry.text === "string") return entry.text;
        return "";
      })
      .filter((line) => line.length > 0)
      .join("\n")
      .trim();
  }

  return "";
};

const toSnapshot = (value: unknown, isError = false): ToolResultSnapshot => ({
  value,
  text: extractText(value),
  isError,
});

const parseResultFromStdout = (stdout: string): unknown => {
  for (const line of stdout.split("\n")) {
    if (!line?.startsWith(IPC_RESULT_PREFIX)) continue;
    const payload = line.slice(IPC_RESULT_PREFIX.length);
    try {
      return JSON.parse(payload);
    } catch {
      return payload;
    }
  }
  return undefined;
};

const buildExecutionSource = (code: string): { source: string; bodyOffset: number } => {
  const preamble = `"use strict";

const __invokeTool = SecureExec.bindings.invokeTool;
const __emitLog = SecureExec.bindings.emitLog;
const __formatArg = (value) => typeof value === "string" ? value : JSON.stringify(value);
const __formatLine = (args) => args.map(__formatArg).join(" ");

const __makeToolsProxy = (path = []) => new Proxy(() => undefined, {
  get(_target, prop) {
    if (prop === "then" || typeof prop === "symbol") return undefined;
    return __makeToolsProxy([...path, String(prop)]);
  },
  apply(_target, _thisArg, args) {
    const toolPath = path.join(".");
    if (!toolPath) throw new Error("Tool path missing in invocation");
    const argsJson = args[0] !== undefined ? JSON.stringify(args[0]) : undefined;
    return Promise.resolve(__invokeTool(toolPath, argsJson)).then((raw) => {
      const envelope = JSON.parse(raw);
      if (!envelope.ok) throw new Error(envelope.error || "Tool invocation failed");
      if (envelope.value !== undefined) return JSON.parse(envelope.value);
      if (typeof envelope.text === "string" && envelope.text.trim().length > 0) return envelope.text;
      return undefined;
    });
  },
});
const tools = __makeToolsProxy();

const console = {
  log: (...args) => __emitLog("log", __formatLine(args)),
  warn: (...args) => __emitLog("warn", __formatLine(args)),
  error: (...args) => __emitLog("error", __formatLine(args)),
  info: (...args) => __emitLog("info", __formatLine(args)),
  debug: (...args) => __emitLog("debug", __formatLine(args)),
};

(async () => {
try {
const value = await (async () => {`;

  const postamble = `})();
if (value !== undefined) process.stdout.write(${JSON.stringify(IPC_RESULT_PREFIX)} + JSON.stringify(value) + "\\n");
} catch (error) {
const message = error && typeof error === "object" ? (error.stack || error.message || String(error)) : String(error);
process.stderr.write(message + "\\n");
process.exitCode = 1;
}
})();`;

  const source = preamble + "\n" + code + "\n" + postamble;
  const bodyOffset = preamble.split("\n").length + 1;
  return { source, bodyOffset };
};

const adjustLineNumbers = (stderr: string, offset: number): string => {
  const escapedPath = SANDBOX_ENTRY_PATH.replace(/\//g, "\\/");
  const pattern1 = new RegExp("^(.*" + escapedPath + ")(:)(\\d+)(:\d+)?(.*)?$");
  const pattern2 = new RegExp("^(.*)(" + escapedPath + ":)(\\d+)(:\d+)(.*)$");

  const lines = stderr.split("\n");
  const result: string[] = [];
  for (const line of lines) {
    const match = line.match(pattern1);
    if (match) {
      const adj = Math.max(1, Number(match[3]) - offset);
      result.push(`${match[1]}${match[2]}${adj}${match[4] ?? ""}${match[5] ?? ""}`);
      continue;
    }
    const inline = line.match(pattern2);
    if (inline) {
      const adj = Math.max(1, Number(inline[3]) - offset);
      result.push(`${inline[1]}${inline[2]}${adj}${inline[4]}${inline[5]}`);
      continue;
    }
    result.push(line);
  }
  return result.join("\n");
};

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

const createInvokeTool =
  (executor: Executor, recorder: CodemodeTraceRecorder) =>
    async (path: unknown, argsJson: unknown): Promise<string> => {
      const toolPath = String(path);
      let args: unknown;

      try {
        args = typeof argsJson === "string" ? JSON.parse(argsJson) : undefined;
      } catch (cause) {
        const message = `Invalid JSON args: ${formatError(cause)}`;
        const step = recorder.startStep({ label: `tools.${toolPath}`, toolPath, input: argsJson });
        recorder.finishStep(step, undefined, message);
        return encodeEnvelope({ ok: false, error: message });
      }

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
            return encodeEnvelope({ ok: false, error: message });
          }
          data = invoked.data;
        }

        const snapshot = toSnapshot(data);
        const encoded = encodeEnvelope({ ok: true, value: serializeJson(data), text: snapshot.text });
        recorder.finishStep(step, snapshot);
        return encoded;
      } catch (cause) {
        const message = formatError(cause);
        recorder.finishStep(step, undefined, message);
        return encodeEnvelope({ ok: false, error: message });
      }
    };

const withSandbox = async <T>(
  cwd: string,
  fn: (kernel: Kernel, bindings: SandboxBindings) => Promise<T>,
): Promise<T> => {
  const kernel = createKernel({ filesystem: createInMemoryFileSystem(), cwd });
  const bindings: SandboxBindings = {
    invokeTool: async () => "",
    emitLog: () => {},
  };
  await kernel.mount(createNodeRuntime({ bindings }));
  try {
    return await fn(kernel, bindings);
  } finally {
    await kernel.dispose().catch(() => {});
  }
};

const executionQueues = new Map<string, Promise<unknown>>();

export const runCodemode = async (options: RuntimeOptions): Promise<CodemodeExecutionResult> => {
  const key = options.cwd;
  const prev = executionQueues.get(key);
  const next = (async (): Promise<CodemodeExecutionResult> => {
    if (prev) {
      try { await prev; } catch { /* ignore previous execution errors */ }
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

  let aborted = false;
  let timedOut = false;

  return withSandbox(options.cwd, async (kernel, bindings) => {
    bindings.invokeTool = createInvokeTool(options.executor, recorder);
    bindings.emitLog = (level: unknown, line: unknown) => {
      const entry = `[${String(level)}] ${String(line)}`;
      logs.push(entry);
      recorder.log(entry);
    };

    const { source, bodyOffset } = buildExecutionSource(code);

    const stdoutDecoder = new TextDecoder();
    const stderrDecoder = new TextDecoder();
    let stdout = "";
    let stderr = "";

    const proc = kernel.spawn("node", ["-e", source], {
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

    const value = parseResultFromStdout(stdout);

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
      const adjustedStderr = adjustLineNumbers(stderr.trim(), bodyOffset);
      const error = adjustedStderr || stdout.trim() || `Process exited with code ${exitCode}`;
      const trace = recorder.finish({ status: "error", value, error });
      return { value, trace, logs };
    }

    const trace = recorder.finish({ status: "ok", value });
    return { value, trace, logs };
  }).catch((cause) => {
    const message = formatError(cause);
    const trace = recorder.finish({
      status: options.signal?.aborted ? "aborted" : "error",
      error: message,
    });
    return { trace, logs };
  });
};