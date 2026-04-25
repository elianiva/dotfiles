export const stripCodeFences = (code: string): string => {
  const trimmed = code.trim();
  const match = trimmed.match(/^(```|~~~)(?:\w+)?\r?\n([\s\S]+)\r?\n\1$/);
  if (match) return match[2].trim();
  return trimmed;
};

export const buildPromptGuidelines = () => [
  "Write plain JavaScript body only. No imports/exports. No markdown fences",
  "Use things from tools.* namespace to access tools",
  "Only do filesystem related operations using tools.pi.*",
  "Never rely on bash if it can be done in JavaScript",
  "Batch related work in one codemode call",
  "Prefer tools.pi.read over shell commands: read({ offset, limit }) gives line ranges",
  "Prefer tools.pi.grep over grep: it returns structured results with line numbers",
  "Prefer tools.pi.count over wc: count({ type: 'line' | 'word' | 'byte', path }) for statistics",
  "Use bash only when no tools.pi.* equivalent exists (e.g., git, docker, build commands)",
];

export const formatError = (cause: unknown): string => {
  if (cause instanceof Error) return cause.message || cause.name;
  if (typeof cause === "string") return cause;
  try {
    return JSON.stringify(cause);
  } catch {
    return String(cause);
  }
};