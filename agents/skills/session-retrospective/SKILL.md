---
name: session-retrospective
description: At end of difficult sessions, analyze friction points and propose concrete improvements.
---

## Trigger
- User asks "what made this session hard?"
- Multiple failed attempts on same task
- User explicitly requests retrospective
- Session took significantly longer than expected

## Process

1. **Summarize Difficulties**
   - List specific moments where you struggled
   - Note repeated patterns (e.g., "3rd edit attempt failed")
   - Count iterations/wasted effort

2. **Root Cause Analysis**
   For each difficulty, identify:
   - Is it a tool limitation?
   - Is it missing information/context?
   - Is it workflow/order of operations?
   - Is it environmental (formatters, external changes)?

3. **Propose Improvements**
   Concrete solutions only:
   - New tool/extension
   - Workflow change
   - Information to pre-fetch
   - Configuration to auto-apply

4. **Estimate Impact**
   For each proposal: "Would have saved X minutes/tokens"

## Output Format
```
Difficulties:
1. [What happened] → [Root cause]
2. ...

Improvements:
1. [Solution] → [Time saved estimate]
2. ...
```

## Rules
- Be specific with examples from the session
- No vague suggestions ("be better at X")
- Each proposal must be actionable
- Prefer automation over manual steps
