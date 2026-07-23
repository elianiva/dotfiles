/**
 * URL protocol detection helpers shared across protocol handlers.
 */

const INTERNAL_SCHEME_RE = /^([a-z][a-z0-9+.-]*):\/\//i;

/** Recognised internal URL schemes this extension handles. */
const HANDLED_SCHEMES = new Set(["skill", "pi", "issue", "pr", "conflict"]);

/** Check if a path is an HTTP(S) URL. */
export function isHttpUrl(path: string): boolean {
  return /^https?:\/\//i.test(path);
}

/** Check if a path is a handled internal protocol URL. */
export function isHandledInternalUrl(path: string): boolean {
  const m = path.match(INTERNAL_SCHEME_RE);
  if (!m) return false;
  return HANDLED_SCHEMES.has(m[1].toLowerCase());
}

/** Check if a path is *any* internal URL (including unhandled ones, for routing order). */
export function isAnyInternalUrl(path: string): boolean {
  return INTERNAL_SCHEME_RE.test(path);
}

/** Parse a `scheme://rest` URL into its parts. */
export interface ParsedInternalUrl {
  scheme: string;
  host: string;
  pathname: string;
}

export function parseInternalUrl(raw: string): ParsedInternalUrl {
  const m = raw.match(INTERNAL_SCHEME_RE);
  if (!m) throw new Error(`Not an internal URL: ${raw}`);
  const scheme = m[1].toLowerCase();
  const rest = raw.slice(m[0].length);
  const slashIdx = rest.indexOf("/");
  const host = slashIdx === -1 ? rest : rest.slice(0, slashIdx);
  const pathname = slashIdx === -1 ? "" : rest.slice(slashIdx + 1);
  return { scheme, host, pathname };
}

/**
 * Extract a URL-selector suffix (:raw, :50-100) from the tail of a read path.
 * Returns the cleaned base path and parsed selector, or null when there is no
 * selector.
 */
export interface ParsedReadSelector {
  basePath: string;
  raw: boolean;
  offset?: number;
  limit?: number;
}

export function parseReadSelector(path: string): ParsedReadSelector {
  // Peel trailing `:raw` and `:N-M` / `:N` selectors. Walk back from the end.
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

    // Range like `:N+K`
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
