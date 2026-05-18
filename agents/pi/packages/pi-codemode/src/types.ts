import type { ImageContent } from "@mariozechner/pi-ai";

export const builtinToolNames = ["read", "bash", "edit", "write", "grep", "find", "ls", "webfetch"] as const;
export type BuiltinToolName = (typeof builtinToolNames)[number];

export const fffToolNames = [
  "grep",
  "fileSearch",
  "multiGrep",
  "recentFiles",
  "searchThenGrep",
] as const;
export type FffToolName = (typeof fffToolNames)[number];

export type ToolResultSnapshot = {
  value: unknown;
  text: string;
  images?: ImageContent[];
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