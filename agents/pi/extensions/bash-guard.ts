import { parse, serialize } from "just-bash";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { createBashTool } from "@mariozechner/pi-coding-agent";
import { access } from "fs/promises";
import { join, dirname } from "path";

// Configuration
const PACKAGE_MANAGERS = ["npm", "pnpm", "bun", "yarn", "npx", "bunx"];
const LINT_FORMAT_TOOLS = ["eslint", "prettier", "lint", "format", "stylelint", "oxlint"];
const DEV_BUILD_COMMANDS = ["dev", "build", "watch", "serve", "start"];
const PYTHON_COMMANDS = ["python", "python3"];

async function getPackageManager(cwd: string): Promise<"bun" | "pnpm"> {
  let current = cwd;
  while (true) {
    try {
      await access(join(current, "bun.lockb"));
      return "bun";
    } catch {}
    try {
      await access(join(current, "bun.lock"));
      return "bun";
    } catch {}
    try {
      await access(join(current, "pnpm-lock.yaml"));
      return "pnpm";
    } catch {}

    const parent = dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return "pnpm"; // safe fallback for most projects
}

function getWordText(word: any): string {
  if (!word || word.type !== "Word") return "";
  return word.parts
    .map((p: any) => (p.type === "Literal" ? p.value : ""))
    .join("");
}

function checkBlocked(ast: any): string | null {
  for (const stmt of ast.statements) {
    if (stmt.type !== "Statement") continue;
    for (const pipe of stmt.pipelines) {
      for (const cmd of pipe.commands) {
        if (cmd.type !== "SimpleCommand") continue;
        const name = getWordText(cmd.name);

        // Block rm -rf
        if (name === "rm") {
          let hasR = false;
          let hasF = false;
          for (const arg of cmd.args) {
            const text = getWordText(arg);
            if (text.startsWith("-") && !text.startsWith("--")) {
              if (text.toLowerCase().includes("r")) hasR = true;
              if (text.includes("f")) hasF = true;
            } else if (text === "--recursive") {
              hasR = true;
            } else if (text === "--force") {
              hasF = true;
            }
          }
          if (hasR && hasF) return "rm -rf is blocked for safety";
        }

        // Package manager checks
        if (PACKAGE_MANAGERS.includes(name)) {
          const args = cmd.args.map(getWordText);

          const foundDev = args.find(a => DEV_BUILD_COMMANDS.includes(a));
          if (foundDev) {
            return `Don't run '${foundDev}'. Assume it's already running or has succeeded, and proceed with your task.`;
          }

          const foundLint = args.find(a => LINT_FORMAT_TOOLS.includes(a));
          if (foundLint) {
            return `Don't run '${foundLint}' directly. Use the appropriate script from package.json (e.g., '${name} run lint') to ensure project-specific configurations are used.`;
          }
        }

        // Direct tool calls
        if (LINT_FORMAT_TOOLS.includes(name)) {
          return `Don't run '${name}' directly. Use the appropriate script from package.json (e.g., 'npm run lint') to ensure project-specific configurations are used.`;
        }
      }
    }
  }
  return null;
}

function rewriteCommand(ast: any, manager: "bun" | "pnpm"): void {
  for (const stmt of ast.statements) {
    if (stmt.type !== "Statement") continue;
    for (const pipe of stmt.pipelines) {
      for (const cmd of pipe.commands) {
        if (cmd.type !== "SimpleCommand") continue;
        const name = getWordText(cmd.name);

        if (name === "npm") {
          cmd.name.parts = [{ type: "Literal", value: manager }];
        } else if (name === "npx") {
          if (manager === "pnpm") {
            cmd.name.parts = [{ type: "Literal", value: "pnpm" }];
            cmd.args.unshift({
              type: "Word",
              parts: [{ type: "Literal", value: "dlx" }],
            });
          } else {
            cmd.name.parts = [{ type: "Literal", value: "bunx" }];
          }
        } else if (PYTHON_COMMANDS.includes(name)) {
          cmd.name.parts = [{ type: "Literal", value: "uv" }];
          cmd.args.unshift({
            type: "Word",
            parts: [{ type: "Literal", value: "run" }],
          });
        }
      }
    }
  }
}

export default function bashGuardExtension(pi: ExtensionAPI) {
  // Block tool calls before execution
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash") {
      try {
        const command = (event as any).input.command;
        const ast = parse(command);
        const blockReason = checkBlocked(ast);
        if (blockReason) {
          ctx.ui.notify(`Blocked: ${blockReason}`, "warning");
          return { block: true, reason: blockReason };
        }
      } catch (e) {
        // Ignore parsing errors for blocking
      }
    }
  });

  // Override the bash tool to rewrite commands
  const defaultBash = createBashTool(process.cwd());

  pi.registerTool({
    ...defaultBash,
    execute: async (id, params, signal, onUpdate, ctx) => {
      const manager = await getPackageManager(ctx.cwd);

      const bashWithHook = createBashTool(ctx.cwd, {
        spawnHook: (spawnArgs) => {
          try {
            const ast = parse(spawnArgs.command);
            const original = spawnArgs.command;
            rewriteCommand(ast, manager);
            const rewritten = serialize(ast);
            if (original !== rewritten) {
              ctx.ui.notify(`Rewriting command: ${original} -> ${rewritten}`, "info");
            }
            return {
              ...spawnArgs,
              command: rewritten,
            };
          } catch (e) {
            return spawnArgs;
          }
        },
      });
      return bashWithHook.execute(id, params, signal, onUpdate, ctx);
    },
  });
}
