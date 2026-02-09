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

(Why it exists, 1–3 bullets)

## Screens / Components

- (List screens or components touched)
- User-facing flows: (brief description)

## User Flows

- (Key flows: e.g. "User logs in → sees dashboard → clicks X → Y")
- (Optional: link to wireframes or figma)

## Accessibility

- (a11y requirements: keyboard nav, ARIA, contrast, screen reader)
- (WCAG level if applicable)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

- No regressions on core flows (existing E2E or smoke tests still pass)
- (Add feature-specific invariants)

Executable (add to \_system/architecture/invariants.yml if applicable):

```yaml
invariants:
  - core_flows_e2e_pass: true
success_metrics:
  - test_pass_rate: 99.5
```

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] E2E or component tests: cover new/changed flows
- [ ] Accessibility: a11y checks pass (e.g. axe, lint)
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] No regressions: existing core-flow tests pass

## Assumptions (MUST BE EXPLICIT)

- (ex: "Design system components are accessible" — verify?)
- (ex: "Target browsers support feature X" — add check?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, money, permissions, PII
- medium: new dependencies, breaking UI changes
- low: docs, refactors, tests, internal tooling

## Kill Criteria (Stop Conditions)

- Conflicts with architecture canon
- Core flows cannot be preserved
- (Add feature-specific kill criteria)

## Rollback Plan

- Feature flag: disable feature in UI
- Revert commit: clean revert possible

## Dependencies

- (Other intent IDs that must ship first)
- (Design/UX sign-off if required)

## GitHub issue

(Optional) Link to a GitHub issue. Use `#123` or `owner/repo#123`.

- (e.g. `#42` or leave blank)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked \_system/do-not-repeat/abandoned-designs.md
- [ ] Checked \_system/do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
