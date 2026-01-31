---
name: jj
description: Uses the jj (Jujutsu) version control system. Use when asked about jj commands, git push/fetch workflow, or rebasing onto main for non git repo
---

# jj (Jujutsu) Workflow

Jujutsu is a Git-compatible VCS. This documents the user's workflow.

## Aliases
- jj tug: Move closest bookmark to @- (Advances bookmark to parent of working copy)
- jj retrunk: Rebase onto trunk() (Rebases current branch onto latest main/master)
- jj lg: Log recent 10 (Shows all revisions, limit 10)
- jj compare: Compare working copy with parent (Shows changes between working copy and parent)

## Key Concepts
- `@` refers to the working copy commit
- `@-` refers to the parent of working copy
- `trunk()` finds the most recent main/master/trunk on remote
- `closest_bookmark(@-)` finds the nearest bookmark ancestor

## Conflict Resolution
When conflicts occur after `jj retrunk`:
1. `jj status` shows conflicted files
2. Edit files to resolve conflicts
3. `jj squash` or continue working - jj auto-tracks changes
