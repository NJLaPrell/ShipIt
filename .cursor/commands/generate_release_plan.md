# /generate-release-plan

Generate a release plan from intents (priorities, dependencies, and status).

## Usage

```
/generate-release-plan
```

## What It Does

1. **Reads intents:**
   - Scans `work/intent/` for intent files
   - Extracts priority, effort, status, dependencies
2. **Plans releases:**
   - Orders intents by dependency and priority
   - Buckets into releases (R1, R2, R3)
3. **Writes output:**
   - Creates `work/release/plan.md`
   - Lists missing dependencies and exclusions

## Output

Creates:

- `work/release/plan.md` - Ordered release plan with dependencies

## See Also

- `scripts/generate-release-plan.sh` - Underlying script
