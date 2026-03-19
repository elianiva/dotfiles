import { exec as execCallback } from "node:child_process";
import { mkdir as mkdirPromise, readFile as readFilePromise, writeFile as writeFilePromise } from "node:fs/promises";

export { mkdirPromise as mkdir, readFilePromise as readFile, writeFilePromise as writeFile };

export function exec(command: string, cwd: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const child = execCallback(command, { cwd, maxBuffer: 10 * 1024 * 1024 }, (error, stdout, stderr) => {
      if (error) reject(new Error(stderr || error.message));
      else resolve(stdout);
    });
    child.on("error", reject);
    setTimeout(() => { child.kill(); reject(new Error("Timeout")); }, 60000);
  });
}
