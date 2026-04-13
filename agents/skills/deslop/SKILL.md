---
name: deslop
description: Remove all AI-generated slop like useless comments, try/catch blocks, and casts
---

Remove all AI-generated slop, this includes:

- Extra comments that a human wouldn't add or is inconsistent with the rest of the file, remove the what, keep the why
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file

Report at the end with only a 1-3 sentence summary of what you changed
