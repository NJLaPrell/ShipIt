# /create-pr

Generate a PR summary (if needed) and create a GitHub PR for the current intent.

## Usage

```
/create-pr <intent-id>
```

Example: `/create-pr F-001`

## What It Does

1. Ensures `work/workflow-state/pr.md` exists (or `work/workflow-state/<intent-id>/pr.md` for per-intent layout). If missing, the user should run `/pr <intent-id>` first.
2. Runs `pnpm gh-create-pr <intent-id>` (or `./scripts/gh/create-pr.sh <intent-id>`) to create a GitHub PR with the PR body from that file.

## Prerequisites

- `gh` CLI installed and authenticated.
- Current branch has commits to push (PR will be created from current branch).
- Intent has workflow state and `/pr` has been run so pr.md exists.

## Instructions

1. If `work/workflow-state/pr.md` (or `work/workflow-state/<intent-id>/pr.md`) does not exist, run `/pr <intent-id>` first to generate it.
2. Run: `pnpm gh-create-pr <intent-id>` (or `./scripts/gh/create-pr.sh <intent-id>`).
3. The script creates the PR with title from the intent and body from pr.md.
