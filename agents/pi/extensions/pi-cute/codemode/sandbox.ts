export function buildSandboxCode(userCode: string, port: number): string {
  const cleaned = userCode
    .trim()
    .replace(/^```(?:js|javascript|ts|typescript)?\s*\n/, "")
    .replace(/\n?```\s*$/, "")
    .trim();

  const indented = cleaned.split("\n").map(l => "    " + l).join("\n");

  return `async function rpc(n, i) {
  const r = await fetch('http://127.0.0.1:${port}', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tool: n, input: i })
  });
  const t = await r.text();
  const d = JSON.parse(t);
  if (d.error) throw new Error(d.error);
  return d.result;
}

const pi = {
  tools: {
    read: (p, o = {}) => rpc("read", { path: p, opts: o }),
    write: (p, c, o = {}) => rpc("write", { path: p, content: c, opts: o }),
    edit: (p, ot, nt, o = {}) => rpc("edit", { path: p, oldText: ot, newText: nt, opts: o }),
    bash: (c, o = {}) => rpc("bash", { command: c, opts: o }),
    find: (p, o = {}) => rpc("find", { pattern: p, opts: o }),
    ls: (p = ".", o = {}) => rpc("ls", { path: p, opts: o })
  }
};

(async () => {
${indented}
})().then(
  r => console.log("__RESULT__" + JSON.stringify(r)),
  e => console.error("__ERROR__" + (e?.message ?? String(e)))
);
`;
}
