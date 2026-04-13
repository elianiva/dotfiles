import { createInMemoryFileSystem, createKernel, createNodeRuntime } from "secure-exec";
import type { Executor } from "@executor-js/sdk";
import { CodemodeTraceRecorder } from "./trace.js";
import type { CodemodeTrace, ToolResultSnapshot } from "./types.js";
import { stripCodeFences } from "./util.js";

const IPC_RESULT_PREFIX = "@@codemode-result@@";
const DEFAULT_TIMEOUT_MS = 30_000;
const MAX_CODE_SIZE = 100_000;

type RuntimeOptions = {
  code: string;
  cwd: string;
  executor: Executor;
  timeoutMs?: number;
  signal?: AbortSignal;
};

type ToolEnvelope =
  | { ok: true; value?: string }
  | { ok: false; error: string };

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

  if (typeof value === "object" && value !== null && "content" in value && Array.isArray((value as { content?: unknown[] }).content)) {
    const content = (value as { content: unknown[] }).content;
    return content
      .filter((entry): entry is { type?: unknown; text?: unknown } => typeof entry === "object" && entry !== null)
      .map((entry) => {
        if (entry.type === "text" && typeof entry.text === "string") return entry.text;
        try {
          return JSON.stringify(entry);
        } catch {
          return String(entry);
        }
      })
      .join("\n")
      .trim();
  }

  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
};

const toSnapshot = (value: unknown): ToolResultSnapshot => ({
  value,
  text: extractText(value),
  isError: false,
});

const parseResultFromStdout = (stdout: string): unknown => {
  for (const line of stdout.split("\n")) {
    if (!line.startsWith(IPC_RESULT_PREFIX)) continue;
    const payload = line.slice(IPC_RESULT_PREFIX.length);
    try {
      return JSON.parse(payload);
    } catch {
      return payload;
    }
  }
  return undefined;
};

const buildExecutionSource = (code: string): string => {
  const body = stripCodeFences(code);

  return `
"use strict";

const __invokeTool = SecureExec.bindings.invokeTool;
const __emitLog = SecureExec.bindings.emitLog;

const __formatArg = (value) => {
  if (typeof value === "string") return value;
  try { return JSON.stringify(value); } catch { return String(value); }
};
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
      return envelope.value === undefined ? undefined : JSON.parse(envelope.value);
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
    const value = await (async () => {
${body}
    })();
    if (value !== undefined) process.stdout.write(${JSON.stringify(IPC_RESULT_PREFIX)} + JSON.stringify(value) + "\\n");
  } catch (error) {
    const message = error && typeof error === "object" ? (error.stack || error.message || String(error)) : String(error);
    process.stderr.write(message + "\\n");
    process.exitCode = 1;
  }
})();
`.trim();
};

const createInvokeTool = (
  executor: Executor,
  recorder: CodemodeTraceRecorder,
) =>
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
      const result = await executor.tools.invoke(toolPath, args, { onElicitation: "accept-all" });

      if (result.error != null) {
        const message = formatError(result.error);
        recorder.finishStep(step, undefined, message);
        return encodeEnvelope({ ok: false, error: message });
      }

      const snapshot = toSnapshot(result.data);

      try {
        const encoded = encodeEnvelope({ ok: true, value: serializeJson(result.data) });
        recorder.finishStep(step, snapshot);
        return encoded;
      } catch (cause) {
        const message = `Result is not JSON serializable: ${formatError(cause)}`;
        recorder.finishStep(step, undefined, message);
        return encodeEnvelope({ ok: false, error: message });
      }
    } catch (cause) {
      const message = formatError(cause);
      recorder.finishStep(step, undefined, message);
      return encodeEnvelope({ ok: false, error: message });
    }
  };

export const runCodemode = async (options: RuntimeOptions): Promise<CodemodeExecutionResult> => {
  const code = stripCodeFences(options.code);
  const timeoutMs = Math.max(100, options.timeoutMs ?? DEFAULT_TIMEOUT_MS);
  const recorder = new CodemodeTraceRecorder({ cwd: options.cwd, code });
  const logs: string[] = [];

  if (code.length > MAX_CODE_SIZE) {
    const message = `Code exceeds ${MAX_CODE_SIZE} bytes`;
    const trace = recorder.finish({ status: "error", error: message });
    return { trace, logs };
  }

  const kernel = createKernel({ filesystem: createInMemoryFileSystem(), cwd: options.cwd });

  let aborted = false;
  let timedOut = false;

  try {
    await kernel.mount(
      createNodeRuntime({
        bindings: {
          invokeTool: createInvokeTool(options.executor, recorder),
          emitLog: (level: unknown, line: unknown) => {
            const entry = `[${String(level)}] ${String(line)}`;
            logs.push(entry);
            recorder.log(entry);
          },
        },
      }),
    );

    const stdoutDecoder = new TextDecoder();
    const stderrDecoder = new TextDecoder();
    let stdout = "";
    let stderr = "";

    const proc = kernel.spawn("node", ["-e", buildExecutionSource(code)], {
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

    const exitCode = await proc.wait();

    clearTimeout(timeoutId);
    if (options.signal && abortHandler) options.signal.removeEventListener("abort", abortHandler);

    stdout += stdoutDecoder.decode();
    stderr += stderrDecoder.decode();

    const value = parseResultFromStdout(stdout);

    if (timedOut) {
      const trace = recorder.finish({ status: "error", error: `Execution timed out after ${timeoutMs}ms` });
      return { trace, logs };
    }

    if (aborted || options.signal?.aborted) {
      const trace = recorder.finish({ status: "aborted", value, error: "Execution aborted" });
      return { value, trace, logs };
    }

    if (exitCode !== 0) {
      const error = stderr.trim() || stdout.trim() || `Process exited with code ${exitCode}`;
      const trace = recorder.finish({ status: "error", value, error });
      return { value, trace, logs };
    }

    const trace = recorder.finish({ status: "ok", value });
    return { value, trace, logs };
  } catch (cause) {
    const message = formatError(cause);
    const trace = recorder.finish({ status: options.signal?.aborted ? "aborted" : "error", error: message });
    return { trace, logs };
  } finally {
    await kernel.dispose();
  }
};
