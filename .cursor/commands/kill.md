# /kill

Kill an intent with rationale and rollback notes.

## Usage

```
/kill <intent-id> [reason]
```

Example: `/kill F-042 "Cannot satisfy latency invariant"`

## What It Does

1. **Marks intent as killed:**
   - Updates intent file: `status: killed`
   - Records kill date and reason

2. **Documents rationale:**
   - Which kill criteria were triggered
   - Why the intent cannot proceed
   - What was attempted

3. **Rollback notes:**
   - What needs to be reverted (if implementation started)
   - Database migrations to roll back
   - Feature flags to disable

4. **Updates workflow state:**
   - Marks `workflow-state/active.md` as killed
   - Archives state files

## Kill Criteria

An intent is killed when ANY of these trigger:
- Cannot satisfy latency invariant without major redesign
- Requires breaking schema compatibility beyond allowed versions
- Adds >20% complexity to core execution path
- Conflicts with architecture canon
- Requires >N days without progress
- Cost exceeds budget by >X%

## Output

Updates `/intent/<intent-id>.md`:
```markdown
## Status
killed

## Kill Rationale
- Kill criterion: Cannot satisfy latency invariant
- Reason: [detailed explanation]
- Date: 2026-01-12
```

## Who Can Kill

- **Steward:** Can kill any intent
- **Any agent:** Can propose kill (Steward decides)
- **Human:** Can override any kill decision
