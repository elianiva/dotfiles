import * as fs from "node:fs/promises";
import * as path from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

export const ROLE_NAMES = [
  "feature, refactoring",
  "bug-fix",
  "perf-issue",
  "hillclimb",
  "judgment and prose",
  "hardest tasks",
  "how explorer",
  "how explainer",
  "how critics",
  "why investigators",
  "why synthesizer",
  "reflect tooling",
  "reflect judgment, divergent, synthesizer",
  "arena runners",
  "arena cross-judge pool",
  "swarm workers",
  "architect runners",
  "interrogate reviewers",
] as const;

export type RoleName = (typeof ROLE_NAMES)[number];
export type RoleValue = string | string[];

export interface PstackConfig {
  version: 1;
  roles: Record<string, RoleValue>;
}

export function configPath(): string {
  return path.join(getAgentDir(), "pstack", "models.json");
}

export function defaultConfig(): PstackConfig {
  return {
    version: 1,
    roles: Object.fromEntries(ROLE_NAMES.map((role) => [role, "inherit-parent"])),
  };
}

export async function readConfig(): Promise<PstackConfig> {
  try {
    const parsed = JSON.parse(await fs.readFile(configPath(), "utf8")) as Partial<PstackConfig>;
    if (parsed.version !== 1 || !parsed.roles || typeof parsed.roles !== "object") return defaultConfig();
    const roles: Record<string, RoleValue> = { ...defaultConfig().roles };
    for (const [role, value] of Object.entries(parsed.roles)) {
      if (typeof value === "string" || (Array.isArray(value) && value.every((item) => typeof item === "string"))) {
        roles[role] = value;
      }
    }
    return { version: 1, roles };
  } catch {
    return defaultConfig();
  }
}

export async function writeConfig(config: PstackConfig): Promise<void> {
  const target = configPath();
  await fs.mkdir(path.dirname(target), { recursive: true });
  await fs.writeFile(target, `${JSON.stringify(config, null, 2)}\n`, { mode: 0o600 });
}

export function modelsForRole(config: PstackConfig, role: string | undefined): string[] {
  if (!role) return [];
  const value = config.roles[role];
  const values = typeof value === "string" ? [value] : Array.isArray(value) ? value : [];
  return values.filter((model) => model !== "inherit-parent" && model !== "auto");
}

export function modelForRole(config: PstackConfig, role: string | undefined): string | undefined {
  return modelsForRole(config, role)[0];
}
