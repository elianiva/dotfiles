---
name: to-callgraph
description: Trace a code path end-to-end and render it as an annotated ASCII callgraph with a concurrency/serialization analysis.
disable-model-invocation: true
---

# To-Callgraph

Trace a flow through the codebase end-to-end and hand back a callgraph: an ASCII diagram of every hop, annotated with where work runs concurrently and where it waits. When the user asks about a path — a feature, a flow, a worry like "can we parallelize this?" — the answer starts with the trace.

## 1. Scope the trace

Pin the **entry** (the event/message/command that starts the flow) and the **exit** (what completes it — a rendered frame, a blob URL, a persisted row). Find every path that carries the feature's name: a feature often has two (a CPU preview path and a GPU path, a fast path and a full path), and each gets traced.

Completion criterion: you can state, in one sentence, what enters and what exits each path.

## 2. Walk the hops

Each hop is one box of the callgraph: `event → message → update → command → service → worker/GPU → message → update → model → view`. Read the file that handles each hop before drawing the edge — a hop you haven't read is an edge you can't draw.

- Recon the area first: `fffind`/`grep` for the feature's names, read what surfaces, then read the project's ADRs/docs for the decisions that shaped the path.
- Before trusting an edge, `grep` for every caller of the exported symbols it crosses — missed callers are bugs.
- Note the runtime's execution model: are commands forked (concurrent) or queued? That determines which hops are already parallel.

Completion criterion: every edge names a file you actually read; every exported symbol you cite has had its callers grepped.

## 3. Render the callgraph

ASCII, top-down, one line per hop, file path on the edge, in the house style:

```
<entry>
  └─ <dispatch> → <message>
       └─ <command.execute>        (forked — concurrent)
            ├─ <service>           ✓ memoized / parallel
            └─ <worker>            ⚠ serializes here — one thread, N requests
```

Mark every async boundary (`postMessage`/Deferred, `Effect.runFork`, GPU submission). Mark every hop that already runs concurrently (✓) and every hop where work queues up (⚠). If a hop spans multiple files, say so.

Completion criterion: a reader can point at any box, ask "where's the code?", and get a file:line.

## 4. Read the seams

For every ⚠, name the concrete cost and the fix shape: a **pool** (N workers/threads instead of 1), a **cache** (memoize a value recomputed per iteration), a **move** (off the main thread), a **coalesce** (dedupe identical requests). Also hunt **wasted work**: the same op repeated per item that could run once (a downscale per LUT instead of per photo). Every bottleneck gets a named fix direction — a complaint without a fix shape is an unfinished seam.

Completion criterion: every ⚠ and every repeated-op finding carries a named fix shape.

## 5. Deliver

Callgraph first, then: what's already parallel, where it serializes, options ranked by cost/benefit, and the recommended cut. When the user asks for a plan, add before/after callgraphs plus a file-by-file change list and how to verify (tests, typecheck, lint, manual smoke).

Completion criterion: the user can approve or reject the recommendation from your writeup alone.
