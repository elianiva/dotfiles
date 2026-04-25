import { Text } from "@mariozechner/pi-tui";
import type { Theme } from "@mariozechner/pi-coding-agent";
import type { CodemodeTrace, TraceStep } from "./types.js";

const truncate = (value: string, max: number): string => (value.length <= max ? value : `${value.slice(0, max - 1)}…`);

const formatDuration = (ms: number): string => {
  if (ms < 1000) return `${ms}ms`;
  return `${(ms / 1000).toFixed(ms < 10_000 ? 1 : 0)}s`;
};

const summarizeStep = (step: TraceStep): string => {
  if (step.error) return truncate(step.error, 80);
  if (!step.output?.text) return "";
  return truncate(step.output.text.split(/\r?\n/)[0] ?? "", 80);
};

export function renderCodemodeCall(code: string, theme: Theme): Text {
  const lines = code.trim().split(/\r?\n/);
  const suffix = lines.length > 1 ? theme.fg("muted", ` (${lines.length} lines)`) : "";
  const shown = lines.slice(0, 12).map((line) => theme.fg("accent", line)).join("\n");

  let content = `${theme.fg("toolTitle", theme.bold("codemode"))}${suffix}\n${shown}`;
  if (lines.length > 12) content += theme.fg("muted", `\n… (${lines.length - 12} more lines)`);

  return new Text(content, 0, 0);
}

export function renderCodemodeResult(trace: CodemodeTrace, expanded: boolean, theme: Theme): Text {
  const duration = trace.endedAt ? formatDuration(trace.endedAt - trace.startedAt) : "running";
  const isError = trace.status === "error" || trace.steps.some((step) => step.status === "error");
  const statusColor = isError ? "error" : trace.status === "ok" ? "success" : "accent";

  if (!expanded) {
    const lines: string[] = [
      `${theme.fg("toolTitle", theme.bold("codemode"))} ${theme.fg(statusColor, trace.status)} ${theme.fg("muted", duration)}`,
    ];

    for (const step of trace.steps) {
      const icon = step.status === "error" ? "✗" : step.status === "ok" ? "✓" : "○";
      const iconColor = step.status === "error" ? "error" : step.status === "ok" ? "success" : "muted";
      const summary = summarizeStep(step);
      lines.push(`${theme.fg(iconColor, icon)} ${step.label}${summary ? ` — ${theme.fg("muted", summary)}` : ""}`);
    }

    if (trace.value !== undefined) {
      const value = typeof trace.value === "string" ? trace.value : JSON.stringify(trace.value);
      lines.push(`→ ${theme.fg("success", truncate(value, 120))}`);
    }

    if (trace.error) lines.push(`→ ${theme.fg("error", truncate(trace.error, 120))}`);

    return new Text(lines.join("\n"), 0, 0);
  }

  const lines: string[] = [
    theme.fg("toolTitle", theme.bold("codemode execution")),
    `status: ${theme.fg(statusColor, trace.status)} · ${duration} · ${trace.steps.length} step${trace.steps.length === 1 ? "" : "s"}`,
    "",
    theme.fg("muted", "// executed code:"),
    ...trace.code.trim().split(/\r?\n/).map((line) => theme.fg("accent", line)),
  ];

  if (trace.steps.length > 0) {
    lines.push("", theme.bold("steps:"));
    for (const step of trace.steps) {
      const color = step.status === "error" ? "error" : step.status === "ok" ? "success" : "warning";
      lines.push(`${theme.fg(color, step.status === "error" ? "✗" : "✓")} ${step.label}`);
      lines.push(theme.fg("muted", `  input: ${truncate(typeof step.input === "string" ? step.input : JSON.stringify(step.input), 240)}`));
      if (step.output?.text) {
        for (const line of step.output.text.split(/\r?\n/).slice(0, 100)) lines.push(theme.fg("toolOutput", `  ${line}`));
      }
      if (step.error) lines.push(theme.fg("error", `  ${step.error}`));
    }
  }

  if (trace.logs.length > 0) {
    lines.push("", theme.bold(`logs (${trace.logs.length}):`));
    for (const log of trace.logs.slice(0, 200)) lines.push(theme.fg("muted", `  ${log}`));
    if (trace.logs.length > 200) lines.push(theme.fg("muted", `  … (${trace.logs.length - 200} more)`));
  }

  if (trace.value !== undefined) {
    lines.push("", theme.bold("result:"));
    const value = typeof trace.value === "string" ? trace.value : JSON.stringify(trace.value, null, 2);
    for (const line of value.split(/\r?\n/).slice(0, 200)) lines.push(theme.fg("success", line));
  }

  if (trace.error) {
    lines.push("", theme.bold("error:"), theme.fg("error", trace.error));
  }

  return new Text(lines.join("\n"), 0, 0);
}