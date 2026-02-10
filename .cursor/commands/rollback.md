# /rollback

Execute rollback for an intent in guided mode. Reads the rollback plan produced by /revert-plan and walks through steps with confirmation.

## Usage

```
/rollback <intent-id>
```

Example: `/rollback F-042`

Or from CLI: `pnpm execute-rollback F-042`

## What It Does

1. Resolves the rollback plan path per [workflow-state-layout.md](_system/architecture/workflow-state-layout.md):
   - If `work/workflow-state/<intent-id>/` exists: read `rollback.md` or rollback section in `02_plan.md`
   - Otherwise: read flat `work/workflow-state/rollback.md` or rollback section in `work/workflow-state/02_plan.md`
2. Presents each step from the rollback plan
3. **High-risk steps** (force, drop, delete, migration down, production, auth, secret): display only — user runs manually
4. **Safe steps** (e.g. simple `git revert <sha>`): prompt "Run this? [y/N]", execute if user confirms
5. Append outcomes to `work/workflow-state/rollback-log.md` (audit log)

## Options

- `--dry-run`: Print steps and classification (auto vs manual) without executing

## Safety

- No automatic force-push, no automatic data deletion
- Destructive steps are never auto-executed
- Before executing any step that touches production, infra, or data, the user must have reviewed the rollback plan
- Run rollback for one intent at a time; do not run parallel rollbacks

## Prerequisites

Run `/revert-plan <intent-id>` first to create the rollback plan. If no plan exists, the command fails with "No rollback plan; run /revert-plan <intent-id> first."

## When to Use

- After shipping an intent that needs to be reverted
- When a rollback plan exists and you want guided execution with confirmations
