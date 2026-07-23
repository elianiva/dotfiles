import { execFileSync, execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

let cached = false;
let available = false;

export function isHerdrAvailable(): boolean {
	if (cached) return available;
	try {
		execFileSync("herdr", ["--version"], { stdio: "ignore" });
		available = process.env.HERDR_ENV === "1";
	} catch {
		available = false;
	}
	cached = true;
	return available;
}

export function herdrSync(args: string[]): string {
	return execFileSync("herdr", args, { encoding: "utf8" });
}

export async function herdrAsync(args: string[]): Promise<string> {
	const { stdout } = await execFileAsync("herdr", args, { encoding: "utf8" });
	return stdout;
}

function parseJson(raw: string): unknown {
	try { return JSON.parse(raw); } catch { return null; }
}

export interface PaneInfo {
	paneId: string; tabId: string; workspaceId: string;
}

/** Get current pane context from env vars, falling back to `herdr pane current`. */
export function getCurrentPane(): PaneInfo {
	const paneId = process.env.HERDR_PANE_ID;
	const tabId = process.env.HERDR_TAB_ID;
	const workspaceId = process.env.HERDR_WORKSPACE_ID;
	if (paneId && tabId && workspaceId) return { paneId, tabId, workspaceId };
	const out = herdrSync(["pane", "current"]);
	const p = (parseJson(out) as any)?.result?.pane;
	if (p?.pane_id && p?.tab_id && p?.workspace_id) return { paneId: p.pane_id, tabId: p.tab_id, workspaceId: p.workspace_id };
	throw new Error("Cannot determine herdr pane context.");
}

/** Create a new tab in the current workspace. Returns the root pane id. */
export function createTab(label: string, cwd: string): string {
	const { workspaceId } = getCurrentPane();
	const out = herdrSync(["tab", "create", "--workspace", workspaceId, "--label", label, "--cwd", cwd, "--no-focus"]);
	const pId = (parseJson(out) as any)?.result?.root_pane?.pane_id;
	if (!pId) throw new Error(`Tab create failed: ${out.trim()}`);
	try { herdrSync(["pane", "rename", pId, label]); } catch { }
	return pId;
}

/** Run a command in a pane (sends text + Enter atomically). */
export function runCommand(paneId: string, command: string): void {
	herdrSync(["pane", "run", paneId, command]);
}

/** Read pane output (sync). */
export function readOutput(paneId: string, lines = 100): string {
	return herdrSync(["pane", "read", paneId, "--source", "visible", "--lines", String(lines)]);
}

/** Read pane output (async). */
export async function readOutputAsync(paneId: string, lines = 100): Promise<string> {
	return herdrAsync(["pane", "read", paneId, "--source", "visible", "--lines", String(lines)]);
}

/** Wait for an agent to reach a status. */
export async function waitForStatus(paneId: string, status: string, timeoutMs = 300_000): Promise<void> {
	await herdrAsync(["wait", "agent-status", paneId, "--status", status, "--timeout", String(timeoutMs)]);
}

export type AgentStatus = "idle" | "working" | "blocked" | "done" | "unknown";

/** Inspect a pane asynchronously. */
export async function inspectPane(paneId: string): Promise<{ alive: boolean; agentStatus: AgentStatus }> {
	try {
		const out = await herdrAsync(["pane", "get", paneId]);
		const p = (parseJson(out) as any)?.result?.pane;
		if (!p) return { alive: false, agentStatus: "unknown" };
		const raw = typeof p.agent_status === "string" ? p.agent_status : "unknown";
		const s = (["idle", "working", "blocked", "done", "unknown"] as const).includes(raw as any) ? raw as AgentStatus : "unknown";
		return { alive: true, agentStatus: s };
	} catch { return { alive: false, agentStatus: "unknown" }; }
}

/** Close a pane. */
export function closePane(paneId: string): void {
	try { herdrSync(["pane", "close", paneId]); } catch { }
}

/** Report agent state to herdr sidebar. */
export function reportAgent(paneId: string, source: string, agent: string, state: string): void {
	try { herdrSync(["pane", "report-agent", paneId, "--source", source, "--agent", agent, "--state", state]); } catch { }
}

/** Rename a pane. */
export function renamePane(paneId: string, label: string): void {
	try { herdrSync(["pane", "rename", paneId, label]); } catch { }
}
