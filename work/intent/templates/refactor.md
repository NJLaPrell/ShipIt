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

(Why it exists, 1–3 bullets — e.g. "Reduce duplication; enable future feature X; meet new standard")

## Current State

- (Brief description of current structure or behavior)
- (Pain points or constraints that motivate the refactor)

## Desired State

- (Target structure or behavior after refactor)
- (Success looks like: tests unchanged or added; behavior preserved)

## Scope of Change

- (In scope: modules, files, APIs to touch)
- (Out of scope: what must not change)
- (Optional: phased steps if refactor is large)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

- Behavior preserved: same observable behavior; same or more tests passing
- (Add refactor-specific invariants: e.g. no API contract change)

Executable (add to \_system/architecture/invariants.yml if applicable):

```yaml
invariants:
  - behavior_preserved: true
success_metrics:
  - test_pass_rate: 99.5
```

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Tests: unchanged or added; all pass (no behavior change unless explicitly in scope)
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] (Optional: snapshot or property tests updated if structure changed)
- [ ] (Add refactor-specific checks: e.g. bundle size, coverage)

## Assumptions (MUST BE EXPLICIT)

- (ex: "Current tests adequately cover behavior" — add gaps?)
- (ex: "No external callers depend on internal structure" — verify?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, money, permissions, infra, PII
- medium: new dependencies, public API surface change
- low: docs, internal refactors, tests, tooling

## Kill Criteria (Stop Conditions)

- Refactor would require breaking public contract without approval
- Test coverage insufficient to safely refactor
- (Add refactor-specific kill criteria)

## Rollback Plan

- Revert commit: clean revert possible (preferred for refactors)
- (If phased: which phases are independently revertible)

## Dependencies

- (Other intent IDs that must ship first)
- (ADRs or design docs if refactor is architectural)

## GitHub issue

(Optional) Link to a GitHub issue. Use `#123` or `owner/repo#123`.

- (e.g. `#42` or leave blank)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked \_system/do-not-repeat/abandoned-designs.md
- [ ] Checked \_system/do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
