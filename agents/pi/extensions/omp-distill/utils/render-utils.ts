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
