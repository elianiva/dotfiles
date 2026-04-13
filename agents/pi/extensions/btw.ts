/**
 * BTW (By The Way) Extension - Interactive Side Chat
 *
 * Creates parallel conversation threads that don't interrupt the main session.
 * Each side chat forks the current context and runs in a separate process.
 *
 * Usage:
 *   /btw [question]         - Start/resume a side chat (opens overlay)
 *   /btw-list               - List active side chats
 *   /btw-resume [id]        - Resume a side chat by ID
 *   /btw-close <id>         - Close a side chat
 *
 * In the side chat overlay:
 *   - Type messages and press Enter to send
 *   - Esc to hide the overlay (chat continues in background)
 *   - Ctrl+C to close the side chat entirely
 */

import type { ExtensionAPI, ExtensionCommandContext, Theme } from "@mariozechner/pi-coding-agent";
import type { Message, TextContent } from "@mariozechner/pi-ai";
import { CURSOR_MARKER, type Focusable, matchesKey, truncateToWidth } from "@mariozechner/pi-tui";
import { spawn, type ChildProcess } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

interface SideChat {
	id: string;
	topic: string;
	startTime: number;
	process: ChildProcess | null;
	stdin: NodeJS.WritableStream | null;
	messages: { role: "user" | "assistant"; content: string }[];
	status: "running" | "closed" | "error";
	error?: string;
	pendingResponse: boolean;
	buffer: string;
}

const activeChats = new Map<string, SideChat>();
let chatCounter = 0;

function generateId(): string {
	return `btw-${Date.now()}-${++chatCounter}`;
}

