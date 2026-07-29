/**
 * Shared types for the TTSR (Time-Traveling Stream Rules) system.
 */

// ─── Ast-grep rule types (matches YAML rule file format) ───

export interface AstGrepAtomicRule {
  pattern?: string | { selector: string; context: string; strictness?: string };
  kind?: string;
  regex?: string;
  nthChild?: number | string | { position: number | string; reverse?: boolean; ofRule?: AstGrepRuleObject };
  range?: { start: { line: number; column: number }; end: { line: number; column: number } };
}

export interface AstGrepRelationalRule extends AstGrepRuleObject {
  stopBy?: "neighbor" | "end" | AstGrepRuleObject;
  field?: string;
}

export interface AstGrepCompositeRule {
  all?: AstGrepRuleObject[];
  any?: AstGrepRuleObject[];
  not?: AstGrepRuleObject;
  matches?: string;
}

export type AstGrepRuleObject = AstGrepAtomicRule & AstGrepCompositeRule & {
  inside?: AstGrepRelationalRule;
  has?: AstGrepRelationalRule;
  precedes?: AstGrepRelationalRule;
  follows?: AstGrepRelationalRule;
};

/** Represents a single ast-grep rule loaded from a YAML file. */
export interface AstGrepRule {
  id: string;
  language: string;
  severity: "error" | "warning" | "info" | "hint";
  message: string;
  note?: string;
  rule: AstGrepRuleObject;
  files?: string[];
  ignores?: string[];
  fix?: string;
  constraints?: Record<string, AstGrepRuleObject>;
  transform?: Record<string, unknown>;
  utils?: Record<string, AstGrepRuleObject>;
}

/** A loaded rule file with its resolved path. */
export interface LoadedRule {
  filePath: string;
  rule: AstGrepRule;
}

// ─── Config types (config.yml) ───

export interface TtsrConfig {
  defaults?: {
    enabled?: boolean;
    severity_threshold?: "error" | "warning" | "info" | "hint";
  };
  rules?: Record<string, {
    enabled?: boolean;
  }>;
  projects?: ProjectGroup[];
}

export interface ProjectGroup {
  detect?: {
    hasFile?: string[];
    hasDep?: string[];
    hasDevDep?: string[];
    packageName?: string;
    language?: string[];
  };
  enable?: string[];
  disable?: string[];
}

// ─── Runtime types ───

/** Resolved configuration for a single rule after project detection. */
export interface ResolvedRuleConfig {
  enabled: boolean;
  severity_threshold: "error" | "warning" | "info" | "hint";
}

/** A matched violation from running a rule against source code. */
export interface Violation {
  ruleId: string;
  filePath: string;
  message: string;
  severity: "error" | "warning" | "info" | "hint";
  /** The code span that matched, if available. */
  matchedText?: string;
  /** 1-based line numbers (approximate). */
  lineStart?: number;
  lineEnd?: number;
}

/** Language extension mapping: file extension → ast-grep Lang enum value. */
export const EXT_TO_LANG: Record<string, string> = {
  ts: "TypeScript",
  tsx: "Tsx",
  js: "JavaScript",
  jsx: "JavaScript",
  cjs: "JavaScript",
  mjs: "JavaScript",
  rs: "Rust",
  py: "Python",
  py3: "Python",
  pyi: "Python",
  go: "Go",
  java: "Java",
  rb: "Ruby",
  rbw: "Ruby",
  cs: "CSharp",
  cpp: "Cpp",
  cc: "Cpp",
  cxx: "Cpp",
  c: "C",
  h: "C",
  css: "Css",
  html: "Html",
  htm: "Html",
  json: "Json",
  yml: "Yaml",
  yaml: "Yaml",
  lua: "Lua",
  scala: "Scala",
  sc: "Scala",
  swift: "Swift",
  kt: "Kotlin",
  kts: "Kotlin",
  elixir: "Elixir",
  ex: "Elixir",
  exs: "Elixir",
  hs: "Haskell",
  php: "PHP",
  sol: "Solidity",
  nix: "Nix",
  hcl: "Hcl",
  sh: "Bash",
  bash: "Bash",
};
