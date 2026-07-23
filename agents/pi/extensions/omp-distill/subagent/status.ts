import type { ActivityState } from "./activity.ts";

export type StatusKind = "starting" | "active" | "waiting" | "stalled" | "running";
export type StatusTransition = "stalled" | "recovered" | null;

const STALL_AFTER_MS = 60_000;

export interface StatusState {
  startTimeMs: number;
  firstActivityAtMs: number | null;
  lastActivityAtMs: number | null;
  lastActivitySequence: number | null;
  activeScope: string | null;
  activeSinceMs: number | null;
  waitingSinceMs: number | null;
  phase: string | null;
  toolName: string | null;
  snapshotMissingSinceMs: number | null;
  currentKind: StatusKind;
  /** After interrupt, ignore activity older than this */
  interruptOverrideMs: number | null;
}

export interface StatusSnapshot {
  kind: StatusKind;
  elapsedMs: number;
  elapsedText: string;
  activeLabel: string | null;
  activeDurationText: string | null;
  waitingDurationText: string | null;
  toolName: string | null;
  snapshotMissingDurationText: string | null;
}

export function createState(startTimeMs: number): StatusState {
  return {
    startTimeMs,
    firstActivityAtMs: null,
    lastActivityAtMs: null,
    lastActivitySequence: null,
    activeScope: null,
    activeSinceMs: null,
    waitingSinceMs: null,
    phase: null,
    toolName: null,
    snapshotMissingSinceMs: null,
    currentKind: "starting",
    interruptOverrideMs: null,
  };
}

export function forceKindAfterInterrupt(state: StatusState, now: number): StatusState {
  return {
    ...state,
    interruptOverrideMs: now,
    lastActivityAtMs: now,
    activeSinceMs: null,
    waitingSinceMs: now,
    phase: "waiting",
    toolName: null,
    currentKind: "waiting",
    snapshotMissingSinceMs: null,
  };
}

export function observe(
  state: StatusState,
  activity: ActivityState | null,
  now: number,
): StatusState {
  if (!activity) {
    return {
      ...state,
      firstActivityAtMs: state.firstActivityAtMs ?? now,
      snapshotMissingSinceMs: state.snapshotMissingSinceMs ?? now,
    };
  }

  // Ignore stale activity data (older than last known or interrupt)
  if (state.lastActivityAtMs != null && activity.updatedAt <= state.lastActivityAtMs) return state;
  if (state.interruptOverrideMs != null && activity.updatedAt <= state.interruptOverrideMs) return state;

  const isActive = activity.phase === "active";
  const isWaiting = activity.phase === "waiting";

  return {
    ...state,
    firstActivityAtMs: state.firstActivityAtMs ?? now,
    lastActivityAtMs: activity.updatedAt,
    lastActivitySequence: activity.sequence,
    activeScope: isActive ? (activity.activeScope ?? null) : null,
    activeSinceMs: isActive ? (activity.activeSince ?? state.activeSinceMs ?? activity.updatedAt) : null,
    waitingSinceMs: isWaiting ? (activity.waitingSince ?? state.waitingSinceMs ?? activity.updatedAt) : null,
    phase: activity.phase,
    toolName: activity.toolName ?? null,
    snapshotMissingSinceMs: null,
    interruptOverrideMs: null,
  };
}

function fmtDur(ms: number): string {
  const total = Math.max(0, Math.floor(ms / 1000));
  if (total < 60) return `${total}s`;
  const m = Math.floor(total / 60);
  const s = total % 60;
  if (m < 60) return `${m}m ${s}s`;
  const h = Math.floor(m / 60);
  return `${h}h ${m % 60}m`;
}

