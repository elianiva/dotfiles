import type { ImageContent } from "@mariozechner/pi-ai";
import type { CodemodeTrace, ToolResultSnapshot, TraceStep } from "./types.js";

const clone = <T>(value: T): T => {
  if (typeof structuredClone === "function") return structuredClone(value);
  return JSON.parse(JSON.stringify(value)) as T;
};

const formatDuration = (ms: number): string => {
  if (ms < 1000) return `${ms}ms`;
  return `${(ms / 1000).toFixed(ms < 10_000 ? 1 : 0)}s`;
};

const summarizeText = (text: string, max = 140): string => {
  const first = text.split(/\r?\n/).find((line) => line.trim().length > 0) ?? "";
  if (first.length <= max) return first;
  return `${first.slice(0, max - 1)}…`;
};

const summarizeValue = (value: unknown): string => {
  if (value === undefined) return "undefined";
  if (value === null) return "null";
  if (typeof value === "string") return JSON.stringify(value.length > 80 ? `${value.slice(0, 77)}…` : value);
  if (typeof value === "number" || typeof value === "boolean") return String(value);
  if (Array.isArray(value)) return `[${value.length} items]`;
  if (typeof value === "object") return `{${Object.keys(value as Record<string, unknown>).slice(0, 4).join(", ")}}`;
  return String(value);
};

export class CodemodeTraceRecorder {
  private readonly trace: CodemodeTrace;
  private readonly steps = new Map<string, TraceStep>();
  private id = 0;

  constructor(input: { cwd: string; code: string }) {
    this.trace = {
      cwd: input.cwd,
      code: input.code,
      startedAt: Date.now(),
      status: "running",
      logs: [],
      steps: [],
    };
  }

  log(line: string): void {
    this.trace.logs.push(line);
  }

  startStep(input: { label: string; toolPath: string; input: unknown }): string {
    const id = `step_${++this.id}`;
    const step: TraceStep = {
      id,
      label: input.label,
      toolPath: input.toolPath,
      input: clone(input.input),
      startedAt: Date.now(),
      status: "running",
    };
    this.steps.set(id, step);
    this.trace.steps.push(step);
    return id;
  }

  finishStep(id: string, output?: ToolResultSnapshot, error?: string): void {
    const step = this.steps.get(id);
    if (!step) return;
    step.endedAt = Date.now();

    if (error) {
      step.status = "error";
      step.error = error;
      return;
    }

    if (output) {
      step.output = clone(output);
      step.status = output.isError ? "error" : "ok";
      if (output.isError) step.error = output.text;
      return;
    }

    step.status = "ok";
  }

  finish(input: { status: CodemodeTrace["status"]; value?: unknown; error?: string }): CodemodeTrace {
    this.trace.endedAt = Date.now();
    this.trace.status = input.status;
    this.trace.value = input.value;
    this.trace.error = input.error;
    return clone(this.trace);
  }
}

export const summarizeTraceForContext = (trace: CodemodeTrace): string => {
  const duration = trace.endedAt ? formatDuration(trace.endedAt - trace.startedAt) : undefined;
  const errors = trace.steps.filter((s) => s.status === "error").length;

  return [
    `codemode ${trace.status}`,
    duration,
    `${trace.steps.length} step${trace.steps.length === 1 ? "" : "s"}`,
    errors > 0 ? `${errors} err` : undefined,
    trace.logs.length > 0 ? `${trace.logs.length} log${trace.logs.length === 1 ? "" : "s"}` : undefined,
    trace.value !== undefined ? `value=${summarizeValue(trace.value)}` : undefined,
    trace.error ? `error=${summarizeText(trace.error, 120)}` : undefined,
  ]
    .filter((v): v is string => Boolean(v))
    .join(" · ");
};

export const formatTraceForAgent = (trace: CodemodeTrace, value: unknown, logs: string[]): { text: string; images: ImageContent[] } => {
  const durationMs = trace.endedAt ? trace.endedAt - trace.startedAt : 0;
  const duration = formatDuration(durationMs);

  const result: string[] = [`status:${trace.status} duration:${duration}`];

  if (trace.steps.length > 0) {
    result.push("", "steps:");
    for (const step of trace.steps) {
      const stepDuration = step.endedAt ? formatDuration(step.endedAt - step.startedAt) : "";
      const prefix = step.status === "error" ? "[ERR]" : step.status === "ok" ? "[OK]" : "[...]";
      result.push(`${prefix} ${step.label} ${stepDuration}`);
      if (step.error) {
        result.push(`  error: ${step.error}`);
      } else if (step.output?.text) {
        const lines = step.output.text.split(/\r?\n/).filter((l) => l.trim().length > 0);
        const preview = lines.slice(0, 8).join("\n  ");
        result.push(`  output: ${preview}${lines.length > 8 ? `\n  ... (${lines.length - 8} more lines)` : ""}`);
      }
    }
  }

  if (trace.error) {
    result.push("", `execution error: ${trace.error}`);
  }

  if (value !== undefined) {
    const raw = typeof value === "string" ? value : JSON.stringify(value);
    result.push("", `return value: ${raw}`);
  }

  if (logs.length > 0) {
    result.push("", "logs:");
    for (const log of logs) {
      result.push(log.replace(/^\[\w+\] /, ""));
    }
  }

  const images = trace.steps.flatMap((s) => s.output?.images ?? []);

  return { text: result.join("\n"), images };
};