function formatTime(ms: number): string {
	const date = new Date(ms);
	return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function getContextMessages(ctx: ExtensionCommandContext): Message[] {
	const entries = ctx.sessionManager.getBranch();
	const messages: Message[] = [];
	for (const entry of entries) {
		if (entry.type !== "message") continue;
		if (entry.message.role === "system") continue;
		messages.push({ role: entry.message.role, content: entry.message.content });
	}
	return messages.slice(-15);
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	if (currentScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}
	return { command: "pi", args };
}

async function createSideChat(
	id: string,
	topic: string,
	contextMessages: Message[],
	cwd: string,
	onMessage: (chat: SideChat, role: "assistant" | "error", content: string) => void,
): Promise<SideChat | null> {
	const args = ["--mode", "json", "--no-session"];

	const contextSummary = contextMessages
		.map((m) => {
			const content = m.content
				.filter((c): c is TextContent => c.type === "text")
				.map((c) => c.text)
				.join(" ")
				.slice(0, 400);
			return `[${m.role}]: ${content}`;
		})
		.join("\n");

	const systemPrompt = `This is a side conversation ("by the way") from a main coding session.

Context from main session (last ${contextMessages.length} messages):
${contextSummary || "(no previous context)"}

The user has started a parallel conversation thread. Respond concisely and helpfully.`;

	const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-btw-"));
	const systemPromptPath = path.join(tmpDir, "system-prompt.md");
	await fs.promises.writeFile(systemPromptPath, systemPrompt, { encoding: "utf-8", mode: 0o600 });

	args.push("--append-system-prompt", systemPromptPath);

	const invocation = getPiInvocation(args);

	return new Promise((resolve) => {
		const proc = spawn(invocation.command, invocation.args, {
			cwd,
			shell: false,
			stdio: ["pipe", "pipe", "pipe"],
		});

		const chat: SideChat = {
			id,
			topic,
			startTime: Date.now(),
			process: proc,
			stdin: proc.stdin,
			messages: [],
			status: "running",
			pendingResponse: false,
			buffer: "",
		};

		const processLine = (line: string) => {
			if (!line.trim()) return;
			let event: any;
			try {
				event = JSON.parse(line);
			} catch {
				return;
			}

			if (event.type === "agent_start") {
				chat.pendingResponse = true;
			} else if (event.type === "message_end" && event.message) {
				const msg = event.message as Message;
				if (msg.role === "assistant") {
					chat.pendingResponse = false;
					let content = "";
					for (const part of msg.content) {
						if (part.type === "text") content += part.text;
					}
					chat.messages.push({ role: "assistant", content });
					onMessage(chat, "assistant", content);
				}
			}
		};

		proc.stdout?.on("data", (data) => {
			chat.buffer += data.toString();
			const lines = chat.buffer.split("\n");
			chat.buffer = lines.pop() || "";
			for (const line of lines) processLine(line);
		});

		proc.on("error", () => {
			chat.status = "error";
			chat.error = "Failed to spawn side chat";
			onMessage(chat, "error", chat.error);
			resolve(null);
		});

		setTimeout(() => {
			if (proc.killed) {
				resolve(null);
			} else {
				resolve(chat);
			}
		}, 500);
	});
}

function sendMessage(chat: SideChat, message: string): void {
	if (!chat.stdin || chat.status !== "running") return;
	chat.messages.push({ role: "user", content: message });
	chat.pendingResponse = true;
	const payload = JSON.stringify({ type: "prompt", text: message }) + "\n";
	chat.stdin.write(payload);
}

function closeChat(chat: SideChat): void {
	if (chat.process && !chat.process.killed) {
		chat.process.kill("SIGTERM");
		setTimeout(() => {
			if (chat.process && !chat.process.killed) {
				chat.process.kill("SIGKILL");
			}
		}, 1000);
	}
	chat.status = "closed";
	chat.process = null;
	chat.stdin = null;
}

// Side Chat Overlay Component
class SideChatOverlay implements Focusable {
	readonly width = 80;
	focused = false;
	private inputText = "";
	private inputCursor = 0;
	private needsRerender = false;

	constructor(
		private theme: Theme,
		private chat: SideChat,
		private onSend: (text: string) => void,
		private onClose: () => void,
		private done: () => void,
	) {}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			this.done();
			return;
		}

		if (matchesKey(data, "ctrl+c")) {
			this.onClose();
			this.done();
			return;
		}

		if (matchesKey(data, "return") && this.inputText.trim()) {
			this.onSend(this.inputText.trim());
			this.inputText = "";
			this.inputCursor = 0;
			return;
		}

		if (matchesKey(data, "backspace")) {
			if (this.inputCursor > 0) {
				this.inputText = this.inputText.slice(0, this.inputCursor - 1) + this.inputText.slice(this.inputCursor);
				this.inputCursor--;
			}
		} else if (matchesKey(data, "left")) {
			this.inputCursor = Math.max(0, this.inputCursor - 1);
		} else if (matchesKey(data, "right")) {
			this.inputCursor = Math.min(this.inputText.length, this.inputCursor + 1);
		} else if (data.length === 1 && data.charCodeAt(0) >= 32) {
			this.inputText = this.inputText.slice(0, this.inputCursor) + data + this.inputText.slice(this.inputCursor);
			this.inputCursor++;
		}
	}

	render(_width: number): string[] {
		const w = this.width;
		const th = this.theme;
		const innerW = w - 4;
		const contentH = 15;

		const lines: string[] = [];
		const pad = (s: string, len: number) => {
			const truncated = truncateToWidth(s, len);
			return truncated + " ".repeat(Math.max(0, len - truncated.length));
		};

		const row = (content: string) => ` ${th.fg("border", "│")} ` + pad(content, innerW) + ` ${th.fg("border", "│")}`;

		lines.push(` ${th.fg("border", `╭${"─".repeat(innerW)}╮`)}`);
		lines.push(row(`${th.fg("accent", "🔄 BTW Side Chat")} ${th.fg("dim", `| ${this.chat.id}`)}`));
		lines.push(row(`${th.fg("dim", "Topic: ")}${truncateToWidth(this.chat.topic, innerW - 7)}`));
		lines.push(row(th.fg("dim", `Started: ${formatTime(this.chat.startTime)} | ${this.chat.messages.length} msgs`)));
		lines.push(` ${th.fg("border", `├${"─".repeat(innerW)}┤`)}`);

		// Messages
		const visibleMessages = this.chat.messages.slice(-contentH);
		for (let i = 0; i < contentH; i++) {
			const msg = visibleMessages[i];
			if (!msg) {
				lines.push(row(""));
				continue;
			}
			const prefix = msg.role === "user" ? th.fg("accent", "You: ") : th.fg("success", "AI: ");
			const content = msg.content.replace(/\n/g, " ");
			const line = prefix + th.fg("text", truncateToWidth(content, innerW - 5));
			lines.push(row(line));
		}

		// Status
		let status = "";
		if (this.chat.status === "error") {
			status = th.fg("error", `Error: ${truncateToWidth(this.chat.error || "Unknown", innerW - 7)}`);
		} else if (this.chat.pendingResponse) {
			status = th.fg("warning", "AI is thinking...");
		} else {
			status = th.fg("dim", "Ready");
		}
		lines.push(row(status));

		// Input
		lines.push(` ${th.fg("border", `├${"─".repeat(innerW)}┤`)}`);

		let inputDisplay = this.inputText;
		if (this.focused && this.inputCursor < inputDisplay.length) {
			const before = inputDisplay.slice(0, this.inputCursor);
			const at = inputDisplay[this.inputCursor];
			const after = inputDisplay.slice(this.inputCursor + 1);
			inputDisplay = before + CURSOR_MARKER + `\x1b[7m${at}\x1b[27m` + after;
		} else if (this.focused) {
			inputDisplay = inputDisplay + CURSOR_MARKER + "\x1b[7m \x1b[27m";
		}

		lines.push(row(th.fg("accent", "> ") + inputDisplay));
		lines.push(` ${th.fg("border", `├${"─".repeat(innerW)}┤`)}`);
		lines.push(row(th.fg("dim", "Enter to send | Esc to hide | Ctrl+C to close")));
		lines.push(` ${th.fg("border", `╰${"─".repeat(innerW)}╯`)}`);

		return lines;
	}

	invalidate(): void {
		this.needsRerender = true;
	}

	dispose(): void {}
}

