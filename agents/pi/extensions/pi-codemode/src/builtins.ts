import {
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
} from "@mariozechner/pi-coding-agent";
import { webfetch } from "./webfetch.js";
import type { BuiltinToolName } from "./types.js";
import { Type } from "@sinclair/typebox";

export type BuiltinTool = {
  name: string;
  description: string;
  parameters: unknown;
  execute: (...args: any[]) => Promise<unknown>;
};

const webfetchTool: BuiltinTool = {
  name: "webfetch",
  description: "Fetch web content and convert to markdown, text, or html. Use when URLs are mentioned to retrieve content. HTTP URLs upgraded to HTTPS. Images and binary content return empty text.",
  parameters: Type.Object({
    url: Type.String({ description: "The URL to fetch content from" }),
    format: Type.Optional(
      Type.Union(
        [Type.Literal("markdown"), Type.Literal("text"), Type.Literal("html")],
        { description: "Output format: markdown (default), text, or html" }
      )
    ),
    timeout: Type.Optional(
      Type.Number({ description: "Timeout in seconds (max 120, default 30)" })
    ),
  }),
  execute: webfetch,
};

export type BuiltinToolset = Record<BuiltinToolName, BuiltinTool>;

const PI_SIGNATURES = [
  "tools.pi.read({ path, offset?, limit? })",
  "tools.pi.bash({ command, timeout? })",
  "tools.pi.edit({ path, edits: [{ oldText, newText }] })",
  "tools.pi.write({ path, content })",
  "tools.pi.grep({ pattern, path?, glob?, ignoreCase?, literal?, context?, limit? })",
  "tools.pi.find({ pattern, path?, limit? })",
  "tools.pi.ls({ path?, limit? })",
  "tools.pi.webfetch({ url, format?, timeout? })",
];

const FFF_SIGNATURES = [
  "tools.fff.grep({ pattern, path?, mode?, smartCase?, glob?, maxMatchesPerFile?, context?, classifyDefinitions?, limit? })",
  "tools.fff.fileSearch({ query, path?, limit? })",
  "tools.fff.multiGrep({ patterns, path?, limit? })",
  "tools.fff.recentFiles({ path?, limit?, minFrecencyScore?, includeUntracked? })",
  "tools.fff.searchThenGrep({ pathQuery, contentQuery, path?, maxFiles?, limit? })",
];

const META_APIS = [
  "tools.list() — list tools",
  "tools.schema(name) — get TypeScript types for a tool. Use this before any unfamiliar tool.",
  "  Example: const params = JSON.parse(tools.schema('tools.mcp.myServer.search'))",
  "tools.definitions() — shared schema types",
];

export function createBuiltinToolset(cwd: string): BuiltinToolset {
  return {
    read: createReadTool(cwd) as BuiltinTool,
    bash: createBashTool(cwd) as BuiltinTool,
    edit: createEditTool(cwd) as BuiltinTool,
    write: createWriteTool(cwd) as BuiltinTool,
    grep: createGrepTool(cwd) as BuiltinTool,
    find: createFindTool(cwd) as BuiltinTool,
    ls: createLsTool(cwd) as BuiltinTool,
    webfetch: webfetchTool,
  };
}

export function buildCodemodeApiPrompt(): string {
  return [
    "## Available APIs",
    "",
    "### pi tools",
    ...PI_SIGNATURES,
    "",
    "### fff tools",
    ...FFF_SIGNATURES,
    "",
    "### Discovery",
    ...META_APIS,
    "",
    "All pi and fff tools return plain text strings. Other tools (MCP, OpenAPI, GraphQL) return objects.",
    "Before using any unfamiliar tool, call tools.schema('tool.name') to get its exact parameter and return types.",
    "Dynamically loaded tools are namespaced: tools.openapi.petstore.listPets, tools.mcp.myServer.search.",
    "Prefer one codemode call; batch work with JS and Promise.all.",
  ].join("\n");
}