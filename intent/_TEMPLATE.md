# F-###: Title

## Type
feature | bug | tech-debt

## Status
planned | active | blocked | validating | shipped | killed

## Motivation
(Why it exists, 1–3 bullets)

## Confidence
Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)
Written in dual form: human-readable AND executable

Human-readable:
- No PII stored unencrypted
- p95 latency < 200ms
- Schema backward compatible for 3 versions

Executable (add to architecture/invariants.yml):
```yaml
invariants:
  - no_pii_unencrypted
  - p95_latency_ms: 200
  - schema_backward_compat_versions: 3
success_metrics:
  - test_pass_rate: 99.5
  - zero_data_loss_on_replay: true
```

## Acceptance (Executable)
These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Tests: `<test_name>` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] Observability: metric X emitted (if applicable)
- [ ] Contract: API response matches schema (if applicable)
- [ ] Performance: p95 < budget (if applicable)

## Assumptions (MUST BE EXPLICIT)
Every assumption is a potential bug. List them and make them testable where possible.

- (ex: "User sessions never exceed 24h" — add test?)
- (ex: "Database connection pool size is sufficient" — add monitoring?)
- (ex: "This regex handles all Unicode correctly" — add property test?)

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
- Adds >20% complexity to core execution path
- Conflicts with architecture canon
- Requires >N days without progress (define N)
- Cost exceeds budget by >X%

## Rollback Plan
REQUIRED before implementation begins.

- Feature flag: `FEATURE_X_ENABLED=false`
- Config toggle: revert to previous config
- Database: migration has corresponding down migration
- Revert commit: clean revert possible without data loss

## Dependencies
- (Other intent IDs that must ship first)
- (ADRs that must be approved)
- (External systems/APIs)

## Do Not Repeat Check
Before starting, verify this hasn't been tried before:
- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
