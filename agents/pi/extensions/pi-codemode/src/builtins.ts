import {
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
} from "@mariozechner/pi-coding-agent";
import { createCustomReadTool } from "./read.js";
import { webfetch } from "./webfetch.js";
import type { BuiltinToolName } from "./types.js";
import { Type } from "@sinclair/typebox";

export type BuiltinTool = {
  name: string;
  description: string;
  parameters: unknown;
  execute: (...args: any[]) => Promise<unknown>;
};

// Only package managers — everything else has a codemode tool equivalent
const BASH_COMMAND_WHITELIST = new Set([
  // Package managers
  "vp",
  "vpx",
  "npm",
  "pnpm",
  "bun",
  "yarn",
  "npx",
  // File operations (no codemode tool equivalent)
  "mkdir",
  "touch",
  "cp",
  "mv",
  // Utilities
  "pwd",
  "which",
  "type",
  "uname",
]);

const WHITELIST_HELP = () => [
  `Allowed commands: ${[...BASH_COMMAND_WHITELIST].sort().join(", ")}`,
  "Use tools.pi.* for reading, writing, searching, grepping, editing files.",
].join("\n");

function extractCommandName(command: string): string | null {
  // Strip shell redirects, pipes, chaining, then grab first word
  const cleaned = command
    .replace(/\\s*[|&;<>]/g, " ")
    .replace(/\(/g, " ")
    .trim();
  const first = cleaned.split(/\s+/)[0];
  if (!first) return null;
  // Strip leading path (e.g., ./node_modules/.bin/npm) — not whitelisted
  if (first.includes("/")) return null;
  return first;
}

function createWhitelistedBashTool(cwd: string): BuiltinTool {
  const bashTool = createBashTool(cwd) as BuiltinTool;

  return {
    name: bashTool.name,
    description:
      "Run package manager commands (npm, pnpm, bun, yarn, npx, node). Other commands are blocked — use tools.pi.* instead.",
    parameters: bashTool.parameters,
    async execute(toolCallId: string, args: any, signal: AbortSignal | undefined, onUpdate: any) {
      const command = String(args?.command ?? "").trim();
      if (!command) {
        return {
          content: [{ type: "text", text: "No command provided.\n\n" + WHITELIST_HELP() }],
        };
      }

      const cmdName = extractCommandName(command);

      if (!cmdName || !BASH_COMMAND_WHITELIST.has(cmdName)) {
        const blocked = cmdName ? `"${cmdName}" is not whitelisted` : "Could not parse command";
        return {
          content: [
            {
              type: "text",
              text: [`Error: ${blocked}`, "", WHITELIST_HELP()].join("\n"),
            },
          ],
        };
      }

      // Proxy: forward execute via original tool's execute
      const result = await bashTool.execute(toolCallId, args, signal, onUpdate);
      return result;
    },
  };
}

const webfetchTool: BuiltinTool = {
  name: "webfetch",
  description:
    "Fetch web content and convert to markdown, text, or html. Use when URLs are mentioned to retrieve content. HTTP URLs upgraded to HTTPS. Images and binary content return empty text.",
  parameters: Type.Object({
    url: Type.String({ description: "The URL to fetch content from" }),
    format: Type.Optional(
      Type.Union([Type.Literal("markdown"), Type.Literal("text"), Type.Literal("html")], {
        description: "Output format: markdown (default), text, or html",
      }),
    ),
    timeout: Type.Optional(
      Type.Number({ description: "Timeout in seconds (max 120, default 30)" }),
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

const META_APIS = ["tools.list()", "tools.schema(name)", "tools.definitions()"];

export function createBuiltinToolset(cwd: string) {
  return {
    read: createCustomReadTool(cwd) as BuiltinTool,
    edit: createEditTool(cwd) as BuiltinTool,
    write: createWriteTool(cwd) as BuiltinTool,
    grep: createGrepTool(cwd) as BuiltinTool,
    find: createFindTool(cwd) as BuiltinTool,
    ls: createLsTool(cwd) as BuiltinTool,
    bash: createWhitelistedBashTool(cwd) as BuiltinTool,
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
    "If the user mentions an unknown tool, call tools.list() to get a list of available tools",
    "Before using any unfamiliar tool, call tools.schema('tool.name') to get its exact parameter and return types.",
    "Dynamically loaded tools are namespaced: tools.openapi.petstore.listPets, tools.mcp.myServer.search.",
    "Prefer one codemode call; batch work with JS and Promise.all.",
    "",
    "### Bash restrictions",
    `tools.pi.bash only allows: ${[...BASH_COMMAND_WHITELIST].sort().join(", ")}.`,
    "Everything else is blocked — use the dedicated tools above instead.",
  ].join("\n");
}
