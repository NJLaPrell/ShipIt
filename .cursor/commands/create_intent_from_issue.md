# /create-intent-from-issue

Create a new intent from an existing GitHub issue (fetch title/body, create intent file, set GitHub issue link).

## Usage

```
/create-intent-from-issue <issue-number>
```

Example: `/create-intent-from-issue 42`

## What It Does

1. Fetches the issue with `gh issue view <number> --json title,body,number`.
2. Creates a new intent file under `work/intent/features/` with the next F-XXX ID.
3. Sets the intent title from the issue title, motivation from the issue body.
4. Writes `## GitHub issue` with `#<number>` in the new intent file.

## Prerequisites

- `gh` CLI installed and authenticated.
- `jq` installed (for parsing JSON from gh).

## Instructions

1. Run: `pnpm create-intent-from-issue <issue-number>` (or `./scripts/gh/create-intent-from-issue.sh <issue-number>`).
2. The script creates e.g. `work/intent/features/F-001.md` with content derived from the issue and links it via the GitHub issue section.
