export interface SearchResult {
  title: string;
  url: string;
  snippet: string;
}

export interface QueryResultData {
  query: string;
  answer: string;
  results: SearchResult[];
  error: string | null;
  provider?: string;
}

export interface StoredSearchData {
  id: string;
  type: "search";
  timestamp: number;
  queries: QueryResultData[];
}

const store = new Map<string, StoredSearchData>();

export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
}

export function storeResult(id: string, data: StoredSearchData): void {
  store.set(id, data);
}

export function getResult(id: string): StoredSearchData | null {
  return store.get(id) ?? null;
}

export function clearResults(): void {
  store.clear();
}
