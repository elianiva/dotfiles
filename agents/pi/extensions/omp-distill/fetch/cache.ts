import LRUCache from "lru-cache";

/**
 * Thin LRU cache wrapper keyed by URL string.
 * Caches the full response body (post-turndown) so repeated reads
 * of the same URL within a session avoid a network round-trip.
 */
export class UrlCache {
  readonly #cache: LRUCache<string, string>;

  constructor(maxSize = 50) {
    this.#cache = new LRUCache<string, string>({ max: maxSize });
  }

  get(url: string): string | undefined {
    return this.#cache.get(url);
  }

  set(url: string, body: string): void {
    this.#cache.set(url, body);
  }

  has(url: string): boolean {
    return this.#cache.has(url);
  }
}

/** Singleton shared across the extension. Reset on pi restart. */
export const urlCache = new UrlCache();
