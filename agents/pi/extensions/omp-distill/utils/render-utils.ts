/**
 * Shared rendering primitives for TUI tool output.
 *
 * Import Theme from the SDK instead of redefining it in every tool file.
 */
export type { Theme } from "@earendil-works/pi-coding-agent";

function truncate(str: string, maxLen: number, ellipsis = "…"): string {
  if (str.length <= maxLen) return str;
  const sliceLen = Math.max(0, maxLen - ellipsis.length);
  return `${str.slice(0, sliceLen)}${ellipsis}`;
}

/**
 * Render a text-mode progress bar.
 * @example progressBar(0.3) → "███░░░░░░░"
 */
export function progressBar(fraction: number, size = 10): string {
  const filled = Math.floor(Math.max(0, Math.min(1, fraction)) * size);
  return "\u2588".repeat(filled) + "\u2591".repeat(size - filled);
}

/**
 * Format a count with label, pluralizing when needed.
 * @example formatCount("source", 3) → "3 sources"
 */
export function formatCount(label: string, count: number): string {
  return `${count} ${label}${count === 1 ? "" : "s"}`;
}

/**
 * Extract domain from a URL string.
 * @example getDomain("https://www.example.com/path") → "example.com"
 */
export function getDomain(url: string): string {
  try {
    const u = new URL(url);
    return u.hostname.replace(/^www\./, "");
  } catch {
    return url;
  }
}

/**
 * Format an age in seconds as a human-readable relative time string.
 * Returns empty string when age is undefined or negative.
 * @example formatAge(7200) → "2h ago"
 */
export function formatAge(ageSeconds?: number): string {
  if (ageSeconds === undefined || ageSeconds < 0) return "";
  if (ageSeconds < 60) return "just now";
  if (ageSeconds < 3600) return `${Math.floor(ageSeconds / 60)}m ago`;
  if (ageSeconds < 86400) return `${Math.floor(ageSeconds / 3600)}h ago`;
  if (ageSeconds < 2592000) return `${Math.floor(ageSeconds / 86400)}d ago`;
  if (ageSeconds < 31536000) return `${Math.floor(ageSeconds / 2592000)}mo ago`;
  return `${Math.floor(ageSeconds / 31536000)}y ago`;
}

/**
 * Format a published date string as a relative age.
 * Returns the raw date string when parsing fails.
 */
export function formatPublishedDate(publishedDate?: string): string {
  if (!publishedDate) return "";
  const date = new Date(publishedDate);
  if (isNaN(date.getTime())) return publishedDate;
  const ageSeconds = (Date.now() - date.getTime()) / 1000;
  return formatAge(ageSeconds) || publishedDate;
}

/**
 * Create a styled status icon string.
 */
export function formatStatusIcon(
  type: "success" | "error" | "warning" | "pending" | "info",
  theme: { fg: (c: string, t: string) => string },
): string {
  switch (type) {
    case "success": return theme.fg("success", "\u2713");
    case "error": return theme.fg("error", "\u2717");
    case "warning": return theme.fg("warning", "\u26A0");
    case "pending": return theme.fg("accent", "\u25CB");
    case "info": return theme.fg("accent", "\u2139");
  }
}

/**
 * Format an expand hint based on current state.
 */
export function formatExpandHint(
  theme: { fg: (c: string, t: string) => string },
  expanded: boolean,
  hasMore = true,
): string {
  if (!hasMore) return "";
  return expanded
    ? ` ${theme.fg("dim", "(collapsed)")}`
    : ` ${theme.fg("dim", "(to expand)")}`;
}

export { truncate };
