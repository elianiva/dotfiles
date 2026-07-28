import { FileFinder } from "@ff-labs/fff-node";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { readFile, stat, realpath } from "node:fs/promises";
import path from "node:path";
import { homedir } from "node:os";

// --- constants ---

const DEFAULT_ROOT = path.join(homedir(), ".pi/agent/sessions");
const DEFAULT_MAX_BYTES = 5 * 1024 * 1024;
const MAX_RESULTS_HARD_CAP = 1000;
const DEFAULT_MAX_RESULTS = 20;

// --- helpers ---

function getRoot(): string {
	return process.env.PI_CODING_AGENT_SESSION_DIR || process.env.PI_SESSION_SEARCH_ROOT || DEFAULT_ROOT;
}

function getMaxBytes(): number {
	const v = Number.parseInt(process.env.PI_SESSION_SEARCH_MAX_BYTES || "", 10);
	return Number.isFinite(v) && v > 0 ? v : DEFAULT_MAX_BYTES;
}

function parseDateOrThrow(value: string | undefined, label: string): number {
	if (!value) return 0;
	const t = Date.parse(value);
	if (!Number.isFinite(t)) throw new Error(`Invalid ${label} "${value}": not a parseable date/time.`);
	return t;
}

function validateMaxResults(raw: unknown): number {
	if (raw === undefined || raw === null) return DEFAULT_MAX_RESULTS;
	if (typeof raw !== "number" || !Number.isFinite(raw) || !Number.isInteger(raw) || raw < 1 || raw > MAX_RESULTS_HARD_CAP)
		throw new Error(`maxResults must be an integer in [1, ${MAX_RESULTS_HARD_CAP}]; got ${String(raw)}`);
	return raw;
}

function extractText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	const parts: string[] = [];
	for (const block of content) {
		if (!block || typeof block !== "object") continue;
		const b = block as { type?: string; text?: string };
		if (b.type === "text" && typeof b.text === "string") parts.push(b.text);
	}
	return parts.join("\n");
}

interface ParsedQuery {
	pattern: string;
	mode: "fuzzy" | "plain" | "regex";
	regexObj?: RegExp;
}

function parseQuery(raw: string): ParsedQuery {
	const trimmed = raw.trim();
	const m = trimmed.match(/^\/(.+)\/([gimsuy]*)$/);
	if (m) {
		const flags = m[2].replace(/[gy]/g, "");
		try {
			const regexObj = new RegExp(m[1], flags);
			return { pattern: m[1], mode: "regex", regexObj };
		} catch (e) {
			throw new Error(`Invalid regex "${raw}": ${(e as Error).message}`);
		}
	}
	return { pattern: trimmed, mode: "fuzzy" };
}

function decodeSessionDirName(name: string): string {
	let s = name;
	if (s.startsWith("--")) s = s.slice(2);
	if (s.endsWith("--")) s = s.slice(0, -2);
	return "/" + s.replace(/-/g, "/");
}

/**
 * Check if text contains the query pattern. Used to verify a match after
 * parsing a JSONL line that fff flagged (since fff's lineContent may be
 * truncated and unparseable).
 */
function textMatches(text: string, parsed: ParsedQuery): boolean {
	switch (parsed.mode) {
		case "regex":
			return parsed.regexObj ? parsed.regexObj.test(text) : text.includes(parsed.pattern);
		case "plain":
			return text.toLowerCase().includes(parsed.pattern.toLowerCase());
		case "fuzzy":
		default: {
			// simple token-level substring check: all query words must appear in text
			const terms = parsed.pattern.toLowerCase().split(/\s+/).filter(Boolean);
			const lower = text.toLowerCase();
			return terms.every((t) => lower.includes(t));
		}
	}
}

// --- fff lifecycle ---

let _finder: FileFinder | null = null;
let _finderRoot: string = "";

function destroyFinder(): void {
	if (_finder) {
		_finder.destroy();
		_finder = null;
		_finderRoot = "";
	}
}

async function getFinder(): Promise<FileFinder> {
	const root = getRoot();
	if (_finder && _finderRoot === root && !_finder.isDestroyed) return _finder;
	destroyFinder();
	const result = FileFinder.create({ basePath: root, disableWatch: true, disableContentIndexing: true });
	if (!result.ok) throw new Error(`FFF init failed: ${result.error}`);
	_finder = result.value;
	_finderRoot = root;
	await _finder.waitForScan(5000).catch(() => {});
	return _finder;
}

