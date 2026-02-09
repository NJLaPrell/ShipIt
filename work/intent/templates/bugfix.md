# F-###: Title

## Type

feature | bug | tech-debt

## Status

planned | active | blocked | validating | shipped | killed

## Priority

p0 | p1 | p2 | p3

## Effort

s | m | l

## Release Target

R1 | R2 | R3 | R4

## Motivation

(Why it exists, 1–3 bullets — e.g. "User-reported wrong result when X; impacts Y")

## Reproduction

- (Steps to reproduce the bug)
- (Environment/version where it occurs)
- (Optional: link to issue or ticket)

## Root Cause

- (Brief description of cause once known)
- (Where in code or design the fault is)

## Fix Scope

- (What will change: files, behavior, config)
- (What will NOT change — avoid scope creep)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

- No new regressions: existing tests pass; new test captures the bug and passes after fix
- (Add any other hard constraints for this fix)

Executable (add to \_system/architecture/invariants.yml if applicable):

```yaml
invariants:
  - regression_test_added: true
success_metrics:
  - test_pass_rate: 99.5
```

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Test that failed before the bug and passes after: (describe or reference test name)
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] No new regressions: full test suite (or relevant subset) passes
- [ ] (Add bug-specific checks: e.g. repro steps no longer fail)

## Assumptions (MUST BE EXPLICIT)

- (ex: "Root cause is in component X" — confirm before broad change?)
- (ex: "Fix does not require API contract change" — verify?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, money, data loss, permissions, infra, PII
- medium: new dependencies, behavior change in hot path
- low: docs, refactors, tests, internal tooling

## Kill Criteria (Stop Conditions)

- Root cause is elsewhere; fix would be a workaround only
- Fix introduces unacceptable regression or complexity
- (Add bug-specific kill criteria)

## Rollback Plan

- Revert commit: clean revert possible (preferred for bugfixes)
- (If config/feature flag: how to disable the fix)

## Dependencies

- (Other intent IDs that must ship first)
- (Blocking issues or environment requirements)

## GitHub issue

(Optional) Link to a GitHub issue. Use `#123` or `owner/repo#123`.

- (e.g. `#42` or leave blank)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked \_system/do-not-repeat/abandoned-designs.md
- [ ] Checked \_system/do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
