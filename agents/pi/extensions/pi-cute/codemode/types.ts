import { Type } from "@sinclair/typebox";

export const runSchema = Type.Object({
  code: Type.String({ description: "JavaScript code to execute with pi.tools API" }),
});

export type CodemodeResult = {
  operations: OperationLog[];
  filesModified: string[];
  summary: string;
  consoleOutput: string;
  returnValue?: unknown;
};

export type OperationLog = {
  op: "read" | "write" | "edit" | "bash" | "find" | "ls";
  input: Record<string, unknown>;
  duration_ms: number;
  success: boolean;
  output?: unknown;
  error?: string;
};

export type ToolImpl = (input: Record<string, unknown>) => Promise<unknown>;
