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
- **Issue workflow:** `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` (templates, recording rules)
- **Test execution:** `.cursor/commands/test_shipit.md`, `.cursor/rules/test-runner.mdc`
- **Editor validation:** Run `pnpm validate-cursor` in Cursor or `pnpm validate-vscode` in VS Code before or during test runs. The test plan (TEST_PLAN.md) supports both editors; in VS Code the ShipIt extension provides Command Palette commands that mirror Cursor slash commands. See [docs/vscode-usage.md](../docs/vscode-usage.md).

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

**Required updates when restructuring:** `vitest.config.ts`, `package.json` (if paths change), `_system/behaviors/WORK_TEST_PLAN_ISSUES.md`, `.cursor/commands/test_shipit.md`, `.cursor/rules/test-runner.mdc`, `scripts/init-project.sh`, and any docs that reference these paths.

## Changes since 0.5.0

- **VS Code parity:** The test plan can be run in Cursor or VS Code. Use `pnpm validate-vscode` when testing in VS Code; step 27 covers VS Code extension validation (Command Palette → ShipIt commands → Copilot Chat with same context as slash commands). Extension source: `vscode-extension/`.