// --- session file parsing ---

interface SessionHeader {
	id: string;
	cwd: string;
	started: string;
}

interface MessageEntry {
	timestamp: string;
	role: "user" | "assistant";
	text: string;
}

/**
 * Parse a session JSONL file and return the header and all message entries.
 */
function parseSessionFile(raw: string): { header: SessionHeader; messages: MessageEntry[] } {
	const header: SessionHeader = { id: "", cwd: "", started: "" };
	const messages: MessageEntry[] = [];
	for (const line of raw.split("\n")) {
		if (!line) continue;
		let obj: any;
		try { obj = JSON.parse(line); } catch { continue; }
		if (obj.type === "session") {
			header.id = String(obj.id ?? "");
			header.cwd = String(obj.cwd ?? "");
			header.started = String(obj.timestamp ?? "");
			continue;
		}
		if (obj.type !== "message") continue;
		const msg = obj.message;
		if (!msg) continue;
		const role = msg.role;
		if (role !== "user" && role !== "assistant") continue;
		const text = extractText(msg.content);
		if (!text) continue;
		messages.push({ timestamp: String(obj.timestamp ?? ""), role, text });
	}
	return { header, messages };
}

// --- search ---

export interface Hit {
	sessionFile: string;
	sessionId: string;
	sessionCwd: string;
	timestamp: string;
	role: string;
	snippet: string;
}

export interface SearchResult {
	hits: Hit[];
	scannedFiles: number;
	truncated: boolean;
}

export interface SearchOptions {
	query: string;
	cwd?: string;
	since?: string;
	until?: string;
	role?: "user" | "assistant" | "any";
	maxResults?: number;
	excludeSessionId?: string;
	signal?: AbortSignal;
}

export async function searchSessions(opts: SearchOptions): Promise<SearchResult> {
	const parsed = parseQuery(opts.query);
	const max = validateMaxResults(opts.maxResults);
	const sinceMs = parseDateOrThrow(opts.since, "since");
	const untilMs = parseDateOrThrow(opts.until, "until");
	const roleFilter = opts.role ?? "any";
	const hits: Hit[] = [];
	let truncated = false;

	// Step 1: use fff to find files with matches (fast SIMD grep)
	const finder = await getFinder();
	const grepQuery = `*.jsonl ${parsed.pattern}`;
	const grepResult = finder.grep(grepQuery, {
		mode: parsed.mode === "regex" ? "regex" : "fuzzy",
		smartCase: true,
		timeBudgetMs: 10000,
		maxFileSize: getMaxBytes(),
		maxMatchesPerFile: 100,
		pageSize: max * 5,
	});
	if (!grepResult.ok) throw new Error(`Search failed: ${grepResult.error}`);

	// Collect unique files from matches
	const fileSet = new Set<string>();
	for (const m of grepResult.value.items) fileSet.add(m.relativePath);
	const files = Array.from(fileSet);

	// Step 2: for each matching file, parse and find exact matches
	for (const file of files) {
		if (opts.signal?.aborted) break;
		if (hits.length >= max) { truncated = true; break; }

		const filePath = path.join(getRoot(), file);
		let raw: string;
		try { raw = await readFile(filePath, "utf8"); } catch { continue; }

		const { header, messages } = parseSessionFile(raw);

		// apply file-level filters
		if (opts.excludeSessionId && header.id === opts.excludeSessionId) continue;
		if (opts.cwd && !header.cwd.includes(opts.cwd) && !file.includes(opts.cwd)) continue;
		const headerTs = Date.parse(header.started);
		if (sinceMs && !Number.isNaN(headerTs) && headerTs < sinceMs) continue;
		if (untilMs && !Number.isNaN(headerTs) && headerTs > untilMs) continue;

		for (const msg of messages) {
			if (hits.length >= max) { truncated = true; break; }
			if (roleFilter !== "any" && msg.role !== roleFilter) continue;
			if (!textMatches(msg.text, parsed)) continue;

			hits.push({
				sessionFile: file,
				sessionId: header.id,
				sessionCwd: header.cwd || decodeSessionDirName(path.dirname(file)),
				timestamp: msg.timestamp,
				role: msg.role,
				snippet: msg.text.length > 400 ? msg.text.slice(0, 400) + "…" : msg.text,
			});
		}
	}

	// sort newest first
	hits.sort((a, b) => {
		const ta = Date.parse(a.timestamp);
		const tb = Date.parse(b.timestamp);
		return (Number.isFinite(tb) ? tb : 0) - (Number.isFinite(ta) ? ta : 0);
	});

	return { hits, scannedFiles: files.length, truncated };
}

