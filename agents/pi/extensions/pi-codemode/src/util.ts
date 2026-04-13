export const stripCodeFences = (code: string): string => {
  const trimmed = code.trim();
  const match = trimmed.match(/^(```|~~~)(?:\w+)?\r?\n([\s\S]+)\r?\n\1$/);
  if (match) return match[2].trim();
  return trimmed;
};
