import { classify, type StatusSnapshot, type StatusState } from "./status.ts";

function formatDuration(ms: number): string {
  if (!Number.isFinite(ms) || ms <= 0) return "0ms";
  if (ms < 1_000) return `${ms}ms`;
  if (ms < 60_000) return `${(ms / 1000).toFixed(1)}s`;
  if (ms < 3_600_000) {
    const mins = Math.floor(ms / 60_000);
    const secs = Math.floor((ms % 60_000) / 1000);
    return secs > 0 ? `${mins}m${secs}s` : `${mins}m`;
  }
  if (ms < 86_400_000) {
    const hours = Math.floor(ms / 3_600_000);
    const mins = Math.floor((ms % 3_600_000) / 60_000);
    return mins > 0 ? `${hours}h${mins}m` : `${hours}h`;
  }
  const days = Math.floor(ms / 86_400_000);
  const hours = Math.floor((ms % 86_400_000) / 3_600_000);
  return hours > 0 ? `${days}d${hours}h` : `${days}d`;
}

export interface WidgetAgent {
  name: string;
  agent?: string;
  startTime: number;
  statusState: StatusState;
}

const ACCENT = "\x1b[38;2;77;163;255m";
const DIM = "\x1b[2m";
const RST = "\x1b[0m";

function wrap(content: string): string {
  return `${ACCENT}${content}${RST}`;
}

function dim(content: string): string {
  return `${DIM}${content}${RST}`;
}

function statusColor(kind: string): string {
  switch (kind) {
    case "active": return "\x1b[38;2;80;200;120m";
    case "waiting": return "\x1b[38;2;200;180;60m";
    case "stalled": return "\x1b[38;2;220;80;80m";
    case "starting":
    default: return "\x1b[38;2;160;160;200m";
  }
}

function visibleWidth(s: string): number {
  return s.replace(/\x1b\[[0-9;]*m/g, "").length;
}

function truncate(s: string, max: number): string {
  const clean = s.replace(/\x1b\[[0-9;]*m/g, "");
  if (clean.length <= max) return s;
  let vis = 0;
  for (let i = 0; i < s.length; i++) {
    if (s.charCodeAt(i) === 0x1b) {
      const end = s.indexOf("m", i);
      if (end === -1) return s.slice(0, max);
      i = end;
      continue;
    }
    vis++;
    if (vis > max - 1) return s.slice(0, i) + "…";
  }
  return s;
}



export function renderWidgetLines(agents: WidgetAgent[], width: number): string[] {
  if (width < 10) return [];

  const count = agents.length;
  const title = " Delegates ";
  const info = ` ${count} running `;

  const lines: string[] = [renderTop(title, info, width)];

  for (const agent of agents) {
    const elapsed = formatDuration(Date.now() - agent.startTime);
    const tag = agent.agent ? ` (${agent.agent})` : "";
    const left = ` ${elapsed}  ${agent.name}${tag} `;
    const snap = classify(agent.statusState, Date.now());
    const right = formatRight(snap);
    lines.push(renderMid(left, right, width));
  }

  lines.push(`${wrap("└")}${wrap("─".repeat(Math.max(0, width - 2)))}${wrap("┘")}`);
  return lines;
}

function renderTop(title: string, info: string, width: number): string {
  const inner = width - 2;
  const left = `─${title}─`;
  const right = `─${info}─`;
  const fill = Math.max(0, inner - visibleWidth(left) - visibleWidth(right));
  return `${wrap("┌")}${left}${wrap("─".repeat(fill))}${right}${wrap("┐")}`;
}

function renderMid(left: string, right: string, width: number): string {
  const inner = width - 2;
  const rightVis = visibleWidth(right);

  if (rightVis >= inner) {
    const trunc = truncate(right, inner);
    const pad = " ".repeat(Math.max(0, inner - visibleWidth(trunc)));
    return `${wrap("│")}${trunc}${pad}${wrap("│")}`;
  }

  const maxLeft = inner - rightVis;
  const truncLeft = truncate(left, maxLeft);
  const leftVis = visibleWidth(truncLeft);
  const pad = " ".repeat(Math.max(0, inner - leftVis - rightVis));
  return `${wrap("│")}${truncLeft}${pad}${right}${wrap("│")}`;
}

function formatRight(snapshot: StatusSnapshot): string {
  const kind = snapshot.kind;
  const color = statusColor(kind);

  if (kind === "starting") return ` ${color}starting${RST}${dim("…")} `;
  if (kind === "active") {
    const label = snapshot.activeLabel ? ` · ${snapshot.activeLabel}` : "";
    const dur = snapshot.activeDurationText ? ` ${dim(snapshot.activeDurationText)}` : "";
    return ` ${color}active${RST}${dim(label)}${dur} `;
  }
  if (kind === "waiting") {
    const label = snapshot.activeLabel ? ` (${snapshot.activeLabel})` : "";
    const dur = snapshot.waitingDurationText ? ` ${dim(snapshot.waitingDurationText)}` : "";
    return ` ${color}waiting${RST}${dim(label)}${dur} `;
  }
  const label = snapshot.activeLabel ? ` (${snapshot.activeLabel})` : "";
  const dur = snapshot.snapshotMissingDurationText ? ` ${dim(snapshot.snapshotMissingDurationText)}` : "";
  return ` ${color}stalled${RST}${dim(label)}${dur} `;
}
