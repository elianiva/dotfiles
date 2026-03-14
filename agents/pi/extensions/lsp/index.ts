/**
 * LSP Diagnostics Extension
 *
 * Warms up LSP servers on file read, provides diagnostics on write/edit operations.
 * Pattern based on opencode's implementation.
 */

import type {
  ExtensionAPI,
  ToolResultEvent,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import { spawn, type ChildProcess } from "node:child_process";
import { readFileSync } from "node:fs";
import { resolve, extname } from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";
import {
  createMessageConnection,
  StreamMessageReader,
  StreamMessageWriter,
  type MessageConnection,
} from "vscode-jsonrpc/node";
import type { Diagnostic as VSCodeDiagnostic } from "vscode-languageserver-protocol";
import { LSP_SERVERS, LANGUAGE_MAP, type LspHandle, type LspServerInfo } from "./lsp-config.js";

const DIAGNOSTICS_TIMEOUT_MS = 5000;
const DIAGNOSTICS_DEBOUNCE_MS = 150;
const LSP_CONNECTION_TIMEOUT_MS = 5000;

type Diagnostic = VSCodeDiagnostic;

interface LspConnection {
  connection: MessageConnection;
  process: ChildProcess;
  rootDir: string;
  serverName: string;
  languages: string[];
  startedAt: number;
  lastActivity: number;
  diagnostics: Map<string, Diagnostic[]>;
  openedFiles: Map<string, number>;
  initialized: boolean;
}

interface LspStatus {
  name: string;
  pid: number | undefined;
  rootDir: string;
  languages: string[];
  uptime: number;
  lastActivity: number;
  filesTracked: number;
  initialized: boolean;
}

class LspConnectionManager {
  private connections = new Map<string, LspConnection>();
  private diagnosticCallbacks = new Map<string, Set<() => void>>();

  async getOrCreateConnections(
    filePath: string,
    cwd: string,
    ctx: ExtensionContext,
  ): Promise<LspConnection[]> {
    const ext = extname(filePath);
    const languageId = LANGUAGE_MAP[ext];
    if (!languageId) return [];

    // Find all matching servers
    const matchingServers = LSP_SERVERS.filter((server) => server.extensions.includes(ext));

    const connections: LspConnection[] = [];

    for (const server of matchingServers) {
      const rootDir = await server.root(filePath, cwd);
      if (!rootDir) continue; // Server doesn't apply to this project

      const connectionKey = `${server.id}:${rootDir}`;
      if (this.connections.has(connectionKey)) {
        const conn = this.connections.get(connectionKey)!;
        conn.lastActivity = Date.now();
        connections.push(conn);
        continue;
      }

      try {
        const handle = await server.spawn(rootDir, cwd);
        if (!handle) {
          ctx.ui.notify(`Could not start ${server.id} LSP server`, "error");
          continue;
        }
        const conn = await this.createConnection(
          connectionKey,
          server.id,
          handle,
          rootDir,
          server.extensions,
          ctx,
          AbortSignal.timeout(LSP_CONNECTION_TIMEOUT_MS),
        );
        this.connections.set(connectionKey, conn);
        connections.push(conn);
      } catch (e: any) {
        if (e.name === "TimeoutError") {
          ctx.ui.notify(`${server.id} LSP connection timed out, skipping`, "warning");
        } else {
          ctx.ui.notify(`Failed to start ${server.id} LSP: ${e}`, "error");
        }
      }
    }

    return connections;
  }

  private async createConnection(
    key: string,
    name: string,
    handle: LspHandle,
    rootDir: string,
    languages: string[],
    ctx: ExtensionContext,
    signal: AbortSignal,
  ): Promise<LspConnection> {
    ctx.ui.notify(`Starting ${name} LSP...`, "info");

    const connection = createMessageConnection(
      new StreamMessageReader(handle.process.stdout),
      new StreamMessageWriter(handle.process.stdin),
    );

    const conn: LspConnection = {
      connection,
      process: handle.process,
      rootDir,
      serverName: name,
      languages: [...languages],
      startedAt: Date.now(),
      lastActivity: Date.now(),
      diagnostics: new Map(),
      openedFiles: new Map(),
      initialized: false,
    };

    // Handle diagnostics
    connection.onNotification("textDocument/publishDiagnostics", (params: any) => {
      const filePath = this.normalizePath(fileURLToPath(params.uri));
      conn.diagnostics.set(filePath, params.diagnostics);

      // Notify waiters
      const callbacks = this.diagnosticCallbacks.get(filePath);
      if (callbacks) {
        for (const cb of callbacks) cb();
      }
    });

    // Handle window/workDoneProgress/create
    connection.onRequest("window/workDoneProgress/create", () => null);

    // Handle workspace/configuration
    connection.onRequest("workspace/configuration", async () => [handle.initialization ?? {}]);

    // Handle client/registerCapability
    connection.onRequest("client/registerCapability", async () => {});

    // Handle client/unregisterCapability
    connection.onRequest("client/unregisterCapability", async () => {});

    // Handle workspace/workspaceFolders
    connection.onRequest("workspace/workspaceFolders", async () => [
      {
        name: "workspace",
        uri: pathToFileURL(rootDir).href,
      },
    ]);

    connection.listen();

    // Initialize with timeout using AbortSignal
    try {
      await this.initializeConnection(connection, handle, rootDir, signal);
    } catch (e: any) {
      if (e.name === "TimeoutError") {
        ctx.ui.notify(`${name} LSP connection timed out, continuing anyway`, "warning");
      } else {
        throw e;
      }
    }

    conn.initialized = true;

    // Handle stderr
    handle.process.stderr?.on("data", (data: Buffer) => {
      const msg = data.toString().trim();
      if (msg) console.error(`[LSP:${name}]`, msg.slice(0, 200));
    });

    // Handle process exit
    handle.process.on("exit", (code) => {
      if (code && code !== 0) {
        ctx.ui.notify(`${name} LSP exited with code ${code}`, "error");
      }
      this.connections.delete(key);
    });

    ctx.ui.notify(`${name} LSP ready`, "success");
    return conn;
  }

  private async initializeConnection(
    connection: MessageConnection,
    handle: LspHandle,
    rootDir: string,
    signal: AbortSignal,
  ): Promise<void> {
    await connection.sendRequest("initialize", {
      rootUri: pathToFileURL(rootDir).href,
      processId: handle.process.pid,
      workspaceFolders: [
        {
          name: "workspace",
          uri: pathToFileURL(rootDir).href,
        },
      ],
      initializationOptions: handle.initialization ?? {},
      capabilities: {
        window: {
          workDoneProgress: true,
        },
        workspace: {
          configuration: true,
          didChangeWatchedFiles: {
            dynamicRegistration: true,
          },
        },
        textDocument: {
          synchronization: {
            didOpen: true,
            didChange: true,
          },
          publishDiagnostics: {
            versionSupport: true,
          },
        },
      },
    });

    await connection.sendNotification("initialized", {});
    if (handle.initialization) {
      await connection.sendNotification("workspace/didChangeConfiguration", {
        settings: handle.initialization,
      });
    }
  }

  /**
   * Touch file with diagnostic subscription BEFORE sending didOpen
   * This is the key fix from opencode to avoid race conditions
   */
  async touchFile(
    conn: LspConnection,
    filePath: string,
    content: string,
    languageId: string,
    waitForDiagnostics: boolean = false,
  ): Promise<Diagnostic[]> {
    const normalizedPath = this.normalizePath(filePath);
    const uri = pathToFileURL(normalizedPath).href;
    const existingVersion = conn.openedFiles.get(normalizedPath);

    // Set up diagnostic listener BEFORE sending notification (opencode pattern)
    let diagnosticsPromise: Promise<Diagnostic[]> | undefined;
    let debounceTimer: ReturnType<typeof setTimeout> | undefined;
    let unsubscribe: (() => void) | undefined;

    if (waitForDiagnostics) {
      diagnosticsPromise = new Promise<Diagnostic[]>((resolve) => {
        let resolved = false;

        const tryResolve = () => {
          if (resolved) return;
          if (debounceTimer) clearTimeout(debounceTimer);
          debounceTimer = setTimeout(() => {
            resolved = true;
            unsubscribe?.();
            resolve(conn.diagnostics.get(normalizedPath) ?? []);
          }, DIAGNOSTICS_DEBOUNCE_MS);
        };

        if (!this.diagnosticCallbacks.has(normalizedPath)) {
          this.diagnosticCallbacks.set(normalizedPath, new Set());
        }
        const callbacks = this.diagnosticCallbacks.get(normalizedPath)!;
        callbacks.add(tryResolve);
        unsubscribe = () => callbacks.delete(tryResolve);

        // Timeout fallback
        setTimeout(() => {
          if (!resolved) {
            resolved = true;
            unsubscribe?.();
            resolve(conn.diagnostics.get(normalizedPath) ?? []);
          }
        }, DIAGNOSTICS_TIMEOUT_MS);
      });
    }

    // Now send the notification
    if (existingVersion !== undefined) {
      conn.diagnostics.delete(normalizedPath);
      const nextVersion = existingVersion + 1;
      conn.openedFiles.set(normalizedPath, nextVersion);

      await conn.connection.sendNotification("workspace/didChangeWatchedFiles", {
        changes: [{ uri, type: 2 }], // Changed
      });

      await conn.connection.sendNotification("textDocument/didChange", {
        textDocument: { uri, version: nextVersion },
        contentChanges: [{ text: content }],
      });
    } else {
      conn.openedFiles.set(normalizedPath, 0);
      conn.diagnostics.delete(normalizedPath);

      await conn.connection.sendNotification("workspace/didChangeWatchedFiles", {
        changes: [{ uri, type: 1 }], // Created
      });

      await conn.connection.sendNotification("textDocument/didOpen", {
        textDocument: { uri, languageId, version: 0, text: content },
      });
    }

    if (diagnosticsPromise) {
      return diagnosticsPromise;
    }
    return [];
  }

  getDiagnostics(conn: LspConnection, filePath: string): Diagnostic[] {
    const normalizedPath = this.normalizePath(filePath);
    return conn.diagnostics.get(normalizedPath) ?? [];
  }

  getAllDiagnostics(filePath: string): { conn: LspConnection; diagnostics: Diagnostic[] }[] {
    const normalizedPath = this.normalizePath(filePath);
    const results: { conn: LspConnection; diagnostics: Diagnostic[] }[] = [];
    for (const conn of this.connections.values()) {
      const diags = conn.diagnostics.get(normalizedPath);
      if (diags && diags.length > 0) {
        results.push({ conn, diagnostics: diags });
      }
    }
    return results;
  }

  async shutdown(conn: LspConnection): Promise<void> {
    try {
      await conn.connection.sendRequest("shutdown", undefined);
      await conn.connection.sendNotification("exit", {});
      conn.connection.end();
      conn.connection.dispose();
    } catch {
      // Ignore shutdown errors
    }
    conn.process.kill();
  }

  async shutdownAll(): Promise<void> {
    const promises = Array.from(this.connections.values()).map((conn) => this.shutdown(conn));
    await Promise.all(promises);
    this.connections.clear();
  }

  killConnection(key: string): boolean {
    const conn = this.connections.get(key);
    if (!conn) return false;

    conn.process.kill("SIGTERM");
    setTimeout(() => {
      if (!conn.process.killed) {
        conn.process.kill("SIGKILL");
      }
    }, 1000);

    this.connections.delete(key);
    return true;
  }

  getStatus(): LspStatus[] {
    return Array.from(this.connections.entries()).map(([key, conn]) => ({
      name: conn.serverName,
      pid: conn.process.pid,
      rootDir: conn.rootDir,
      languages: conn.languages,
      uptime: Date.now() - conn.startedAt,
      lastActivity: Date.now() - conn.lastActivity,
      filesTracked: conn.openedFiles.size,
      initialized: conn.initialized,
    }));
  }

  private normalizePath(filePath: string): string {
    return resolve(filePath);
  }
}

// Helper Functions

function extractFileFromEvent(event: ToolResultEvent): { path: string; isWrite: boolean } | null {
  if (!event.isError && (event.toolName === "write" || event.toolName === "edit")) {
    return { path: event.input.path as string, isWrite: true };
  }
  if (!event.isError && event.toolName === "read") {
    return { path: event.input.path as string, isWrite: false };
  }
  return null;
}

function formatDiagnostics(diagnostics: Diagnostic[]): string {
  const severityLabels = ["", "ERROR", "WARNING", "INFO", "HINT"];

  return diagnostics
    .map((d) => {
      const line = (d.range?.start?.line ?? 0) + 1;
      const col = (d.range?.start?.character ?? 0) + 1;
      const severity = severityLabels[d.severity ?? 0] || "UNKNOWN";
      const code = d.code ? `[${d.code}]` : "";
      // const source = d.source ? `${d.source}` : "";
      return `${severity} [${line}:${col}] ${d.message}`;
    })
    .join("\n");
}

function formatDuration(ms: number): string {
  if (ms < 1000) return `${ms}ms`;
  if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
  return `${(ms / 60000).toFixed(1)}m`;
}

export default function (pi: ExtensionAPI) {
  const manager = new LspConnectionManager();

  // Warm up LSP on read, full diagnostics on write/edit
  pi.on("tool_result", async (event: ToolResultEvent, ctx: ExtensionContext) => {
    const fileInfo = extractFileFromEvent(event);
    if (!fileInfo) return;

    const { path: filePath, isWrite } = fileInfo;
    const absPath = resolve(ctx.cwd, filePath);

    const conns = await manager.getOrCreateConnections(filePath, ctx.cwd, ctx);
    if (conns.length === 0) return;

    let content: string;
    try {
      content = readFileSync(absPath, "utf-8");
    } catch {
      return;
    }

    const ext = extname(filePath);
    const languageId = LANGUAGE_MAP[ext];
    if (!languageId) return;

    // For read operations: warm up and fetch existing diagnostics if available
    if (!isWrite) {
      await Promise.all(
        conns.map((conn) => manager.touchFile(conn, absPath, content, languageId, false)),
      );
      const allDiags = manager.getAllDiagnostics(absPath);
      if (allDiags.length > 0) {
        const combined = allDiags.flatMap((d) => d.diagnostics);
        const formatted = formatDiagnostics(combined);
        pi.sendUserMessage(`Current diagnostics for \`${filePath}\`:\n${formatted}`, {
          deliverAs: "steer",
        });
      }
      return;
    }
    // For write operations: use opencode pattern - subscribe BEFORE sending
    const diagnostics = (
      await Promise.all(
        conns.map((conn) => manager.touchFile(conn, absPath, content, languageId, true)),
      )
    ).flat();

    // Show results
    if (diagnostics.length > 0) {
      const formatted = formatDiagnostics(diagnostics);
      pi.sendUserMessage(`Diagnostics for \`${filePath}\`:\n${formatted}`, {
        deliverAs: "steer",
      });
    } else {
      ctx.ui.notify(`✓ ${filePath}: clean`, "success");
    }
  });

  // Cleanup on shutdown
  pi.on("session_shutdown", async () => {
    await manager.shutdownAll();
  });

  // /lsp command - dashboard
  pi.registerCommand("lsp", {
    description:
      "LSP status dashboard - show running servers, available LSPs, and manage processes",
    getArgumentCompletions: (prefix: string) => {
      const actions = ["status", "available", "kill", "killall"];
      const filtered = actions.filter((a) => a.startsWith(prefix));
      return filtered.length > 0 ? filtered.map((a) => ({ value: a, label: a })) : null;
    },
    handler: async (args: string, ctx) => {
      const parts = args.trim().split(/\s+/);
      const action = parts[0] || "status";
      const serverKey = parts[1];

      switch (action) {
        case "status": {
          const status = manager.getStatus();
          if (status.length === 0) {
            ctx.ui.notify("No LSP servers currently running", "info");
            return;
          }

          const lines = [
            "📊 LSP Server Status",
            "",
            ...status.map((s) => {
              const uptime = formatDuration(s.uptime);
              const statusStr = s.initialized ? "🟢 ready" : "🟡 initializing";
              return `  ${s.name}\n    PID: ${s.pid} | Status: ${statusStr}\n    Root: ${s.rootDir}\n    Languages: ${s.languages.join(", ")}\n    Uptime: ${uptime} | Files: ${s.filesTracked}`;
            }),
            "",
            "Use `/lsp kill <server>` to kill a specific server",
            "Use `/lsp killall` to kill all servers",
          ];

          ctx.ui.notify(lines.join("\n"), "info");
          break;
        }

        case "available": {
          const lines = [
            "🔧 Available LSP Servers",
            "",
            "Configured servers:",
            ...LSP_SERVERS.map((s) => `  ${s.id} - ${s.extensions.join(", ")}`),
          ];

          ctx.ui.notify(lines.join("\n"), "info");
          break;
        }

        case "kill": {
          if (!serverKey) {
            const status = manager.getStatus();
            if (status.length === 0) {
              ctx.ui.notify("No servers running", "info");
              return;
            }

            const keys = status.map((s) => `${s.name}:${s.rootDir}`);
            ctx.ui.notify("Usage: /lsp kill <server-key>\n\nAvailable servers:", "error");
            ctx.ui.notify(keys.join("\n"), "info");
            return;
          }

          const killed = manager.killConnection(serverKey);
          if (killed) {
            ctx.ui.notify(`Killed LSP server: ${serverKey}`, "success");
          } else {
            ctx.ui.notify(`Server not found: ${serverKey}`, "error");
          }
          break;
        }

        case "killall": {
          const status = manager.getStatus();
          await manager.shutdownAll();
          ctx.ui.notify(
            `Killed ${status.length} LSP server${status.length > 1 ? "s" : ""}`,
            "success",
          );
          break;
        }
      }
    },
  });
}
