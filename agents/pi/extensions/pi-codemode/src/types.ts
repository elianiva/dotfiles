import type { ImageContent, TextContent } from "@mariozechner/pi-ai";

export const builtinToolNames = ["read", "bash", "edit", "write", "grep", "find", "ls"] as const;
export type BuiltinToolName = (typeof builtinToolNames)[number];

export type ToolContent = (TextContent | ImageContent)[];

export type ToolResultSnapshot = {
  value: unknown;
  text: string;
  isError: boolean;
};

export type TraceStep = {
  id: string;
  label: string;
  toolPath: string;
  input: unknown;
  startedAt: number;
  endedAt?: number;
  status: "running" | "ok" | "error";
  output?: ToolResultSnapshot;
  error?: string;
};

export type CodemodeTrace = {
  cwd: string;
  code: string;
  startedAt: number;
  endedAt?: number;
  status: "running" | "ok" | "error" | "aborted";
  value?: unknown;
  logs: string[];
  steps: TraceStep[];
  error?: string;
};

export type CodemodeResultDetails = {
  trace: CodemodeTrace;
  value?: unknown;
  logs: string[];
  summary: string;
};
