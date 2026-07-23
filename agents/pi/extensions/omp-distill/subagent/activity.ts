import { existsSync, mkdirSync, readFileSync, renameSync, unlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

export type ActivityPhase = "starting" | "active" | "waiting" | "done";
export type ActivityScope = "agent" | "turn" | "tool";

export interface ActivityState {
  version: 1;
  childId: string;
  createdAt: number;
  updatedAt: number;
  sequence: number;
  latestEvent: string;
  phase: ActivityPhase;
  activeScope?: ActivityScope;
  activeSince?: number;
  waitingSince?: number;
  toolName?: string;
}

export interface ActivityRecorder {
  sessionStart(): void;
  agentStart(): void;
  agentEnd(): void;
  turnStart(): void;
  turnEnd(): void;
  toolStart(toolName?: string): void;
  toolEnd(): void;
  callerPing(): void;
  subagentDone(): void;
  sessionShutdown(): void;
}

export function getActivityFile(artifactDir: string, childId: string): string {
  return join(artifactDir, "activity", `${childId}.json`);
}

export function readActivityFile(filePath: string, childId: string): ActivityState | null {
  if (!existsSync(filePath)) return null;
  try {
    const data = JSON.parse(readFileSync(filePath, "utf8"));
    if (data?.childId !== childId) return null;
    return data as ActivityState;
  } catch {
    return null;
  }
}

function noop(): ActivityRecorder {
  return {
    sessionStart() {},
    agentStart() {},
    agentEnd() {},
    turnStart() {},
    turnEnd() {},
    toolStart() {},
    toolEnd() {},
    callerPing() {},
    subagentDone() {},
    sessionShutdown() {},
  };
}

export function createRecorder(params: {
  childId?: string;
  activityFile?: string;
}): ActivityRecorder {
  const childId = params.childId?.trim();
  const activityFile = params.activityFile?.trim();
  if (!childId || !activityFile) return noop();

  const state: ActivityState = {
    version: 1,
    childId,
    createdAt: Date.now(),
    updatedAt: Date.now(),
    sequence: 0,
    latestEvent: "init",
    phase: "starting",
  };

  let dirty = false;
  let flushTimer: ReturnType<typeof setTimeout> | null = null;

  function write() {
    dirty = false;
    const dir = dirname(activityFile);
    mkdirSync(dir, { recursive: true });
    const tmp = join(dir, `${childId}.${process.pid}.${state.sequence}.tmp`);
    try {
      writeFileSync(tmp, JSON.stringify(state) + "\n");
      renameSync(tmp, activityFile);
    } catch {
      try { unlinkSync(tmp); } catch {}
    }
  }

  function schedule() {
    dirty = true;
    if (flushTimer) return;
    flushTimer = setTimeout(() => {
      flushTimer = null;
      write();
    }, 300);
  }

  function record(event: string, update: (s: ActivityState) => void, immediate = false) {
    state.sequence++;
    state.updatedAt = Date.now();
    state.latestEvent = event;
    update(state);
    if (immediate) {
      if (flushTimer) { clearTimeout(flushTimer); flushTimer = null; }
      write();
    } else {
      schedule();
    }
  }

  return {
    sessionStart() { record("session_start", s => { s.phase = "starting"; }, true); },
    agentStart() {
      record("agent_start", s => {
        s.phase = "active";
        s.activeScope = "agent";
        s.activeSince ??= Date.now();
        delete s.waitingSince;
      }, true);
    },
    agentEnd() {
      record("agent_end", s => {
        s.phase = "waiting";
        s.waitingSince ??= Date.now();
        delete s.activeScope;
        delete s.activeSince;
      }, true);
    },
    turnStart() {
      record("turn_start", s => {
        s.phase = "active";
        s.activeScope = "turn";
        s.activeSince ??= Date.now();
        delete s.waitingSince;
      }, true);
    },
    turnEnd() {
      record("turn_end", s => {
        if (!s.toolName) {
          s.phase = "waiting";
          s.waitingSince ??= Date.now();
          delete s.activeScope;
          delete s.activeSince;
        }
      }, true);
    },
    toolStart(toolName) {
      record("tool_start", s => {
        s.phase = "active";
        s.activeScope = "tool";
        s.toolName = toolName;
        s.activeSince ??= Date.now();
        delete s.waitingSince;
      }, true);
    },
    toolEnd() {
      record("tool_end", s => {
        delete s.toolName;
        s.phase = "waiting";
        s.waitingSince ??= Date.now();
        delete s.activeScope;
        delete s.activeSince;
      }, true);
    },
    callerPing() { record("caller_ping", s => { s.phase = "done"; }, true); },
    subagentDone() { record("subagent_done", s => { s.phase = "done"; }, true); },
    sessionShutdown() {
      if (state.phase !== "done") {
        record("session_shutdown", s => { s.phase = "done"; }, true);
      }
    },
  };
}
