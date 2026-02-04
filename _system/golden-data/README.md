# Golden Data

This directory stores replay validation test data for regression testing.

## Purpose

Golden data captures known-good inputs and expected outputs that can be replayed through code changes to verify behavior hasn't regressed.

## Format

Golden data files are typically JSON files containing test cases:

```json
[
  {
    "input": {
      /* input data */
    },
    "expectedOutput": {
      /* expected result */
    },
    "description": "Brief description of test case"
  }
]
```

## Usage

1. **Capture golden data** from production or hand-crafted test cases
2. **Replay through code** during testing
3. **Compare outputs** to detect regressions

## Example

See `docs/PLAN.md` (in repo root docs/) Research Q11 for implementation patterns and examples of replay-based validation.

## Non-Deterministic Data

For outputs with timestamps, UUIDs, or other non-deterministic values, normalize them before comparison:

```typescript
const normalize = (output) => ({
  ...output,
  timestamp: 'NORMALIZED',
  id: 'NORMALIZED',
});
```
