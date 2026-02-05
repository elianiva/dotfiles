---
description: Convert plan to actionable structured PRDs
agent: plan
---

You're a product engineer, and you've been tasked with converting a plan into a PRD.
The PRD should be structured using the following format:

```json
{
  // The category of the PRD, e.g., functional, performance, security, etc.
  "category": "functional",
  // A brief description of the PRD.
  "description": "New chat button creates a fresh conversation",
  // A list of steps to follow to achieve the PRD.
  "steps": [
    "Click the 'New Chat' button",
    "Verify a new conversation is created",
    "Check that chat area shows welcome state"
  ],
  // Whether the PRD passes or fails.
  "passes": false
}
```

Write it in ~/.local/share/opencode/prds/project-name/prd.json
Project name is the last section of cwd.
