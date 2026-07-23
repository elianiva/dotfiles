/**
 * skill:// protocol handler.
 *
 * Resolves `skill://<name>` to the skill's SKILL.md content.
 * Falls back to scanning project + global skill dirs.
 */
import { loadSkills, getAgentDir } from "@earendil-works/pi-coding-agent";

export interface SkillResult {
  content: string;
  source: string;
}

/**
 * Resolve a skill:// URL to its content.
 *   skill://<name>          → read that skill's SKILL.md
 *   skill://<name>/<path>   → read a specific file inside the skill dir
 */
export async function resolveSkill(raw: string, cwd: string): Promise<SkillResult> {
  const { host, pathname } = parseSkillUrl(raw);
  if (!host) throw new Error("skill:// URL requires a skill name. Usage: skill://<name>");

  const agentDir = getAgentDir();
  const { skills } = loadSkills({
    cwd,
    agentDir,
    skillPaths: [],
    includeDefaults: true,
  });

  const skill = skills.find((s) => s.name === host);
  if (!skill) {
    const names = skills.map((s) => s.name).join(", ") || "none";
    throw new Error(`Unknown skill: "${host}". Available: ${names}`);
  }

  if (pathname) {
    // Resolve relative path within skill dir
    const { readFileSync, existsSync } = await import("node:fs");
    const { join } = await import("node:path");
    const target = join(skill.baseDir, pathname);
    if (!existsSync(target)) {
      throw new Error(`File "${pathname}" not found in skill "${host}"`);
    }
    const content = readFileSync(target, "utf-8");
    return { content, source: `${host}/${pathname}` };
  }

  const { readFileSync } = await import("node:fs");
  const content = readFileSync(skill.filePath, "utf-8");
  return { content, source: host };
}

function parseSkillUrl(raw: string): { host: string; pathname: string } {
  const m = raw.match(/^skill:\/\/([^/]+)(?:\/(.*))?$/);
  if (!m) return { host: "", pathname: "" };
  return { host: m[1], pathname: m[2] ?? "" };
}

import type { ProtocolHandler } from "./types";

export function isSkillUrl(path: string): boolean {
  return /^skill:\/\//i.test(path);
}

/** Protocol handler for skill:// URLs. */
export const skillHandler: ProtocolHandler = {
  scheme: "skill",
  matches: isSkillUrl,
  async resolve(path, ctx) {
    const resolved = await resolveSkill(path, ctx.cwd);
    return {
      content: [{ type: "text", text: resolved.content }],
      details: { source: resolved.source },
    };
  },
};
