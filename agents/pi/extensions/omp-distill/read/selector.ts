/**
 * URL read-selector parsing for protocol handlers.
 *
 * Extracts `:raw`, `:N`, `:N-M`, `:N+K` suffixes from read paths.
 */
export interface ParsedReadSelector {
  basePath: string;
  raw: boolean;
  offset?: number;
  limit?: number;
}

export function parseReadSelector(path: string): ParsedReadSelector {
  let raw = false;
  let offset: number | undefined;
  let limit: number | undefined;
  let basePath = path;

  while (true) {
    const colonIdx = basePath.lastIndexOf(":");
    if (colonIdx < 0) break;

    const tail = basePath.slice(colonIdx + 1);
    const candidate = basePath.slice(0, colonIdx);

    if (tail.toLowerCase() === "raw") {
      raw = true;
      basePath = candidate;
      continue;
    }

    const rangeMatch = tail.match(/^(\d+)(?:-(\d+))?$/);
    if (rangeMatch) {
      offset = parseInt(rangeMatch[1], 10);
      if (rangeMatch[2] !== undefined) {
        limit = parseInt(rangeMatch[2], 10) - offset + 1;
      }
      basePath = candidate;
      continue;
    }

    const plusMatch = tail.match(/^(\d+)\+(\d+)$/);
    if (plusMatch) {
      offset = parseInt(plusMatch[1], 10);
      limit = parseInt(plusMatch[2], 10);
      basePath = candidate;
      continue;
    }

    break;
  }

  return { basePath, raw, offset, limit };
}
