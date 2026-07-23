/**
 * Low-level HTTP primitives for the shared fetch pipeline.
 */
export const USER_AGENTS = [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Safari/605.1.15",
];

export const DEFAULT_TIMEOUT_MS = 20_000;

/**
 * Create an AbortSignal that combines the caller's signal with a timeout.
 * Returns the combined signal and a cleanup function to clear the timeout.
 */
export function signalWithTimeout(
  signal: AbortSignal | undefined,
  timeoutMs: number = DEFAULT_TIMEOUT_MS,
): { signal: AbortSignal; cleanup: () => void } {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  const combined = signal
    ? AbortSignal.any([signal, controller.signal])
    : controller.signal;
  return {
    signal: combined,
    cleanup: () => clearTimeout(timeoutId),
  };
}

/**
 * Read a Response body as UTF-8 text, enforcing a byte limit.
 * Shared implementation used by both http.ts and fetch-content.ts.
 */
export async function readResponseBody(
  res: Response,
  maxBytes: number = 512 * 1024,
): Promise<string> {
  const chunks: Uint8Array[] = [];
  let total = 0;
  const reader = res.body?.getReader();
  if (!reader) return "";

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      chunks.push(value);
      total += value.length;
      if (total > maxBytes) {
        await reader.cancel().catch(() => {});
        break;
      }
    }
  } finally {
    reader.releaseLock?.();
  }

  return Buffer.concat(chunks).toString("utf-8");
}

/**
 * Whether a response body suggests a bot-blocking page.
 */
export function isBotBlocked(status: number, body: string): boolean {
  if (status === 403) return true;
  const lower = body.toLowerCase().slice(0, 2000);
  const signals = [
    "please complete the security check",
    "please enable javascript",
    "checking your browser",
    "cf-ray",
    "just a moment",
    "attention required",
    "verify you are human",
  ];
  return signals.some((s) => lower.includes(s));
}


