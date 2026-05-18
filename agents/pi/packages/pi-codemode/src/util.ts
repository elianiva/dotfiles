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
  "Output visibility: use `return value` to show output visibly, use `console.log(value)` for logs.",
  "Bare expressions like `result;` or string tricks like `'' + result` are silently swallowed.",
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

