/**
 * Host-side tool bridge.
 *
 * Guest cells call `tool.<name>({...})`; the frame travels through the REPL
 * to this module, which executes the real pi tool definition in the host
 * process and returns the result. The bridge deliberately exposes a fixed
 * allowlist of tools — no bash, no eval, no subagent — so sandboxed code can
 * never spawn host processes or recurse.
 *
 * `env(name?)` is a reserved pseudo-tool returning an allowlisted view of the
 * host environment (the guest's own `process.env` is denied by the VM).
 */

import type { ExtensionAPI, ExtensionContext, ToolDefinition } from "@earendil-works/pi-coding-agent";
import {
  createEditToolDefinition,
  createFindToolDefinition,
  createGrepToolDefinition,
  createLsToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { createWebSearchTool } from "../web-search";

export const BRIDGE_TOOL_NAMES = ["read", "write", "edit", "grep", "find", "ls", "web_search"] as const;

export const ENV_ALLOWLIST = ["PWD", "HOME", "USER", "SHELL", "TERM", "LANG", "PATH"];

interface EnvRequest {
  name?: string;
}
const definitionCache = new Map<string, EvalBridge>();

export class EvalBridge {
  private readonly defs = new Map<string, ToolDefinition<any, any, any>>();
  private seq = 0;

  private constructor(pi: ExtensionAPI, cwd: string) {
    this.defs.set("read", createReadToolDefinition(cwd));
    this.defs.set("write", createWriteToolDefinition(cwd));
    this.defs.set("edit", createEditToolDefinition(cwd));
    this.defs.set("grep", createGrepToolDefinition(cwd));
    this.defs.set("find", createFindToolDefinition(cwd));
    this.defs.set("ls", createLsToolDefinition(cwd));
    this.defs.set("web_search", createWebSearchTool(pi));
  }

  /** Get the bridge for a cwd, rebuilding lazily when the cwd changes. */
  static for(pi: ExtensionAPI, cwd: string): EvalBridge {
    const cached = definitionCache.get(cwd);
    if (cached) return cached;
    const bridge = new EvalBridge(pi, cwd);
    definitionCache.clear();
    definitionCache.set(cwd, bridge);
    return bridge;
  }

  static toolNames(): string {
    return BRIDGE_TOOL_NAMES.join(", ");
  }

  /** Execute a bridge call. Throws with a plain message on any failure. */
  async call(ctx: ExtensionContext, name: string, args: unknown, signal: AbortSignal | undefined): Promise<unknown> {
    if (name === "__env") {
      return this.envView(args);
    }
    const def = this.defs.get(name);
    if (!def) {
      throw new Error(`unknown tool "${name}" — the eval bridge exposes: ${BRIDGE_TOOL_NAMES.join(", ")}`);
    }
    try {
      const result = await def.execute(`eval-bridge-${++this.seq}`, args, signal, undefined, ctx);
      const text = result.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("\n");
      const details = result.details;
      if (details !== undefined && details !== null && typeof details === "object" && Object.keys(details).length > 0) {
        return { text, details };
      }
      return text;
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      throw new Error(`tool.${name} failed: ${message}`);
    }
  }

  private envView(args: unknown): unknown {
    const request = args as EnvRequest | undefined;
    const name = request?.name;
    if (typeof name === "string") {
      return ENV_ALLOWLIST.includes(name) ? (process.env[name] ?? null) : null;
    }
    const view: Record<string, string> = {};
    for (const key of ENV_ALLOWLIST) {
      const value = process.env[key];
      if (value !== undefined) view[key] = value;
    }
    return view;
  }
}
