# tests/

Test code, fixtures, run logs, and process docs. **Concerns are mixed in one directory**; see below for the breakdown and target structure.

## Current Structure (by concern)

| Concern                  | Files                                                                                                     | Purpose                                                        |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Executable test code** | `routes/*.test.ts`, `release-plan/*.test.ts`, `cli/*.test.ts`                                             | Unit/integration tests run by Vitest                           |
| **CLI E2E tests**        | `cli/test-*.sh`, `cli/run-tests.sh`, `cli/test-helpers.sh`                                                | Shell-based E2E tests for shipit create/init/upgrade/check     |
| **Fixtures**             | `fixtures.json`, `cli/fixtures/`                                                                          | Hardcoded inputs for test runs (used by `test_shipit` command) |
| **Run logs**             | `ISSUES.md`, `ISSUES_HISTORIC.md`                                                                         | Test run summaries; latest run vs archived                     |
| **Process docs**         | `TEST_PLAN.md`, `ISSUE_TEMPLATE.md`, `ISSUE_RESEARCH_TEMPLATE.md`, `ISSUE_RESOLUTION_COMMENT_TEMPLATE.md` | How to run tests, how to file issues, resolution format        |

## Testing strategy (CLI-first)

ShipIt uses three test layers; each can run independently:

1. **Framework workflow tests** (this repo): Use `./scripts/init-project.sh` to create `tests/test-project/` (reads `tests/fixtures.json`, no prompts). Then run the steps in `TEST_PLAN.md` and `.cursor/commands/test_shipit.md` to validate the full ShipIt workflow (scoping, intents, /ship, /verify, etc.). These tests do **not** require the CLI to be installed.
2. **CLI tests** (`tests/cli/`): Test the CLI itself (`shipit create`, `shipit init`, `shipit upgrade`, `shipit check`) in isolation. Run with `pnpm test:cli`. See "CLI testing" below.
3. **Upgrade tests**: Covered by CLI tests (`test-upgrade.sh`) and the upgrade command’s own behavior (backup, merge, restore).

Framework tests use the internal script only; user-facing project creation is via the CLI (`create-shipit-app` or `shipit init`).

## CLI testing

The ShipIt CLI (`shipit create`, `shipit init`, `shipit upgrade`, `shipit check`) is tested by:

- **E2E (shell):** `pnpm test:cli` or `bash tests/cli/run-tests.sh`. Each test runs in an isolated temp directory, invokes the real CLI, and asserts on created files and output. Tests: `test-create.sh`, `test-check.sh`, `test-upgrade.sh`.
- **Unit (Vitest):** `tests/cli/version.test.ts` tests version comparison logic.

CI runs `pnpm test:cli` in the Test Suite job after Vitest.

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
