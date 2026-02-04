# tests/

Test code, fixtures, run logs, and process docs. **Concerns are mixed in one directory**; see below for the breakdown and target structure.

## Current Structure (by concern)

| Concern                  | Files                                                                                                     | Purpose                                                        |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Executable test code** | `routes/*.test.ts`, `release-plan/*.test.ts`                                                              | Unit/integration tests run by Vitest                           |
| **Fixtures**             | `fixtures.json`                                                                                           | Hardcoded inputs for test runs (used by `test_shipit` command) |
| **Run logs**             | `ISSUES.md`, `ISSUES_HISTORIC.md`                                                                         | Test run summaries; latest run vs archived                     |
| **Process docs**         | `TEST_PLAN.md`, `ISSUE_TEMPLATE.md`, `ISSUE_RESEARCH_TEMPLATE.md`, `ISSUE_RESOLUTION_COMMENT_TEMPLATE.md` | How to run tests, how to file issues, resolution format        |

## References

- **Test discovery:** `vitest.config.ts` includes `tests/**/*.test.ts`
- **Issue workflow:** `behaviors/WORK_TEST_PLAN_ISSUES.md` (templates, recording rules)
- **Test execution:** `.cursor/commands/test_shipit.md`, `.cursor/rules/test-runner.mdc`

## Target Structure (future release)

When separating concerns in a later release, the proposed layout:

```
tests/
  unit/              # routes/, release-plan/ (executable test code)
  fixtures/          # fixtures.json

docs/
  test-planning/     # TEST_PLAN.md, ISSUE_*_TEMPLATE.md
  test-results/      # or reports/test-results/ for ISSUES.md, ISSUES_HISTORIC.md
```

**Required updates when restructuring:** `vitest.config.ts`, `package.json` (if paths change), `behaviors/WORK_TEST_PLAN_ISSUES.md`, `.cursor/commands/test_shipit.md`, `.cursor/rules/test-runner.mdc`, `scripts/init-project.sh`, and any docs that reference these paths.
