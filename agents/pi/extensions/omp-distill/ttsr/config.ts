/**
 * Config loader for TTSR.
 *
 * Loads config.yml files from rule directories, evaluates project detection
 * signals against the current project, and resolves which rules are active.
 */

import { existsSync, readFileSync } from "node:fs";
import { readdirSync } from "node:fs";
import { extname, join } from "node:path";
import { parse as parseYaml } from "yaml";
import type {
  TtsrConfig,
  ProjectGroup,
  ResolvedRuleConfig,
} from "./types";

// ─── Public API ───

/**
 * Load config.yml from all rule directories.
 * Global (~/.pi/agent/ttsr-rules/) is the base, project (.pi/ttsr-rules/) overlays.
 */
export function loadConfig(
  globalRulesDir: string,
  projectRulesDir: string,
): TtsrConfig {
  const globalConfig = readConfigFile(join(globalRulesDir, "config.yml"));
  const projectConfig = readConfigFile(join(projectRulesDir, "config.yml"));

  return mergeConfigs(globalConfig, projectConfig);
}

/**
 * Evaluate project detection groups against the current project
 * and resolve the final set of enabled/disabled rules.
 *
 * Returns a Map of ruleId → ResolvedRuleConfig.
 */
export function resolveRules(
  config: TtsrConfig,
  cwd: string,
): Map<string, ResolvedRuleConfig> {
  const globalDefaults = config.defaults ?? {};
  const globalEnabled = globalDefaults.enabled !== false;
  const globalThreshold = globalDefaults.severity_threshold ?? "warning";

  const resolved = new Map<string, ResolvedRuleConfig>();

  // Seed with per-rule overrides from config.rules
  if (config.rules) {
    for (const [ruleId, ruleCfg] of Object.entries(config.rules)) {
      resolved.set(ruleId, {
        enabled: ruleCfg.enabled !== false && globalEnabled,
        severity_threshold: globalThreshold,
      });
    }
  }

  // Apply project detection groups (all matching groups are merged)
  if (config.projects) {
    for (const group of config.projects) {
      if (matchesProject(group, cwd)) {
        applyGroup(resolved, group, globalEnabled, globalThreshold);
      }
    }
  }

  return resolved;
}

// ─── Config file I/O ───

function readConfigFile(filePath: string): TtsrConfig {
  try {
    if (!existsSync(filePath)) return {};
    const raw = readFileSync(filePath, "utf-8");
    return (parseYaml(raw) as TtsrConfig) ?? {};
  } catch (err) {
    console.warn(
      `[omp-distill/ttsr] Failed to read config: ${filePath}`,
      err instanceof Error ? err.message : String(err),
    );
    return {};
  }
}

function mergeConfigs(base: TtsrConfig, overlay: TtsrConfig): TtsrConfig {
  return {
    defaults: { ...base.defaults, ...overlay.defaults },
    rules: { ...base.rules, ...overlay.rules },
    projects: [...(base.projects ?? []), ...(overlay.projects ?? [])],
  };
}

// ─── Project detection ───

function matchesProject(group: ProjectGroup, cwd: string): boolean {
  const detect = group.detect;
  // No detect = catch-all (matches all projects)
  if (!detect || Object.keys(detect).length === 0) return true;

  if (detect.hasFile && detect.hasFile.length > 0) {
    if (!detect.hasFile.some((f) => existsSync(join(cwd, f)))) return false;
  }

  if (
    (detect.hasDep && detect.hasDep.length > 0) ||
    (detect.hasDevDep && detect.hasDevDep.length > 0) ||
    detect.packageName
  ) {
    const pkg = readPackageJson(cwd);
    if (!pkg) return false;

    if (detect.hasDep && detect.hasDep.length > 0) {
      const allDeps = { ...pkg.dependencies, ...pkg.peerDependencies };
      if (!detect.hasDep.some((d) => d in allDeps)) return false;
    }

    if (detect.hasDevDep && detect.hasDevDep.length > 0) {
      const devDeps = pkg.devDependencies ?? {};
      if (!detect.hasDevDep.some((d) => d in devDeps)) return false;
    }

    if (detect.packageName && pkg.name !== detect.packageName) {
      return false;
    }
  }

  if (detect.language && detect.language.length > 0) {
    if (!detectLanguage(cwd, detect.language)) return false;
  }

  return true;
}

interface PackageJson {
  name?: string;
  dependencies?: Record<string, string>;
  devDependencies?: Record<string, string>;
  peerDependencies?: Record<string, string>;
}

function readPackageJson(cwd: string): PackageJson | null {
  const pkgPath = join(cwd, "package.json");
  try {
    if (!existsSync(pkgPath)) return null;
    return JSON.parse(readFileSync(pkgPath, "utf-8")) as PackageJson;
  } catch {
    return null;
  }
}

function detectLanguage(cwd: string, languages: string[]): boolean {
  const extMap: Record<string, string[]> = {
    ts: [".ts", ".tsx", ".mts", ".cts"],
    tsx: [".tsx"],
    js: [".js", ".jsx", ".mjs", ".cjs"],
    jsx: [".jsx"],
    rs: [".rs"],
    py: [".py", ".pyi", ".py3"],
    go: [".go"],
    java: [".java"],
    rb: [".rb"],
    cs: [".cs"],
    cpp: [".cpp", ".cc", ".cxx", ".hpp", ".hh"],
    c: [".c", ".h"],
    css: [".css"],
  };

  const wantedExts = new Set<string>();
  for (const lang of languages) {
    const exts = extMap[lang] ?? [`.${lang}`];
    for (const ext of exts) wantedExts.add(ext);
  }

  return scanForExtensions(cwd, wantedExts, 2);
}

function scanForExtensions(
  dir: string,
  wantedExts: Set<string>,
  maxDepth: number,
): boolean {
  if (maxDepth < 0) return false;
  try {
    const entries = readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      if (entry.isDirectory()) {
        if (entry.name.startsWith(".") || entry.name === "node_modules")
          continue;
        if (scanForExtensions(join(dir, entry.name), wantedExts, maxDepth - 1))
          return true;
      } else if (wantedExts.has(extname(entry.name))) {
        return true;
      }
    }
  } catch {
    // Permission denied — skip
  }
  return false;
}

function applyGroup(
  resolved: Map<string, ResolvedRuleConfig>,
  group: ProjectGroup,
  globalEnabled: boolean,
  globalThreshold: string,
): void {
  const threshold = globalThreshold as ResolvedRuleConfig["severity_threshold"];
  for (const ruleId of group.enable ?? []) {
    resolved.set(ruleId, { enabled: globalEnabled, severity_threshold: threshold });
  }
  for (const ruleId of group.disable ?? []) {
    resolved.set(ruleId, { enabled: false, severity_threshold: threshold });
  }
}
