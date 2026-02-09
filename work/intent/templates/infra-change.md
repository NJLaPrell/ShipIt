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

## Resources

- (Infra resources touched: e.g. DB, queue, k8s, CDN)
- (New resources or changes to existing)

## Rollout Steps

- (Ordered steps: e.g. 1) Deploy new config 2) Migrate data 3) Switch traffic)
- (Checkpoints and validation between steps)

## Rollback

- (How to roll back each step)
- (Runbook or script references)
- (Rollback tested before rollout)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

- No single point of failure introduced
- Rollback path tested (dry run or staging)
- (Add infra-specific invariants)

Executable (add to \_system/architecture/invariants.yml if applicable):

```yaml
invariants:
  - rollback_tested: true
success_metrics:
  - zero_data_loss_on_rollback: true
```

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Infra tests or runbooks: deployment/rollback steps validated
- [ ] Rollback tested (staging or dry run)
- [ ] CLI: `pnpm test` green (if app tests apply)
- [ ] (Add infra-specific checks: e.g. health checks, capacity)

## Assumptions (MUST BE EXPLICIT)

- (ex: "Maintenance window is available" — confirm?)
- (ex: "Backup is current before migration" — verify?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, data migration, permissions, infra, PII
- medium: new dependencies, capacity, networking
- low: docs, config-only changes

## Kill Criteria (Stop Conditions)

- Rollback fails or is not tested
- Single point of failure introduced
- Data loss risk without mitigation
- (Add infra-specific kill criteria)

## Rollback Plan

REQUIRED before implementation begins. Must match "Rollback" section above.

- (Step-by-step rollback; same order as Rollout in reverse where applicable)
- (Data: down migration or restore from backup)
- (Config: revert to previous version)

## Dependencies

- (Other intent IDs that must ship first)
- (Infra team or vendor dependencies)
- (Maintenance windows)

## GitHub issue

(Optional) Link to a GitHub issue. Use `#123` or `owner/repo#123`.

- (e.g. `#42` or leave blank)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked \_system/do-not-repeat/abandoned-designs.md
- [ ] Checked \_system/do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist
