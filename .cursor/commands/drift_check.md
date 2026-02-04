# /drift_check

Calculate and record drift metrics to detect system entropy.

## Usage

```
/drift_check
```

## What It Does

Runs the drift metrics script and updates `generated/drift/metrics.md` with:

1. **PR Size Trend** - Average files changed in last 20 PRs
2. **Test-to-Code Ratio** - Ratio of test lines to code lines
3. **Dependency Growth** - Count of dependencies and devDependencies
4. **Untracked New Concepts** - New files without corresponding intents
5. **CI Performance** - Time-to-green metrics (manual update)

## Output

Updates `generated/drift/metrics.md` with current metrics and compares against baselines in `generated/drift/baselines.md`.

## When to Use

- Weekly automated check (via CI)
- Before major releases
- When investigating system entropy
- After significant refactoring

## See Also

- `scripts/drift-check.sh` - The underlying script
- `generated/drift/baselines.md` - Baseline thresholds
- `generated/drift/metrics.md` - Current metrics
