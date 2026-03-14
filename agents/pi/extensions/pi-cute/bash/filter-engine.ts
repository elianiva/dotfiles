export type ReplaceRule = {
  pattern: RegExp;
  replacement: string;
};

export type MatchOutputRule = {
  pattern: RegExp;
  message: string;
  unless?: RegExp;
};

export type OutputFilters = {
  stripAnsi?: boolean;
  replace?: ReplaceRule[];
  matchOutput?: MatchOutputRule[];
  stripLinesMatching?: RegExp[];
  keepLinesMatching?: RegExp[];
  truncateLinesAt?: number;
  headLines?: number;
  tailLines?: number;
  maxLines?: number;
  onEmpty?: string;
};

const ESC = String.fromCharCode(27);
const ANSI_RE = new RegExp(`${ESC}\\[[0-9;]*[a-zA-Z]`, "g");

function truncateLine(text: string, max: number): string {
  if (max <= 3) return "...";
  const chars = [...text];
  if (chars.length <= max) return text;
  return `${chars.slice(0, max - 3).join("")}...`;
}

export function applyOutputFilters(input: string, filters?: OutputFilters): string {
  if (!filters) return input;
  if (filters.stripLinesMatching?.length && filters.keepLinesMatching?.length) {
    throw new Error("stripLinesMatching and keepLinesMatching are mutually exclusive");
  }

  let lines = input.split("\n");

  if (filters.stripAnsi) {
    lines = lines.map((line) => line.replace(ANSI_RE, ""));
  }

  if (filters.replace?.length) {
    lines = lines.map((line) => {
      let out = line;
      for (const rule of filters.replace ?? []) out = out.replace(rule.pattern, rule.replacement);
      return out;
    });
  }

  if (filters.matchOutput?.length) {
    const blob = lines.join("\n");
    for (const rule of filters.matchOutput) {
      if (!rule.pattern.test(blob)) continue;
      if (rule.unless && rule.unless.test(blob)) continue;
      return rule.message;
    }
  }

  if (filters.stripLinesMatching?.length) {
    lines = lines.filter((line) => !filters.stripLinesMatching?.some((re) => re.test(line)));
  } else if (filters.keepLinesMatching?.length) {
    lines = lines.filter((line) => filters.keepLinesMatching?.some((re) => re.test(line)));
  }

  const truncateLinesAt = filters.truncateLinesAt;
  if (truncateLinesAt !== undefined) {
    lines = lines.map((line) => truncateLine(line, truncateLinesAt));
  }

  const total = lines.length;
  if (filters.headLines !== undefined && filters.tailLines !== undefined) {
    if (total > filters.headLines + filters.tailLines) {
      const omitted = total - filters.headLines - filters.tailLines;
      lines = [
        ...lines.slice(0, filters.headLines),
        `... (${omitted} lines omitted)`,
        ...lines.slice(total - filters.tailLines),
      ];
    }
  } else if (filters.headLines !== undefined) {
    if (total > filters.headLines) {
      const omitted = total - filters.headLines;
      lines = [...lines.slice(0, filters.headLines), `... (${omitted} lines omitted)`];
    }
  } else if (filters.tailLines !== undefined) {
    if (total > filters.tailLines) {
      const omitted = total - filters.tailLines;
      lines = [`... (${omitted} lines omitted)`, ...lines.slice(total - filters.tailLines)];
    }
  }

  if (filters.maxLines !== undefined && lines.length > filters.maxLines) {
    const truncated = lines.length - filters.maxLines;
    lines = [...lines.slice(0, filters.maxLines), `... (${truncated} lines truncated)`];
  }

  const result = lines.join("\n");
  if (result.trim().length === 0 && filters.onEmpty) return filters.onEmpty;
  return result;
}
