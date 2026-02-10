---
name: prd
version: 1.0.0
description: Convert plan to actionable structured PRDs
---

# PRD Generation

Convert plans into actionable structured Product Requirements Documents (PRDs).

## PRD Format

```json
{
  "category": "functional",
  "description": "Brief description of the feature",
  "steps": [
    "Step 1: Action to take",
    "Step 2: Verification step",
    "Step 3: Expected outcome"
  ],
  "passes": false
}
```

## Output Location

Write to: `~/.local/share/opencode/prds/{project-name}/prd.json`

Project name is the last section of the current working directory.

$ARGUMENTS
