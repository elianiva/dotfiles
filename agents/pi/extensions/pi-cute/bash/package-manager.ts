import { access } from "node:fs/promises";
import { dirname, join } from "node:path";

export type PackageManager = "bun" | "pnpm";

export async function detectPackageManager(cwd: string): Promise<PackageManager> {
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

  return "pnpm";
}
