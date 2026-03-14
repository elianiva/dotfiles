import { createBashTool, type BashToolInput } from "@mariozechner/pi-coding-agent";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { checkBlockedCommand } from "./blockers";
import { parseCommand } from "./command-ast";
import { filterCommandOutput } from "./filter-pipeline";
import { detectPackageManager } from "./package-manager";
import { rewriteCommandInput } from "./rewrite-pipeline";

function filterToolText(command: string, text: string): string {
  return filterCommandOutput(command, text);
}

export function registerGuardedBashTool(pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    try {
      const command = (event.input?.command ?? "") as string;
      const ast = parseCommand(command);
      const reason = checkBlockedCommand(ast);
      if (!reason) return;
      ctx.ui.notify(`Blocked: ${reason}`, "warning");
      return { block: true, reason };
    } catch {
      return;
    }
  });

  const defaultBash = createBashTool(process.cwd());

  pi.registerTool({
    ...defaultBash,
    execute: async (id, params, signal, onUpdate, ctx) => {
      const input = params as BashToolInput;
      const manager = await detectPackageManager(ctx.cwd);
      const rewrittenCommand = rewriteCommandInput(input.command, manager);

      if (rewrittenCommand !== input.command) {
        ctx.ui.notify(`Rewrite: ${input.command} -> ${rewrittenCommand}`, "info");
      }

      const bash = createBashTool(ctx.cwd, {
        spawnHook: (spawnArgs) => {
          const rewritten = spawnArgs.command === input.command
            ? rewrittenCommand
            : rewriteCommandInput(spawnArgs.command, manager);

          return rewritten === spawnArgs.command
            ? spawnArgs
            : { ...spawnArgs, command: rewritten };
        },
      });

      try {
        const result = await (bash.execute as any)(id, params, signal, onUpdate);
        const text = result?.content?.[0]?.type === "text" ? result.content[0].text : "";
        if (!text) return result;

        return {
          ...result,
          content: [{ type: "text", text: filterToolText(rewrittenCommand, text) }],
        };
      } catch (error: unknown) {
        const message = error instanceof Error ? error.message : String(error);
        throw new Error(filterToolText(rewrittenCommand, message));
      }
    },
  });
}
