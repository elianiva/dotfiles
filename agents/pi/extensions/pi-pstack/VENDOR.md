# pi-pstack vendored as pi extension

Source: https://github.com/kkgogogo17/pi-pstack @ v0.1.0 (cloned from /Users/elianiva/Development/repos/kkgogogo17/pi-pstack@main)
Upstream: https://github.com/cursor/plugins/tree/main/pstack (MIT, Copyright 2026 Lauren Tan)
Vendored: 2026-08-27 into agents/pi/extensions/pi-pstack
License: MIT (see LICENSE)

Notes:
- Self-contained pi-package per reference package.json (pi.extensions + pi.skills)
- Removed skills/bro from vendor (identical to agents/skills/bro, keep existing)
- Existing agents/skills/teach (matt's teaching workspace) renamed to agents/skills/matt-teach (name: matt-teach) so pi-pstack's teach (poteto explain) owns /skill:teach
- No other bro/teach overlaps; 43 skills vendored (44 upstream -1 bro)
- Registered as local pi package via agents/pi/settings.json packages entry

Simplified 2026-08-27: removed vendored subagent tool, now delegates via omp-distill's subagent (shared). Removed spawn/tmp helpers, kept pstack_todo/config/sessions.
