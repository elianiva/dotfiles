---
name: tldraw-offline
description: Operate the user's tldraw offline canvas app, including open .tldraw or .tldr files. Use whenever a task involves inspecting, editing, arranging, connecting, linting, or scripting a tldraw Desktop canvas.
---
<!-- installed-by:tldraw-desktop-agent-skills -->

# tldraw canvas operator

Use this skill for tasks involving open tldraw Desktop files. The desktop app exposes a local HTTP server that can list documents, inspect canvas state, capture screenshots, execute JavaScript against a live editor, and expose live script files for durable behavior.

## Server

The default server is `http://localhost:7236`. If that port is not active, read the `port` from `/Users/elianiva/Library/Application Support/tldraw/server.json`.

A clean quit removes `server.json`; the next launch rewrites it. It also records `pid` and `startedAt`, so if the file is present but requests to its `port` fail, treat it as stale (the app quit uncleanly) — the app is not running.

Every request except `GET /` and `/readme` needs the per-launch `token` from that same `server.json`, sent as `-H "authorization: Bearer <token>"`.

**If the server's base URL and bearer token are already in your context** — the app injects them at subagent launch when its agent hook is installed — use those literal values directly, or just call the installed `tq` helper (below). The rest of this section is the fallback for when neither is in hand.

**Each Bash tool call runs in a fresh shell — exported env vars do NOT persist between calls.** A `TLDRAW_TOKEN` you `export` in one call is empty in the next, so the request sends `authorization: Bearer` with no token and 401s. "Export once and reuse" does not work here — re-establish the port and token on every call. Read them together at the top of each call (both stay fixed for the app's lifetime, so re-reading is cheap):

```bash
PORT=$(jq -r .port '/Users/elianiva/Library/Application Support/tldraw/server.json'); TOKEN=$(jq -r .token '/Users/elianiva/Library/Application Support/tldraw/server.json')
# use as:  http://localhost:$PORT/...   -H "authorization: Bearer $TOKEN"
```

### Helper: `tq`

A ready-made helper ships with this skill at `"$HOME/skills/tldraw-offline/tq"`. Invoke it as `sh "$HOME/skills/tldraw-offline/tq" <METHOD> <path> [body]` — it re-reads the port and token from `server.json` itself on every call, so you never handle the token or the fresh-shell env problem. A body starting with `{` is sent as JSON; anything else as raw `text/plain`:

```bash
sh "$HOME/skills/tldraw-offline/tq" POST /api/search '{"code":"return await api.getDocs()"}'
sh "$HOME/skills/tldraw-offline/tq" POST /api/doc/DOC_ID/exec 'return editor.getCurrentPageShapes().length'
sh "$HOME/skills/tldraw-offline/tq" GET  /api/doc/DOC_ID/script-status
```

If `tq` is missing (an older install), fall back to raw `curl` with the `PORT`/`TOKEN` reads shown above. The raw-`curl` examples below stay in explicit form so each request is visible; translate any to `sh "$HOME/skills/tldraw-offline/tq" <METHOD> <path> [body]`.

```bash
curl -s http://localhost:7236/readme
```

## Core endpoints

- `POST /api/search`: run JavaScript with an `api` object. Use this to discover docs, read shapes and bindings, capture screenshots, and query the editor API reference.
- `POST /api/doc/:id/exec`: run JavaScript with a live tldraw `editor` scoped to one document. Use this for saved canvas edits.
- `POST /api/doc/:id/script-workspace`: expose live script paths for direct durable document-script and asset edits.
- `GET /api/doc/:id/script-status`: inspect watcher state for `script/**` edits and find `errorLogPath`.

The code-taking POST endpoints accept raw JavaScript as the request body (`content-type: text/plain`) or a JSON body `{"code": "..."}`, and wrap the code in an async function so top-level `await` works. Prefer raw bodies for shell use.

## Use this first

Most tasks do not require searching `api.members`. Start with these calls and search the full Editor API only if a snippet fails or you truly need an unknown method. The object is `api`, not `spec`. Each block below is shown as raw `curl` so the request is visible; `sh "$HOME/skills/tldraw-offline/tq" <METHOD> <path> [body]` is the shorter equivalent that handles the port and token for you.

```bash
# Fresh shell per call: re-read port + token first (or use the values already in your context).
PORT=$(jq -r .port '/Users/elianiva/Library/Application Support/tldraw/server.json'); TOKEN=$(jq -r .token '/Users/elianiva/Library/Application Support/tldraw/server.json')

# Pick the target doc by focused window or filename.
curl -s -X POST http://localhost:$PORT/api/search \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"return await api.getDocs({ name: \"NAME\" })"}'

# Read the current page's shapes with ids, bounds, text, and metadata.
curl -s -X POST http://localhost:$PORT/api/search \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"const doc = await api.getFocusedDoc(); const page = doc ? await api.getShapes(doc.id) : null; return { doc, shapes: page?.shapes.map(s => ({ id: s.id, type: s.type, x: s.x, y: s.y, props: s.props, meta: s.meta })) ?? [] }"}'

# Read bindings only for connection-dependent behavior.
curl -s -X POST http://localhost:$PORT/api/search \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"const doc = await api.getFocusedDoc(); return doc ? await api.getBindings(doc.id) : []"}'
```

## Reference recipes

`api.recipes` (via `/api/search`) is an object keyed by recipe `id`; read one in full with `api.recipes['<id>']`. Query it when a task matches one of the worked recipes:

- `stack-existing-boxes` — Stack existing boxes
- `add-durable-behavior-with-a-document-script` — Add durable behavior with a document script
- `editable-furniture-with-anchored-internals` — Editable furniture with anchored internals
- `clickable-card-or-button-ui` — Clickable card or button UI
- `connection-dependent-behavior` — Connection-dependent behavior
- `animation-simulation-loop` — Animation / simulation loop
- `custom-shape-config-js` — Custom shape (config.js)
- `custom-overlay-config-js` — Custom overlay (config.js)

Fetch `/readme` when an endpoint fails or you need API details not covered here.

## Durable UI Behavior

For durable UI behavior, open `/script-workspace`, write `script/main.js`, check `script-status`, then verify behavior once. `script-status` returns a derived `state` field — treat `state: "applied"` as success; `"pending"` means the watcher has not caught up yet (retry once), and `"error"` means the apply failed (read `lastApplyError` / `errorLogPath`). Branch on `state` rather than comparing the raw digests yourself. The `/script-workspace` response reports `isDefaultScript` (true while `script/main.js` is still the untouched starter template, pre-created when absent) — when `isDefaultScript` is false there is a preexisting script to extend, not clobber. Read `mainJsPath` to see the current contents before editing (and read it once first if your file tools refuse to write a file they have not read). Do not spend the run searching for pointer/click APIs — read the clickable-UI recipe from `api.recipes` first.

## Shape format

`api.getShapes()`, `/exec`, and document scripts all use raw tldraw SDK records. Create shapes with normal tldraw partials. Prefer importing primitives from `'tldraw'` when the host import map is active — in an `/exec` snippet use `await import('tldraw')` (a snippet can't use a static `import`); a document script can use a top-level `import { createShapeId } from 'tldraw'`. The `helpers` bag carries only editor-bound conveniences (not SDK primitives) — import primitives from `'tldraw'` directly. Read `api.imports` (from `/api/search`) for the full list of importable symbols:

```js
const { createShapeId, toRichText } = await import('tldraw')
editor.createShape({
	id: createShapeId('box1'),
	type: 'geo',
	x: 100,
	y: 100,
	props: { geo: 'rectangle', w: 300, h: 200, richText: toRichText('Label') },
})
```

Use `api.getShapes(doc.id)` to inspect existing raw shape records before mutating them.

## Screenshots

`api.getScreenshot(docId, opts?)` captures a JPEG to a temp file and returns `{ filePath, width, height, pageName, viewport, bounds, captureMode }` — a path, not image data, so open the file yourself to look at it. `opts.size` is `'small' | 'medium' | 'large' | 'full'` (default `'small'`). `opts.mode` is `'canvas'` (default — just the shapes, framed to their bounds) or `'window'` (the whole app window: canvas plus UI chrome); use `'window'` to see UI a script's `components` override draws outside the canvas. `opts.bounds` (`{ x, y, w, h }` in page coordinates) applies to `'canvas'` mode only. Prefer reading records with `api.getShapes()`; screenshot only when visual placement is uncertain or the user asks for visual proof.

## Diagram connections

- Create every meaningful connection with `helpers.createArrowBetweenShapes(fromId, toId, options)` so both endpoints have real bindings.
- Never create a raw arrow shape for a meaningful connection. Raw unbound arrows are only appropriate for explicitly decorative marks.
- Run `helpers.getLints()` before reporting a diagram complete and address every actionable result. Fetch `/readme` for the helper recipe and the opt-out for intentional decorative arrows.

## Workflow

1. Restate the intended outcome in concrete canvas terms.
2. Choose durability:
   - Static drawing edits such as moving, arranging, labeling, or styling shapes use `/exec`.
   - Durable behavior such as clickable UI, animations, reactive layouts, or "run on open" logic uses `/script-workspace` and direct filesystem edits under `script/**`. Read the worked recipes from `api.recipes` (via `/api/search`) before building durable behavior.
3. Verify once with records from `api.getShapes()`, `api.getBindings()`, `api.getScriptStatus()`, or a screenshot when visual placement is uncertain.
5. Stop after one successful verification unless the user explicitly asks for debugging.

Never edit `.tldraw` archive files directly while they are open, and never edit `db.sqlite`, `db.sqlite-wal`, `db.sqlite-shm`, `metadata.json`, `.lock`, or `.script-workspace/**`.

## Durable script pattern: editable furniture, anchored internals

Use this when a document script draws a board that users should rearrange or restyle while script-owned animation/game pieces still follow it.

- Create user-facing furniture with stable ids and `helpers.createShapeIfMissing` / `helpers.createShapesIfMissing`; never delete and redraw it on rerun.
- Pick one visible anchor per interactive system, such as a track or table felt.
- Use `helpers.onShapeTranslate(anchorId, ({ dx, dy }) => ... , { signal })` to respond only to that anchor.
- Move script-owned internals with `helpers.translateShapes(..., dx, dy)` (it runs without recording undo history); wrap other script-owned writes in `editor.run(fn, { history: 'ignore' })`.
- Avoid broad `store.listen` / `afterChange` layout handlers that react to every shape; they can treat the script's own writes as new user edits and recurse.

## Editor customization: custom shapes, tools, and overlays (`config.js`)

Custom shape types, tools, overlays, or UI components need a `script/config.js` next to `main.js` (create it through `/script-workspace`, same as `main.js`) — a `main.js`-only script cannot register them. Its default export runs BEFORE the editor mounts, receives `{ config }` (the app's default `TldrawConfig`), and returns it after mutating or spreading it. The passed `config` carries `shapeUtils`, `bindingUtils`, `assetUtils`, `overlayUtils`, `tools` (arrays of constructors), `components` (a `TLComponents` map), and `options`; optional `getShapeVisibility(shape, editor)`, `assetUrls`, and `initialState`. Push your constructors onto the arrays — a util/tool whose static `type`/`id` matches a stock one replaces it. Custom shapes subclass `ShapeUtil` and custom overlays subclass `OverlayUtil` (both from `'tldraw'`); define them in a sibling file and `import` them, since `config.js` and `main.js` are separate module graphs.

Read the worked `custom-shape` and `custom-overlay` recipes from `api.recipes` for the full `ShapeUtil` / `OverlayUtil` skeletons before writing either. Saving `config.js` (or a file it imports) rebuilds the store and editor — document, camera, and selection are preserved but undo history resets — whereas saving `main.js` never remounts. Keep run-on-mount logic in `main.js`; `config.js` only builds the config. Types live in `.script-workspace/script-context.d.ts` (`ConfigScriptContext`, `TldrawConfig`).

## Fast path for static edits

Shown as raw `curl`; `sh "$HOME/skills/tldraw-offline/tq" <METHOD> <path> [body]` is the shorter equivalent that handles the port and token for you.

```bash
# Fresh shell per call: re-read port + token (or use the values already in your context).
PORT=$(jq -r .port '/Users/elianiva/Library/Application Support/tldraw/server.json'); TOKEN=$(jq -r .token '/Users/elianiva/Library/Application Support/tldraw/server.json')

# Discover docs.
curl -s -X POST http://localhost:$PORT/api/search \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"return await api.getDocs()"}'

# Read shapes for a doc.
curl -s -X POST http://localhost:$PORT/api/search \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"const [doc] = await api.getDocs(); return await api.getShapes(doc.id)"}'

# Mutate with /exec, then verify once with api.getShapes().
curl -s -X POST http://localhost:$PORT/api/doc/DOC_ID/exec \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{"code":"const { createShapeId, toRichText } = await import(\"tldraw\"); const id = createShapeId(\"r1\"); editor.createShape({ id, type: \"geo\", x: 100, y: 100, props: { geo: \"rectangle\", w: 200, h: 100, richText: toRichText(\"Hello\") } }); return { created: [id] }"}'
```

## Reporting

Keep summaries tight. Include the doc id/name, changed shape ids or script path, and the one verification result. If something fails, quote the server error, digest mismatch, or the relevant `.script-workspace/error.log` line.
