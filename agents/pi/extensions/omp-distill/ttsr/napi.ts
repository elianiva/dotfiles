/**
 * Thin wrapper around @ast-grep/napi.
 *
 * Provides type-safe access to the napi functions we need for TTSR.
 * If the napi package fails to load, all functions become no-ops that return
 * empty results, allowing graceful degradation.
 */

import type { AstGrepRuleObject } from "./types";

interface NapiModule {
  parse(lang: string, src: string): SgRoot;
}

interface SgRoot {
  root(): SgNode;
  filename(): string;
}

interface Range {
  start: { line: number; column: number; index: number };
  end: { line: number; column: number; index: number };
}

interface SgNode {
  range(): Range;
  text(): string;
  kind(): string;
  isLeaf(): boolean;
  isNamed(): boolean;
  findAll(matcher: NapiConfig): SgNode[];
  getMatch(m: string): SgNode | null;
  getRoot(): SgRoot;
}

interface NapiConfig {
  rule: Record<string, unknown>;
  constraints?: Record<string, unknown>;
  language?: string;
  transform?: Record<string, unknown>;
  utils?: Record<string, unknown>;
}

export interface MatchResult {
  node: SgNode;
  range: Range;
  text: string;
  /** Meta-variable bindings keyed by variable name (without $). */
  bindings: Record<string, string>;
}

// Try loading the native module at import time
let napi: NapiModule | null = null;
try {
  // jiti supports dynamic import at module top level
  napi = (await import("@ast-grep/napi")) as unknown as NapiModule;
} catch {
  // Silently degrade — TTSR will be disabled
}

/** Whether the napi module is available. */
export function isNapiAvailable(): boolean {
  return napi !== null;
}

/**
 * Parse source code into an AST root.
 * Returns null if napi is unavailable or parsing fails.
 */
export function parseSource(
  lang: string,
  source: string,
): SgRoot | null {
  if (!napi) return null;
  try {
    return napi.parse(lang, source);
  } catch (err) {
    console.warn(
      `[omp-distill/ttsr] Failed to parse source as ${lang}:`,
      err instanceof Error ? err.message : String(err),
    );
    return null;
  }
}

/**
 * Run an ast-grep rule against a parsed AST root.
 * Returns all matches.
 */
export function findMatches(
  root: SgRoot,
  rule: AstGrepRuleObject,
  constraints?: Record<string, unknown>,
  transform?: Record<string, unknown>,
  utils?: Record<string, unknown>,
): MatchResult[] {
  try {
    const config: NapiConfig = {
      rule: rule as Record<string, unknown>,
    };
    if (constraints && Object.keys(constraints).length > 0) {
      config.constraints = constraints;
    }
    if (transform && Object.keys(transform).length > 0) {
      config.transform = transform;
    }
    if (utils && Object.keys(utils).length > 0) {
      config.utils = utils;
    }

    const rootNode = root.root();
    const nodes = rootNode.findAll(config);

    return nodes.map((node) => {
      const range = node.range();
      return {
        node,
        range,
        text: node.text(),
        bindings: extractBindings(node, rule),
      };
    });
  } catch (err) {
    console.warn(
      "[omp-distill/ttsr] Rule matching failed:",
      err instanceof Error ? err.message : String(err),
    );
    return [];
  }
}

/**
 * Extract meta-variable bindings from a matched node.
 */
function extractBindings(
  node: SgNode,
  rule: AstGrepRuleObject,
): Record<string, string> {
  const bindings: Record<string, string> = {};
  const varNames = collectMetaVars(rule);
  for (const name of varNames) {
    const m = node.getMatch(name);
    if (m) {
      bindings[name] = m.text();
    }
  }
  return bindings;
}

/**
 * Collect all meta-variable names ($VAR) referenced in a rule object.
 */
function collectMetaVars(obj: unknown): Set<string> {
  const vars = new Set<string>();
  if (!obj || typeof obj !== "object") return vars;

  const record = obj as Record<string, unknown>;
  for (const value of Object.values(record)) {
    if (typeof value === "string") {
      for (const match of value.matchAll(/\$([A-Z_][A-Z0-9_]*)/g)) {
        vars.add(match[1]);
      }
      if (/\$\$\$/.test(value)) {
        vars.add("$$$");
      }
    } else if (typeof value === "object") {
      for (const v of collectMetaVars(value)) {
        vars.add(v);
      }
    }
  }
  return vars;
}
