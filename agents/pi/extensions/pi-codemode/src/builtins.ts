import {
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
} from "@mariozechner/pi-coding-agent";
import type { BuiltinToolName } from "./types.js";

export type BuiltinTool = {
  name: string;
  description: string;
  parameters: unknown;
  execute: (...args: any[]) => Promise<unknown>;
};

export type BuiltinToolset = Record<BuiltinToolName, BuiltinTool>;

const TOOL_SIGNATURES: Record<BuiltinToolName, string> = {
  read: "tools.pi.read({ path, offset?, limit? })",
  bash: "tools.pi.bash({ command, timeout? })",
  edit: "tools.pi.edit({ path, edits: [{ oldText, newText }] })",
  write: "tools.pi.write({ path, content })",
  grep: "tools.pi.grep({ pattern, path?, glob?, ignoreCase?, literal?, context?, limit? })",
  find: "tools.pi.find({ pattern, path?, limit? })",
  ls: "tools.pi.ls({ path?, limit? })",
};

export function createBuiltinToolset(cwd: string): BuiltinToolset {
  return {
    read: createReadTool(cwd) as BuiltinTool,
    bash: createBashTool(cwd) as BuiltinTool,
    edit: createEditTool(cwd) as BuiltinTool,
    write: createWriteTool(cwd) as BuiltinTool,
    grep: createGrepTool(cwd) as BuiltinTool,
    find: createFindTool(cwd) as BuiltinTool,
    ls: createLsTool(cwd) as BuiltinTool,
  };
}

export function buildCodemodeApiPrompt(): string {
  return [
    "## pi async API",
    ...Object.values(TOOL_SIGNATURES),
    "",
    "Each tool returns raw executor tool data.",
    "Use only tools.pi.* from codemode.",
    "Prefer one codemode call, batch work with JS.",
  ].join("\n");
}
