import { createServer } from "node:http";
import type { Server } from "node:http";
import type { ToolImpl } from "./types.js";

export async function startRpcServer(tools: Record<string, ToolImpl>): Promise<{ server: Server; port: number }> {
  return new Promise((resolve) => {
    const server = createServer(async (req, res) => {
      let body = "";
      for await (const chunk of req) body += chunk;

      try {
        const { tool: name, input } = JSON.parse(body);
        const fn = tools[name];
        if (!fn) {
          res.writeHead(400);
          res.end(JSON.stringify({ error: `Unknown: ${name}` }));
          return;
        }
        const result = await fn(input);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ result }));
      } catch (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
      }
    });

    server.listen(0, "127.0.0.1", () => {
      const addr = server.address() as { port: number };
      resolve({ server, port: addr.port });
    });
  });
}
