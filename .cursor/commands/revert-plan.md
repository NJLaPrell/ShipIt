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

- `work/intent/**/<intent-id>.md` (commonly `intent/features/<intent-id>.md`)
- `work/workflow-state/02_plan.md`
- `work/workflow-state/03_implementation.md` (if present)

## Output

Writes `work/workflow-state/rollback.md` with:

- Feature flags or toggles
- Config or migration rollback steps
- Revert commit guidance

## Instructions

1. Read the intent and plan to understand changes introduced.
2. Identify toggles, config, or data migrations that need rollback.
3. Document a step-by-step rollback procedure.
4. Save to `work/workflow-state/rollback.md`.

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
