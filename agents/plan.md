# Session Analytics Dashboard

## Data Source

`~/.pi/agent/sessions/<project-slug>/<timestamp>_<uuid>.jsonl`

Each line is a JSON event. Key types:
- `session` — metadata (id, timestamp, cwd)
- `model_change` — provider, modelId
- `thinking_level_change` — thinkingLevel
- `message` — role (user/assistant/toolResult), content, usage, cost
- `custom` — plannotator state, etc.

## Metrics to Compute

### Per Session
- duration (first → last event timestamp)
- message count (user + assistant)
- tool call count + error count
- total tokens (input + output + cacheRead + cacheWrite)
- total cost ($)
- model(s) used
- thinking level(s) used
- stop reason (toolUse, abort, etc.)
- project (from cwd)

### Per Project
- session count
- total cost
- avg messages/session
- avg duration
- error rate (sessions with tool errors / total)
- most used model
- most used thinking level

### Global
- total sessions
- total cost
- cost over time (daily/weekly)
- error rate trend
- model usage distribution
- thinking level distribution
- top projects by activity

## Dashboard Views

### 1. Overview
- Total sessions, total cost, avg cost/session
- Cost over time chart (line, daily/weekly toggle)
- Top 5 projects by session count
- Model usage pie chart

### 2. Project Detail
- Session list (sortable: date, duration, cost, messages)
- Avg messages/session gauge
- Error rate gauge
- Cost breakdown by model
- Thinking level distribution

### 3. Session Inspector
- Timeline view (events as dots, color by type)
- Message list with expandable content
- Tool call success/failure visualization
- Token usage per message (bar chart)
- Cost per message (line chart)

### 4. Health Dashboard
- Error rate by project (bar chart)
- Most failing tools (bar chart)
- Longest sessions (potential context drift)
- Cost outliers (sessions with unusually high cost)

## Tech Stack

- Runtime: Bun
- UI: React + TanStack Router (reuse existing tooling)
- DB: SQLite (better-sqlite3 or LibSQL)
- Charts: recharts or visx
- Styling: Tailwind + shadcn/ui

## Data Pipeline

```
.jsonl files → parser script → SQLite → dashboard UI
```

### Parser
- Watch `~/.pi/agent/sessions/` for new/changed `.jsonl` files
- Parse events, extract metrics
- Upsert into SQLite (session_id + event_id as key)
- Run on dashboard open or via `bun run sync`

### Schema (SQLite)

```sql
sessions (
  id TEXT PRIMARY KEY,
  project TEXT,
  started_at TEXT,
  duration_ms INTEGER,
  message_count INTEGER,
  tool_call_count INTEGER,
  tool_error_count INTEGER,
  total_input_tokens INTEGER,
  total_output_tokens INTEGER,
  total_cache_read INTEGER,
  total_cache_write INTEGER,
  total_cost REAL,
  models TEXT,          -- JSON array
  thinking_levels TEXT, -- JSON array
  stop_reasons TEXT     -- JSON array
)

messages (
  id TEXT PRIMARY KEY,
  session_id TEXT REFERENCES sessions(id),
  role TEXT,
  timestamp TEXT,
  model TEXT,
  provider TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  cache_read INTEGER,
  cache_write INTEGER,
  cost REAL,
  tool_name TEXT,
  is_error BOOLEAN,
  content_preview TEXT  -- first 200 chars
)

tools (
  id INTEGER PRIMARY KEY,
  session_id TEXT REFERENCES sessions(id),
  name TEXT,
  call_count INTEGER,
  error_count INTEGER
)
```

## File Structure

```
~/.dotfiles/agents/dashboard/
├── src/
│   ├── routes/
│   │   ├── index.tsx          # Overview
│   │   ├── project.$slug.tsx  # Project detail
│   │   └── session.$id.tsx    # Session inspector
│   ├── components/
│   │   ├── cost-chart.tsx
│   │   ├── error-gauge.tsx
│   │   ├── session-timeline.tsx
│   │   └── model-pie.tsx
│   ├── lib/
│   │   ├── parser.ts          # .jsonl → events
│   │   ├── db.ts              # SQLite queries
│   │   └── schema.ts          # DB schema
│   └── app.tsx
├── package.json
└── bun.lock
```
