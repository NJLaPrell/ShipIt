# /revert-plan

Create or update a rollback plan for the current intent.

## Usage

```
/revert-plan <intent-id>
```

Example: `/revert-plan F-042`

## What It Does

Produces a rollback section to ensure changes are reversible.

## Inputs

- `intent/<intent-id>.md`
- `workflow-state/02_plan.md`
- `workflow-state/03_implementation.md` (if present)

## Output

Writes `workflow-state/rollback.md` with:

- Feature flags or toggles
- Config or migration rollback steps
- Revert commit guidance

## Instructions

1. Read the intent and plan to understand changes introduced.
2. Identify toggles, config, or data migrations that need rollback.
3. Document a step-by-step rollback procedure.
4. Save to `workflow-state/rollback.md`.

## Template

```markdown
# Rollback Plan: <intent-id>

## Feature Flags
- `FEATURE_X_ENABLED=false`

## Config Rollback
- Restore previous config values in `config/...`

## Data/Migrations
- Run down migration: `<migration_name>`

## Code Revert
- `git revert <sha>`
```
