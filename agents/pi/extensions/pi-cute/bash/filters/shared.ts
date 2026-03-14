export function splitCommandSegments(input: string): string[] {
  const out: string[] = [];
  let cur = "";
  let i = 0;
  let inSingle = false;
  let inDouble = false;

  while (i < input.length) {
    const ch = input[i]!;

    if (ch === "'" && !inDouble) {
      inSingle = !inSingle;
      cur += ch;
      i += 1;
      continue;
    }

    if (ch === "\"" && !inSingle) {
      inDouble = !inDouble;
      cur += ch;
      i += 1;
      continue;
    }

    if (!inSingle && !inDouble) {
      const two = input.slice(i, i + 2);
      if (two === "&&" || two === "||") {
        if (cur.trim()) out.push(cur.trim());
        cur = "";
        i += 2;
        continue;
      }

      if (ch === ";" || ch === "|") {
        if (cur.trim()) out.push(cur.trim());
        cur = "";
        i += 1;
        continue;
      }
    }

    cur += ch;
    i += 1;
  }

  if (cur.trim()) out.push(cur.trim());
  return out;
}
