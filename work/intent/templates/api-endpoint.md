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

## Endpoint (API)

- Path: (e.g. `/api/v1/resources`)
- Method: GET | POST | PUT | PATCH | DELETE
- Request schema: (body/params)
- Response schema: (status codes, body)
- Auth: (none | API key | JWT | scope)
- Rate limit: (if applicable)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

Written in dual form: human-readable AND executable. For API: latency, backward compat.

Human-readable:

- p95 latency < 200ms (or project budget)
- Schema backward compatible for 3 versions
- (Add API-specific invariants)

Executable (add to \_system/architecture/invariants.yml):

```yaml
invariants:
  - p95_latency_ms: 200
  - schema_backward_compat_versions: 3
success_metrics:
  - test_pass_rate: 99.5
```

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Contract tests: API response matches schema; status codes documented and tested
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] Performance: p95 < budget (if applicable)
- [ ] (Add endpoint-specific checks)

## Assumptions (MUST BE EXPLICIT)

Every assumption is a potential bug. List them and make them testable where possible.

- (ex: "Auth provider returns consistent claims" — add contract?)
- (ex: "Rate limiter is configured per endpoint" — add test?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, money, data migration, permissions, infra, PII
- medium: new dependencies, API changes, performance-sensitive
- low: docs, refactors, tests, internal tooling

## Kill Criteria (Stop Conditions)

If ANY of these trigger, the intent is KILLED (not paused, not reworked—killed):

- Cannot satisfy latency invariant without major redesign
- Requires breaking schema compatibility beyond allowed versions
- Conflicts with architecture canon
- (Add API-specific kill criteria)

## Rollback Plan

REQUIRED before implementation begins.

- Feature flag or route toggle: disable endpoint
- Config revert: previous version
- Revert commit: clean revert possible without data loss

## Dependencies

- (Other intent IDs that must ship first)
- (ADRs that must be approved)
- (External systems/APIs)

## GitHub issue

(Optional) Link to a GitHub issue for tracking/collaboration. Single source of truth for the link is this intent file. Use `#123` (same repo) or `owner/repo#123`.

- (e.g. `#42` or leave blank)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked \_system/do-not-repeat/abandoned-designs.md
- [ ] Checked \_system/do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
