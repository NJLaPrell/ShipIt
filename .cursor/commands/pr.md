# /pr

Generate a pull request description and checklist for an intent.

## Usage

```
/pr <intent-id>
```

Example: `/pr F-042`

## What It Does

Creates a PR-ready summary using the intent and workflow state files.

## Inputs

- `intent/<intent-id>.md`
- `workflow-state/02_plan.md`
- `workflow-state/03_implementation.md`
- `workflow-state/04_verification.md`
- `workflow-state/05_release_notes.md`

## Output

Writes `workflow-state/pr.md` with:

- Intent reference
- Summary of changes
- Verification results
- Risk level
- Rollback notes
- Checklist

## Instructions

1. Read the intent and workflow-state files listed above.
2. Summarize the implemented changes (what/why).
3. Include verification evidence (tests, lint, typecheck, audit).
4. Call out any deviations from plan.
5. Write the result to `workflow-state/pr.md`.

## Template

```markdown
# PR: <intent-id> - <title>

## Intent
- <intent-id>: <short description>

## Summary
- Change 1
- Change 2

## Verification
- `pnpm test` → PASS
- `pnpm lint && pnpm typecheck` → PASS
- `pnpm audit --audit-level=high` → PASS

## Risk Level
- low | medium | high

## Rollback
- <rollback steps or reference to workflow-state/02_plan.md>

## Checklist
- [ ] Acceptance criteria met
- [ ] Verification evidence recorded
- [ ] Rollback plan documented
```
