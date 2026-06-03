/**
 * Auto-generates session titles.
 *
 * - On first message: generates title in background via gpt-4o-mini
 * - /rename-old-sessions: retroactively names unnamed sessions from last month
 */

import { complete } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// --- shared helpers ---

function extractText(content: unknown): string | null {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return null;
	for (const block of content) {
		if (block?.type === "text" && typeof block.text === "string") return block.text;
	}
	return null;
}

function stripSkillBlocks(text: string): string {
	return text.replace(/<skill[\s\S]*?<\/skill>/gi, "").replace(/\s+/g, " ").trim();
}

function hasSessionName(jsonl: string): boolean {
	for (const line of jsonl.split("\n")) {
		if (!line) continue;
		try {
			const entry = JSON.parse(line);
			if (entry.type === "session_info" && typeof entry.name === "string" && entry.name.length > 0) {
				return true;
			}
		} catch { /* skip malformed lines */ }
	}
	return false;
}

function findFirstUserText(jsonl: string): string | null {
	for (const line of jsonl.split("\n")) {
		if (!line) continue;
		try {
			const entry = JSON.parse(line);
			if (entry.type === "message" && entry.message?.role === "user") {
				return extractText(entry.message.content);
			}
		} catch { /* skip */ }
	}
	return null;
}

function lastEntryId(jsonl: string): string | null {
	let last: string | null = null;
	for (const line of jsonl.split("\n")) {
		if (!line) continue;
		try {
			const entry = JSON.parse(line);
			if (entry.id) last = entry.id;
		} catch { /* skip */ }
	}
	return last;
}

function buildSessionDisplayName(title: string, firstMessage: string): string {
	const snippet = firstMessage.replace(/\s+/g, " ").trim().slice(0, 60);
	return `${title} — ${snippet}${firstMessage.length > 60 ? "…" : ""}`;
}

function generateSessionInfo(id: string, parentId: string | null, name: string): string {
	return JSON.stringify({
		type: "session_info",
		id,
		parentId,
		timestamp: new Date().toISOString(),
		name,
	});
}

async function generateTitle(text: string, ctx: { modelRegistry: ExtensionAPI["modelRegistry"]; model: ExtensionAPI["model"] }): Promise<string | null> {
	const model = ctx.model;
	if (!model) return null;

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
	if (!auth?.ok || !auth.apiKey) return null;

	const truncated = text.slice(0, 2000);
	const response = await complete(
		model,
		{
			messages: [
				{
					role: "user",
					content: [
						{
							type: "text",
							text: `Generate a short but descriptive session title (5-12 words) for this conversation. Be specific enough to distinguish it from similar topics. Include key terms, file names, or project context when present. Reply ONLY with the title, no quotes, no punctuation, no extra text.\n\n${truncated}`,
						},
					],
				},
			],
		},
		{ apiKey: auth.apiKey, headers: auth.headers },
	);

	return response.content
		.filter((c): c is { type: "text"; text: string } => c.type === "text")
		.map((c) => c.text)
		.join("")
		.trim()
		.replace(/^["']|["']$/g, "")
		.slice(0, 80) || null;
}

function randomHex8(): string {
	return Math.random().toString(16).slice(2, 10);
}

// --- extension ---

export default function (pi: ExtensionAPI) {
	let titled = false;

	// Auto-title on first message
	pi.on("agent_end", async (_event, ctx) => {
		if (titled || pi.getSessionName()) return;

		const entries = ctx.sessionManager.getBranch();
		const firstUser = entries.find((e) => e.type === "message" && e.message?.role === "user");
		if (!firstUser) return;
		titled = true;

		const text = extractText(firstUser.message!.content);
		if (!text || text.trim().length < 10) return;

		const cleanText = stripSkillBlocks(text);
		if (!cleanText || cleanText.length < 10) return;

		generateTitle(cleanText, ctx).then((title) => {
			if (title) pi.setSessionName(buildSessionDisplayName(title, cleanText));
		}).catch(() => {});
	});

	pi.on("session_start", async (event) => {
		if (event.reason === "new") {
			titled = false;
		} else {
			titled = !!pi.getSessionName();
		}
	});

	// Retroactive naming for unnamed sessions in the last month
	// Usage: /rename-old-sessions [--force] [--dry-run]
	pi.registerCommand("rename-old-sessions", {
		description: "Generate titles for unnamed sessions active in the last 30 days",
		handler: async (args, ctx) => {
			const fs = await import("node:fs/promises");
			const pathMod = await import("node:path");
			const { SessionManager } = await import("@earendil-works/pi-coding-agent");

			const flags = new Set(args.split(/\s+/).filter(Boolean));
			const force = flags.has("--force");
			const dryRun = flags.has("--dry-run");

			const sessions = await SessionManager.list(ctx.cwd);
			const cutoff = Date.now() - 30 * 24 * 60 * 60 * 1000;

			const candidates: Array<{ path: string; jsonl: string; mtime: number }> = [];

			for (const s of sessions) {
				const stat = await fs.stat(s.path).catch(() => null);
				if (!stat || stat.mtimeMs < cutoff) continue;

				const jsonl = await fs.readFile(s.path, "utf8").catch(() => "");
				if (!jsonl) continue;
				if (!force && hasSessionName(jsonl)) continue;

				const text = findFirstUserText(jsonl);
				if (!text || text.trim().length < 10) continue;

				candidates.push({ path: s.path, jsonl, mtime: stat.mtimeMs });
			}

			if (candidates.length === 0) {
				ctx.ui.notify(`No sessions to rename (${force ? "force" : "unnamed"}, last 30d)`, "info");
				return;
			}

			if (dryRun) {
				for (const c of candidates) {
					const text = findFirstUserText(c.jsonl)!;
					const name = pathMod.basename(c.path, ".jsonl").slice(0, 40);
					ctx.ui.notify(`${name} (${text.slice(0, 40)}…)`, "info");
				}
				ctx.ui.notify(`${candidates.length} session(s) would be renamed`, "info");
				return;
			}

			ctx.ui.notify(`Renaming ${candidates.length} session(s)...`, "info");

			let ok = 0, fail = 0;

			for (const c of candidates) {
				const text = findFirstUserText(c.jsonl);
				const cleanText = text ? stripSkillBlocks(text) : null;
				const title = cleanText ? await generateTitle(cleanText, ctx) : null;
				if (!title) { fail++; continue; }

				const parentId = lastEntryId(c.jsonl);
				const displayName = buildSessionDisplayName(title, cleanText!);
				const entry = generateSessionInfo(randomHex8(), parentId, displayName);

				await fs.appendFile(c.path, "\n" + entry, "utf8").catch(() => null);

				const name = pathMod.basename(c.path, ".jsonl").slice(0, 40);
				ctx.ui.notify(`${name} → ${title}`, "info");
				ok++;
			}

			ctx.ui.notify(`Done: ${ok} renamed, ${fail} failed`, "info");
		},
	});
}
