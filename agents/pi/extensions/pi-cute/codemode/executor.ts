import { Text } from "@mariozechner/pi-tui";
import { NodeRuntime } from "@secure-exec/core";
import { createNodeDriver, createNodeRuntimeDriverFactory } from "@secure-exec/node";
import type { Static } from "@sinclair/typebox";
import { exec, mkdir, readFile, writeFile } from "./host-tools.js";
import { startRpcServer } from "./rpc-server.js";
import { buildSandboxCode } from "./sandbox.js";
import { runSchema, type CodemodeResult, type OperationLog } from "./types.js";
import type { Theme } from "@mariozechner/pi-coding-agent";
import { resolve } from "node:path";

export function createRunTool(cwd: string) {
  return {
    name: "run",
    label: "run",
    description: "Execute JS with pi.tools API",
    parameters: runSchema,

    async execute(_toolCallId: string, args: Static<typeof runSchema>, signal?: AbortSignal) {
      const operations: OperationLog[] = [];
      const filesModified = new Set<string>();
      const consoleLogs: string[] = [];

      const runtime = new NodeRuntime({
        systemDriver: createNodeDriver({ permissions: { network: () => ({ allow: true }) } }),
        runtimeDriverFactory: createNodeRuntimeDriverFactory(),
        memoryLimit: 128,
        cpuTimeLimitMs: 30000,
      });

      const { server, port } = await startRpcServer({
        read: async (input) => {
          const start = Date.now();
          try {
            const result = await readFile(resolve(cwd, input.path as string), "utf-8");
            operations.push({ op: "read", input, duration_ms: Date.now() - start, success: true, output: result.slice(0, 1000) });
            return result;
          } catch (e) {
            operations.push({ op: "read", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
        write: async (input) => {
          const start = Date.now();
          try {
            const fullPath = resolve(cwd, input.path as string);
            await mkdir(resolve(fullPath, ".."), { recursive: true });
            await writeFile(fullPath, input.content as string);
            filesModified.add(input.path as string);
            operations.push({ op: "write", input, duration_ms: Date.now() - start, success: true, output: (input.content as string).length });
            return (input.content as string).length;
          } catch (e) {
            operations.push({ op: "write", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
        edit: async (input) => {
          const start = Date.now();
          try {
            const fullPath = resolve(cwd, input.path as string);
            let content = await readFile(fullPath, "utf-8");
            if (!content.includes(input.oldText as string)) throw new Error("Old text not found");
            content = content.replace(input.oldText as string, input.newText as string);
            await writeFile(fullPath, content);
            filesModified.add(input.path as string);
            operations.push({ op: "edit", input, duration_ms: Date.now() - start, success: true, output: "updated" });
            return "updated";
          } catch (e) {
            operations.push({ op: "edit", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
        bash: async (input) => {
          const start = Date.now();
          try {
            const result = await exec(input.command as string, cwd);
            operations.push({ op: "bash", input, duration_ms: Date.now() - start, success: true, output: result.slice(0, 500) });
            return result;
          } catch (e) {
            operations.push({ op: "bash", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
        find: async (input) => {
          const start = Date.now();
          try {
            const result = await exec(`find . -name "${(input.pattern as string).replace(/"/g, '\\"')}" -type f 2>/dev/null | head -50`, cwd);
            const files = result.split("\n").filter(f => f.trim());
            operations.push({ op: "find", input, duration_ms: Date.now() - start, success: true, output: files.length });
            return files;
          } catch (e) {
            operations.push({ op: "find", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
        ls: async (input) => {
          const start = Date.now();
          try {
            const cmd = input.path === "." ? "ls -1" : `ls -1 "${(input.path as string).replace(/"/g, '\\"')}"`;
            const result = await exec(cmd, cwd);
            const entries = result.split("\n").filter(f => f.trim());
            operations.push({ op: "ls", input, duration_ms: Date.now() - start, success: true, output: entries.length });
            return entries;
          } catch (e) {
            operations.push({ op: "ls", input, duration_ms: Date.now() - start, success: false, error: String(e) });
            throw e;
          }
        },
      });

      try {
        const sandboxCode = buildSandboxCode(args.code, port);

        let resultJson: string | undefined;
        let errorMsg: string | undefined;

        const execResult = await runtime.exec(sandboxCode, {
          onStdio: ({ channel, message }) => {
            if (channel === "stdout" && message.startsWith("__RESULT__")) {
              resultJson = message.slice("__RESULT__".length);
            } else if (channel === "stderr" && message.startsWith("__ERROR__")) {
              errorMsg = message.slice("__ERROR__".length);
            } else {
              consoleLogs.push(message);
            }
          },
        });

        server.close();
        runtime.dispose();

        if (signal?.aborted) {
          return { content: [{ type: "text" as const, text: "Aborted" }], details: { operations, filesModified: Array.from(filesModified), summary: buildSummary(operations), consoleOutput: consoleLogs.join("\n") } as CodemodeResult, isError: true };
        }

        if (execResult.code !== 0 || errorMsg) {
          return { content: [{ type: "text" as const, text: errorMsg ?? execResult.errorMessage ?? `Exit ${execResult.code}` }], details: { operations, filesModified: Array.from(filesModified), summary: buildSummary(operations), consoleOutput: consoleLogs.join("\n") } as CodemodeResult, isError: true };
        }

        const returnValue = resultJson ? JSON.parse(resultJson) : undefined;
        const summary = buildSummary(operations);

        return {
          content: [{ type: "text" as const, text: `${operations.length} ops, ${filesModified.size} files\n${summary}` }],
          details: { operations, filesModified: Array.from(filesModified), summary, consoleOutput: consoleLogs.join("\n"), returnValue } as CodemodeResult,
        };
      } catch (error) {
        server.close();
        runtime.dispose();
        return { content: [{ type: "text" as const, text: String(error) }], details: { operations, filesModified: Array.from(filesModified), summary: buildSummary(operations), consoleOutput: consoleLogs.join("\n") } as CodemodeResult, isError: true };
      }
    },

    renderCall(args: Static<typeof runSchema>, theme: Theme) {
      const lines = args.code.split("\n");
      return new Text(theme.fg("toolTitle", theme.bold("run")) + " " + theme.fg("accent", (lines[0] ?? "").slice(0, 60) + (lines.length > 1 ? " ..." : "")), 0, 0);
    },

    renderResult(result: { content: Array<{ type: string; text?: string }>; details?: CodemodeResult }, context: { expanded: boolean; isPartial: boolean }, theme: Theme) {
      if (context.isPartial) return new Text(theme.fg("warning", "..."), 0, 0);
      const d = result.details;
      if (!d) return new Text(theme.fg("error", "?"), 0, 0);

      if (context.expanded) {
        let text = d.filesModified.length ? theme.fg("toolTitle", "Files:") + "\n" + d.filesModified.map(f => "  " + theme.fg("accent", f)).join("\n") + "\n\n" : "";
        text += theme.fg("toolTitle", "Ops:") + "\n" + d.operations.map(op => `  ${op.success ? "✓" : "✗"} ${op.op}`).join("\n");
        if (d.consoleOutput?.trim()) text += "\n" + theme.fg("dim", d.consoleOutput.slice(0, 500));
        if (d.returnValue !== undefined) text += "\n→ " + JSON.stringify(d.returnValue).slice(0, 200);
        return new Text(text, 0, 0);
      }

      const s = d.operations.filter(o => o.success).length, f = d.operations.filter(o => !o.success).length;
      return new Text(theme.fg(f ? "warning" : "success", `${s}/${d.operations.length}${f ? ` ${f}fail` : ""}${d.filesModified.length ? ` ${d.filesModified.length}Δ` : ""}`), 0, 0);
    },
  };
}

function buildSummary(ops: OperationLog[]): string {
  if (ops.length === 0) return "None";
  const byType = new Map<string, number>();
  for (const o of ops) byType.set(o.op, (byType.get(o.op) ?? 0) + 1);
  return Array.from(byType.entries()).map(([op, n]) => `${n}${op}`).join(" ");
}