export default function (pi: ExtensionAPI) {
	// Periodic cleanup
	setInterval(() => {
		const now = Date.now();
		for (const [id, chat] of activeChats) {
			if (chat.status !== "running" && now - chat.startTime > 86400000) {
				activeChats.delete(id);
			}
		}
	}, 60000);

	async function openSideChatOverlay(chat: SideChat, ctx: ExtensionCommandContext): Promise<void> {
		let overlay: SideChatOverlay | null = null;

		// Re-render overlay when messages update
		const _renderTrigger = { chat, overlay };

		await ctx.ui.custom<void>(
			(_tui, theme, _kb, done) => {
				overlay = new SideChatOverlay(
					theme,
					chat,
					(text) => sendMessage(chat, text),
					() => closeChat(chat),
					done,
				);
				return overlay;
			},
			{ overlay: true },
		);
	}

	// /btw [topic] - Start new side chat
	pi.registerCommand("btw", {
		description: "Start a side chat (doesn't interrupt main session)",
		handler: async (args, ctx) => {
			const topic = args.trim() || "Side discussion";
			const id = generateId();

			const contextMessages = getContextMessages(ctx);
			ctx.ui.notify(`Starting side chat ${id}...`, "info");

			const chat = await createSideChat(id, topic, contextMessages, ctx.cwd, (c, role, content) => {
				if (role === "assistant") {
					const preview = content.slice(0, 60).replace(/\n/g, " ");
					ctx.ui.notify(`[${c.id}] ${preview}...`, "info");
				}
			});

			if (!chat) {
				ctx.ui.notify("Failed to start side chat", "error");
				return;
			}

			activeChats.set(id, chat);

			// Send initial message if provided
			if (args.trim()) {
				sendMessage(chat, args.trim());
			}

			// Open overlay
			await openSideChatOverlay(chat, ctx);
		},
	});

	// /btw-list - List active side chats
	pi.registerCommand("btw-list", {
		description: "List active side chats",
		handler: async (_args, ctx) => {
			if (activeChats.size === 0) {
				ctx.ui.notify("No active side chats. Use /btw to start one.", "info");
				return;
			}

			const lines: string[] = [];
			for (const [id, chat] of activeChats) {
				const icon = chat.status === "running" ? "🔄" : chat.status === "error" ? "❌" : "✓";
				const msgCount = chat.messages.length;
				lines.push(`${icon} [${id}] ${chat.topic} (${msgCount} msgs)`);
			}
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});

	// /btw-resume [id] - Resume a side chat
	pi.registerCommand("btw-resume", {
		description: "Resume a side chat by ID (or most recent if no ID)",
		handler: async (args, ctx) => {
			let id = args.trim();

			if (!id) {
				// Find most recent running chat
				const running = Array.from(activeChats.values())
					.filter((c) => c.status === "running")
					.sort((a, b) => b.startTime - a.startTime)[0];

				if (!running) {
					ctx.ui.notify("No running side chats. Use /btw-list to see all.", "warning");
					return;
				}
				id = running.id;
			}

			const chat = activeChats.get(id);
			if (!chat) {
				ctx.ui.notify(`Side chat ${id} not found`, "error");
				return;
			}

			if (chat.status !== "running") {
				ctx.ui.notify(`Side chat ${id} is ${chat.status}`, "warning");
				return;
			}

			await openSideChatOverlay(chat, ctx);
		},
	});

	// /btw-close <id> - Close a side chat
	pi.registerCommand("btw-close", {
		description: "Close a side chat by ID",
		handler: async (args, ctx) => {
			const id = args.trim();
			if (!id) {
				ctx.ui.notify("Usage: /btw-close <id>", "warning");
				return;
			}

			const chat = activeChats.get(id);
			if (!chat) {
				ctx.ui.notify(`Side chat ${id} not found`, "error");
				return;
			}

			closeChat(chat);
			activeChats.delete(id);
			ctx.ui.notify(`Closed side chat ${id}`, "success");
		},
	});
}