export function classify(state: StatusState, now: number): StatusSnapshot {
  const elapsedMs = Math.max(0, now - state.startTimeMs);
  const elapsedText = fmtDur(elapsedMs);
  const activeDurationText = state.activeSinceMs ? fmtDur(now - state.activeSinceMs) : null;
  const waitingDurationText = state.waitingSinceMs ? fmtDur(now - state.waitingSinceMs) : null;
  const snapshotMissingDurationText = state.snapshotMissingSinceMs
    ? fmtDur(now - state.snapshotMissingSinceMs)
    : null;

  if (state.phase === "active") {
    return {
      kind: "active",
      elapsedMs, elapsedText,
      activeLabel: activeLabel(state),
      activeDurationText, waitingDurationText: null,
      toolName: state.toolName,
      snapshotMissingDurationText: null,
    };
  }

  if (state.phase === "waiting" || state.phase === "done") {
    return {
      kind: "waiting",
      elapsedMs, elapsedText,
      activeLabel: state.phase === "done" ? "done" : null,
      activeDurationText: null, waitingDurationText,
      toolName: null,
      snapshotMissingDurationText: null,
    };
  }

  // No valid snapshot yet, or snapshot missing
  const hasEverSeen = state.lastActivityAtMs != null;

  if (!hasEverSeen) {
    const refMs = state.firstActivityAtMs ?? state.startTimeMs;
    const sinceFirst = Math.max(0, now - refMs);
    if (sinceFirst >= STALL_AFTER_MS) {
      return {
        kind: "stalled",
        elapsedMs, elapsedText,
        activeLabel: "never seen activity",
        activeDurationText: null, waitingDurationText: null,
        toolName: null,
        snapshotMissingDurationText,
      };
    }
    return {
      kind: "starting",
      elapsedMs, elapsedText,
      activeLabel: null,
      activeDurationText: null, waitingDurationText: null,
      toolName: null,
      snapshotMissingDurationText,
    };
  }

  // Have seen activity but current snapshot is missing
  const problemMs = state.snapshotMissingSinceMs ?? now;
  if (now - problemMs >= STALL_AFTER_MS) {
    return {
      kind: "stalled",
      elapsedMs, elapsedText,
      activeLabel: "lost contact",
      activeDurationText: null, waitingDurationText: null,
      toolName: null,
      snapshotMissingDurationText,
    };
  }

  // Stay in whatever kind we were in, but flag the missing snapshot
  return {
    kind: state.currentKind === "stalled" ? "starting" : state.currentKind,
    elapsedMs, elapsedText,
    activeLabel: null,
    activeDurationText, waitingDurationText,
    toolName: state.toolName,
    snapshotMissingDurationText,
  };
}

function activeLabel(state: StatusState): string | null {
  if (state.activeScope === "tool" && state.toolName) return state.toolName;
  return state.activeScope;
}

export function advance(state: StatusState, now: number): {
  next: StatusState;
  snapshot: StatusSnapshot;
  transition: StatusTransition;
} {
  const snapshot = classify(state, now);
  const prevKind = state.currentKind;
  const nextKind = snapshot.kind;

  let transition: StatusTransition = null;
  if (prevKind !== "stalled" && nextKind === "stalled") transition = "stalled";
  else if (prevKind === "stalled" && (nextKind === "active" || nextKind === "waiting")) transition = "recovered";

  return {
    snapshot,
    transition,
    next: { ...state, currentKind: nextKind },
  };
}

export function formatLine(name: string, snapshot: StatusSnapshot): string {
  const base = `${name} (${snapshot.elapsedText})`;
  switch (snapshot.kind) {
    case "starting":
      return `${base} — starting`;
    case "active": {
      const label = snapshot.activeLabel ? ` · ${snapshot.activeLabel}` : "";
      const dur = snapshot.activeDurationText ? ` ${snapshot.activeDurationText}` : "";
      return `${base} — active${label}${dur}`;
    }
    case "waiting": {
      const label = snapshot.activeLabel ? ` (${snapshot.activeLabel})` : "";
      const dur = snapshot.waitingDurationText ? ` ${snapshot.waitingDurationText}` : "";
      return `${base} — waiting${dur}${label}`;
    }
    case "stalled": {
      const label = snapshot.activeLabel ? ` (${snapshot.activeLabel})` : "";
      const dur = snapshot.snapshotMissingDurationText ? ` ${snapshot.snapshotMissingDurationText}` : "";
      return `${base} — stalled${dur}${label}`;
    }
    default:
      return `${base} — ${snapshot.kind}`;
  }
}
