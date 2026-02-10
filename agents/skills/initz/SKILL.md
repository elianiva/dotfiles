---
name: initz
version: 1.0.0
description: Initialize or improve AGENTS.md
---

# AGENTS.md Initialization

Analyze this codebase and create an AGENTS.md file containing:

1. Build/lint/test commands - especially for running a single test
2. Code style guidelines including imports, formatting, types, naming conventions, error handling, etc.

## Guidelines

- Target length: ~150 lines
- Include Cursor rules (from `.cursor/rules/` or `.cursorrules`) if present
- Include Copilot rules (from `.github/copilot-instructions.md`) if present
- If there's already an AGENTS.md at `${path}`, improve it

## Progressive Disclosure Approach

1. **Find contradictions**: Identify conflicting instructions and ask which to keep
2. **Identify the essentials**: Extract what belongs in root AGENTS.md:
   - One-sentence project description
   - Package manager (if not npm)
   - Non-standard build/typecheck commands
   - Anything truly relevant to every single task
3. **Group the rest**: Organize remaining instructions into logical categories (TypeScript conventions, testing patterns, API design, Git workflow)
4. **Create the file structure**:
   - Minimal root AGENTS.md with markdown links to separate files
   - Each separate file with relevant instructions
   - Suggested docs/ folder structure
5. **Flag for deletion**: Identify redundant, vague, or overly obvious instructions

$ARGUMENTS
