## Intent

**Intent ID:** F-### (or B-###, T-###)

**Link to Intent:** `/intent/<intent-id>.md`

## Summary

Brief description of what this PR implements.

## Acceptance Criteria

- [ ] All acceptance criteria from intent file met
- [ ] Tests pass: `pnpm test`
- [ ] Lint passes: `pnpm lint && pnpm typecheck`
- [ ] No security findings
- [ ] Documentation updated (if applicable)

## Changes

- File 1: Description
- File 2: Description

## Risk Level

- [ ] Low (docs, refactors, tests, internal tooling)
- [ ] Medium (new dependencies, API changes, performance-sensitive)
- [ ] High (auth, payments, permissions, infra, PII) - **Requires human approval**

## Verification

- [ ] Manual testing completed
- [ ] Edge cases tested
- [ ] Performance impact assessed (if applicable)

## Rollback Plan

- Feature flag: `FEATURE_X_ENABLED=false`
- Revert commit: `git revert <sha>`
- Database: Down migration exists (if applicable)

## Related

- Closes #(issue number, if applicable)
- Depends on #(PR number, if applicable)