// --- read session window ---

export async function readSessionWindow(opts: {
	sessionFile: string;
	aroundTimestamp?: string;
	contextMessages?: number;
	maxMessages?: number;
}): Promise<string> {
	const input = opts.sessionFile;
	const root = getRoot();
	const candidate = path.isAbsolute(input) ? input : path.join(root, input);
	const resolvedRoot = await realpath(root).catch(() => path.resolve(root));
	const resolvedFile = await realpath(candidate).catch(() => path.resolve(candidate));
	if (!resolvedFile.startsWith(resolvedRoot + path.sep) && resolvedFile !== resolvedRoot) {
		throw new Error(`Refusing to read outside session root: ${resolvedRoot}`);
	}
	const maxBytes = getMaxBytes();
	const st = await stat(resolvedFile);
	if (st.size > maxBytes) {
		throw new Error(`Session file too large: ${st.size} bytes (max ${maxBytes}). Raise PI_SESSION_SEARCH_MAX_BYTES.`);
	}
	const raw = await readFile(resolvedFile, "utf8");
	const { header, messages } = parseSessionFile(raw);

	let startIdx = 0;
	let endIdx = messages.length;
	const ctx = opts.contextMessages ?? 6;
	const max = opts.maxMessages ?? 30;

	if (opts.aroundTimestamp) {
		const target = Date.parse(opts.aroundTimestamp);
		if (Number.isFinite(target)) {
			let nearest = 0, bestDiff = Infinity;
			for (let i = 0; i < messages.length; i++) {
				const diff = Math.abs(Date.parse(messages[i].timestamp) - target);
				if (diff < bestDiff) { bestDiff = diff; nearest = i; }
			}
			startIdx = Math.max(0, nearest - ctx);
			endIdx = Math.min(messages.length, nearest + ctx + 1);
		}
	}
	if (endIdx - startIdx > max) endIdx = startIdx + max;

	const out: string[] = [];
	if (header.id) out.push(`# Session ${header.id} — cwd: ${header.cwd} — started: ${header.started}`);
	out.push(`# Showing messages ${startIdx + 1}–${endIdx} of ${messages.length}`);
	out.push("");
	for (let i = startIdx; i < endIdx; i++) {
		const msg = messages[i];
		const ts = new Date(Date.parse(msg.timestamp)).toISOString();
		out.push(`## ${msg.role} @ ${ts}`);
		out.push(msg.text);
		out.push("");
	}
	return out.join("\n");
}

// --- formatting ---

function formatHitsForLLM(result: SearchResult): string {
	return JSON.stringify({
		count: result.hits.length,
		truncated: result.truncated,
		scannedFiles: result.scannedFiles,
		hits: result.hits,
	}, null, 2);
}

function getCurrentSessionId(ctx: ExtensionContext): string | undefined {
	try {
		const header = (ctx.sessionManager as { getHeader?: () => { id?: string } | null }).getHeader?.();
		return header?.id;
	} catch { return undefined; }
}

// --- extension entry point ---

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "search_sessions",
		label: "Search prior pi sessions",
		description:
			"Search past pi session transcripts (~/.pi/agent/sessions) for a topic. Uses fff (SIMD-accelerated fuzzy finder) for fast, typo-tolerant file discovery. " +
			"Use when the user asks 'have we discussed X before?', 'what did we decide about Y?', or wants to find a prior session without resuming it. Read-only.",
		promptSnippet: "Find prior pi sessions matching a query.",
		promptGuidelines: [
			"Use search_sessions when the user references prior conversations or asks if a topic was discussed before.",
			"Pass a focused `query` (substring or `/regex/flags`). Narrow with `cwd` if you know which project.",
			"After a promising hit, call read_session with the returned `sessionFile` (and optionally `aroundTimestamp`) to pull more context.",
		],
		parameters: Type.Object({
			query: Type.String({
				description:
					"Plain text (fuzzy, typo-tolerant) or `/regex/flags` form. Regex flags `g` and `y` are stripped; case-sensitivity in regex form is honored (use `/Foo/i` for case-insensitive). " +
					"Searches user/assistant message text. Fuzzy mode handles typos gracefully.",
			}),
			cwd: Type.Optional(
				Type.String({
					description: "Filter sessions by working directory (substring match against the session's cwd, e.g. 'OneAdobe' or '/home/user/workspace').",
				}),
			),
			since: Type.Optional(
				Type.String({ description: "ISO date/time; ignore sessions started before this." }),
			),
			until: Type.Optional(
				Type.String({ description: "ISO date/time; ignore sessions started after this." }),
			),
			role: Type.Optional(
				Type.Union([Type.Literal("user"), Type.Literal("assistant"), Type.Literal("any")], {
					description: "Restrict matches to user messages, assistant messages, or both. Default: any.",
				}),
			),
			maxResults: Type.Optional(
				Type.Integer({
					minimum: 1,
					maximum: MAX_RESULTS_HARD_CAP,
					description: `Maximum number of hits to return. Default ${DEFAULT_MAX_RESULTS}, hard cap ${MAX_RESULTS_HARD_CAP}.`,
				}),
			),
			includeCurrentSession: Type.Optional(
				Type.Boolean({ description: "Include the current session in results. Default false." }),
			),
		}),
		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const query = String(params.query ?? "").trim();
			if (!query) return { content: [{ type: "text", text: "Error: `query` is required." }], details: {}, isError: true };
			const excludeSessionId = params.includeCurrentSession ? undefined : getCurrentSessionId(ctx);
			try {
				const result = await searchSessions({
					query,
					cwd: params.cwd as string | undefined,
					since: params.since as string | undefined,
					until: params.until as string | undefined,
					role: params.role as "user" | "assistant" | "any" | undefined,
					maxResults: params.maxResults as number | undefined,
					excludeSessionId,
					signal,
				});
				return {
					content: [{ type: "text", text: formatHitsForLLM(result) }],
					details: { count: result.hits.length, truncated: result.truncated },
				};
			} catch (e) {
				return { content: [{ type: "text", text: `search_sessions failed: ${(e as Error).message}` }], details: {}, isError: true };
			}
		},
	});

	pi.registerTool({
		name: "read_session",
		label: "Read a window of a prior pi session",
		description:
			"Read a slice of a prior pi session transcript. Use after search_sessions returns a promising hit to pull surrounding context. Read-only.",
		promptSnippet: "Read a window from a prior pi session JSONL file.",
		promptGuidelines: [
			"Pass `sessionFile` exactly as returned by search_sessions.",
			"If you have a hit's `timestamp`, pass it as `aroundTimestamp` to center the window on it.",
			"Keep `maxMessages` modest — these transcripts can be huge.",
		],
		parameters: Type.Object({
			sessionFile: Type.String({
				description: "Path to a session .jsonl file. Either absolute, or relative to the configured sessions root (as returned by search_sessions).",
			}),
			aroundTimestamp: Type.Optional(
				Type.String({ description: "ISO timestamp to center the window on (e.g. a hit's timestamp)." }),
			),
			contextMessages: Type.Optional(
				Type.Number({ description: "Messages of context on each side of the target. Default 6." }),
			),
			maxMessages: Type.Optional(
				Type.Number({ description: "Hard cap on returned messages. Default 30." }),
			),
		}),
		async execute(_toolCallId, params) {
			try {
				const text = await readSessionWindow({
					sessionFile: String(params.sessionFile),
					aroundTimestamp: params.aroundTimestamp as string | undefined,
					contextMessages: params.contextMessages as number | undefined,
					maxMessages: params.maxMessages as number | undefined,
				});
				return { content: [{ type: "text", text }], details: {} };
			} catch (e) {
				return { content: [{ type: "text", text: `read_session failed: ${(e as Error).message}` }], details: {}, isError: true };
			}
		},
	});

	pi.on("session_shutdown", () => { destroyFinder(); });
}
