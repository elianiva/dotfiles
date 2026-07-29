/**
 * Core TTSR checker.
 *
 * Loads ast-grep YAML rules from rule directories, matches them against
 * file content after edit/write operations, and returns violations.
 */

import { existsSync, readFileSync } from "node:fs";
import { extname, relative, join } from "node:path";
import { parse as parseYaml } from "yaml";
import { globSync } from "tinyglobby";
import picomatch from "picomatch";
import type {
  AstGrepRule,
  LoadedRule,
  ResolvedRuleConfig,
  Violation,
} from "./types";
import { EXT_TO_LANG } from "./types";
import { parseSource, findMatches } from "./napi";

// ─── Public API ───

/**
 * Check a file against all applicable TTSR rules.
 *
 * @param filePath - Absolute path to the file that was modified
 * @param ruleDirs - Array of rule directories to load rules from (global + project)
 * @param resolvedRules - Map from resolveRules() with per-rule config
 * @returns Array of violations found
 */
export function checkFile(
  filePath: string,
  ruleDirs: string[],
  resolvedRules: Map<string, ResolvedRuleConfig>,
): Violation[] {
  const ext = extname(filePath).toLowerCase().slice(1);
  const lang = EXT_TO_LANG[ext];
  if (!lang) return [];

  // Read the file content
  let source: string;
  try {
    source = readFileSync(filePath, "utf-8");
  } catch {
    return [];
  }

  if (source.trim().length === 0) return [];

  // Parse the source into an AST
  const root = parseSource(lang, source);
  if (!root) return [];

  // Load all rules from rule dirs
  const allRules = loadAllRules(ruleDirs);

  const violations: Violation[] = [];
  for (const loaded of allRules) {
    const ruleCfg = resolvedRules.get(loaded.rule.id);
    // Rule not mentioned in resolved config → not applicable to this project
    if (!ruleCfg) continue;
    if (!ruleCfg.enabled) continue;

    // Check severity threshold
    if (!meetsSeverityThreshold(loaded.rule.severity, ruleCfg.severity_threshold)) {
      continue;
    }

    // Check rule-level files/ignores globs
    if (!matchesRuleGlobs(filePath, loaded.rule)) {
      continue;
    }

    try {
      const matches = findMatches(
        root,
        loaded.rule.rule,
        loaded.rule.constraints as Record<string, unknown> | undefined,
        loaded.rule.transform as Record<string, unknown> | undefined,
        loaded.rule.utils as Record<string, unknown> | undefined,
      );

      for (const match of matches) {
        violations.push({
          ruleId: loaded.rule.id,
          filePath,
          message: loaded.rule.message,
          severity: loaded.rule.severity,
          matchedText: truncate(match.text, 120),
          lineStart: match.range.start.line + 1, // 0-based → 1-based
          lineEnd: match.range.end.line + 1,
        });
      }
    } catch (err) {
      console.warn(
        `[omp-distill/ttsr] Error running rule ${loaded.rule.id}:`,
        err instanceof Error ? err.message : String(err),
      );
    }
  }

  return violations;
}

/**
 * Look up the language alias for a file path.
 */
export function getLangForFile(filePath: string): string | undefined {
  const ext = extname(filePath).toLowerCase().slice(1);
  return EXT_TO_LANG[ext];
}

// ─── Rule loading ───

/** Cache of loaded rules, keyed by rule dir. Invalidated on restart. */
const rulesCache = new Map<string, LoadedRule[]>();

function loadAllRules(ruleDirs: string[]): LoadedRule[] {
  const allRules: LoadedRule[] = [];
  const seen = new Set<string>();

  for (const dir of ruleDirs) {
    if (!existsSync(dir)) continue;

    // Use cache if available
    let dirRules = rulesCache.get(dir);
    if (!dirRules) {
      dirRules = loadRulesFromDir(dir);
      rulesCache.set(dir, dirRules);
    }

    for (const loaded of dirRules) {
      if (seen.has(loaded.rule.id)) continue;
      seen.add(loaded.rule.id);
      allRules.push(loaded);
    }
  }

  return allRules;
}

function loadRulesFromDir(dir: string): LoadedRule[] {
  const rules: LoadedRule[] = [];

  // Use tinyglobby to find all YAML rule files
  let yamlFiles: string[];
  try {
    yamlFiles = globSync(["**/*.yml", "**/*.yaml"], {
      cwd: dir,
      absolute: true,
      ignore: ["**/config.yml", "**/config.yaml"],
    });
  } catch {
    return [];
  }

  for (const filePath of yamlFiles) {
    const rule = parseRuleFile(filePath);
    if (!rule) continue;
    rules.push({ filePath, rule });
  }

  return rules;
}

function parseRuleFile(filePath: string): AstGrepRule | null {
  try {
    const raw = readFileSync(filePath, "utf-8");
    const parsed = parseYaml(raw) as Record<string, unknown>;
    if (!parsed || typeof parsed !== "object") return null;
    if (!parsed.id || !parsed.rule) return null;

    return {
      id: parsed.id as string,
      language: (parsed.language as string) ?? "",
      severity: (parsed.severity as AstGrepRule["severity"]) ?? "warning",
      message: (parsed.message as string) ?? "",
      note: parsed.note as string | undefined,
      rule: parsed.rule as AstGrepRule["rule"],
      files: parsed.files as string[] | undefined,
      ignores: parsed.ignores as string[] | undefined,
      fix: parsed.fix as string | undefined,
      constraints: parsed.constraints as Record<string, unknown> | undefined,
      transform: parsed.transform as Record<string, unknown> | undefined,
      utils: parsed.utils as Record<string, unknown> | undefined,
    };
  } catch (err) {
    console.warn(
      `[omp-distill/ttsr] Failed to parse rule: ${filePath}`,
      err instanceof Error ? err.message : String(err),
    );
    return null;
  }
}

// ─── Helpers ───

const SEVERITY_RANK: Record<string, number> = {
  error: 0,
  warning: 1,
  info: 2,
  hint: 3,
};

function meetsSeverityThreshold(
  severity: string,
  threshold: string,
): boolean {
  return (SEVERITY_RANK[severity] ?? 1) <= (SEVERITY_RANK[threshold] ?? 1);
}

function matchesRuleGlobs(filePath: string, rule: AstGrepRule): boolean {
  // Normalize to relative path for glob matching, using forward slashes
  const normalized = filePath.replaceAll("\\", "/");

  if (rule.files && rule.files.length > 0) {
    const matched = rule.files.some((pattern) => {
      const isMatch = picomatch(pattern);
      return isMatch(normalized) || isMatch(normalized.split("/").pop() ?? normalized);
    });
    if (!matched) return false;
  }

  if (rule.ignores && rule.ignores.length > 0) {
    const ignored = rule.ignores.some((pattern) => {
      const isMatch = picomatch(pattern);
      return isMatch(normalized) || isMatch(normalized.split("/").pop() ?? normalized);
    });
    if (ignored) return false;
  }

  return true;
}

function truncate(text: string, maxLen: number): string {
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen - 3) + "...";
}
