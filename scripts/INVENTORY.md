# Scripts Inventory

Inventory of all scripts in `./scripts` and their usage status.

## Active Scripts (Used in package.json or command-manifest.yml)

### Core Workflow

- ✅ `workflow-orchestrator.sh` - Main workflow orchestrator (package.json: `workflow-orchestrator`)
- ✅ `verify.sh` - Verification phase (package.json: `verify`)
- ✅ `kill-intent.sh` - Kill an intent (package.json: `kill-intent`)

### Intent Management

- ✅ `new-intent.sh` - Create new intent (package.json: `new-intent`)
- ✅ `fix-intents.sh` - Auto-fix intent issues (package.json: `fix`)

### Project Setup

- ✅ `init-project.sh` - Initialize project (package.json: `init-project`)
- ✅ `scope-project.sh` - AI-assisted feature breakdown (package.json: `scope-project`)

### Planning

- ✅ `generate-release-plan.sh` - Generate release plan (package.json: `generate-release-plan`)
- ✅ `generate-roadmap.sh` - Generate roadmap (package.json: `generate-roadmap`)

### Operations

- ✅ `deploy.sh` - Deploy with readiness checks (package.json: `deploy`)
- ✅ `check-readiness.sh` - Run readiness checks (package.json: `check-readiness`)
- ✅ `drift-check.sh` - Calculate drift metrics (package.json: `drift-check`)
- ✅ `execute-rollback.sh` - Execute rollback (package.json: `execute-rollback`)

### Generation

- ✅ `generate-docs.sh` - Update docs (package.json: `generate-docs`)
- ✅ `generate-dashboard.sh` - Generate dashboard (package.json: `generate-dashboard`)
- ✅ `generate-project-context.sh` - Generate project context (package.json: `generate-context`)
- ✅ `generate-system-state.sh` - Generate SYSTEM_STATE.md (package.json: `generate-system-state`)

### Validation

- ✅ `validate-project.sh` - Validate project.json (package.json: `validate-project`)
- ✅ `validate-cursor.sh` - Validate Cursor integration (package.json: `validate-cursor`)
- ✅ `validate-vscode.sh` - Validate VS Code integration (package.json: `validate-vscode`)

### Help & Status

- ✅ `help.sh` - Show help (package.json: `help`)
- ✅ `status.sh` - Show status (package.json: `status`)
- ✅ `suggest.sh` - Suggest next actions (package.json: `suggest`)

### Metrics & Reporting

- ✅ `usage.sh` - Record usage (package.json: `usage-record`)
- ✅ `usage-report.sh` - Show usage report (package.json: `usage-report`)
- ✅ `calibration-report.sh` - Confidence calibration report (package.json: `calibration-report`)
- ✅ `collect-metrics.sh` - Collect metrics (package.json: `collect-metrics`)

### GitHub Integration

- ✅ `gh/create-issue-from-intent.sh` - Create issue from intent (package.json: `gh-create-issue`)
- ✅ `gh/link-issue.sh` - Link issue (package.json: `gh-link-issue`)
- ✅ `gh/create-pr.sh` - Create PR (package.json: `gh-create-pr`)
- ✅ `gh/create-intent-from-issue.sh` - Create intent from issue (package.json: `create-intent-from-issue`)
- ✅ `gh/on-ship-update-issue.sh` - Update issue on ship (package.json: `on-ship-update-issue`)

### Dashboard

- ✅ `dashboard-start.sh` - Start dashboard (package.json: `dashboard`)
- ✅ `export-dashboard-json.js` - Export dashboard JSON (package.json: `export-dashboard`)

### Headless Mode

- ✅ `headless/run-phase.sh` - Run phase in headless mode (package.json: `headless-run-phase`)

### Testing

- ✅ `test-shipit.sh` - Test ShipIt framework (package.json: `test:shipit`)

### Publishing

- ✅ `publish-npm.sh` - Publish to npm (package.json: `publish:npm`) - **Note:** Also used by CI workflow

## Potentially Unused or Temporary Scripts

### Test Scripts (Not in package.json)

- ⚠️ `test-headless.sh` - Smoke test for headless mode (issue #65)
  - **Status:** Only referenced in its own file
  - **Usage:** Manual testing script
  - **Recommendation:** Keep if still needed for manual testing, or move to tests/ directory

- ⚠️ `test-workflow-state.sh` - Smoke test for workflow-state layout (issue #60)
  - **Status:** Only referenced in its own file
  - **Usage:** Manual testing script
  - **Recommendation:** Keep if still needed for manual testing, or move to tests/ directory

### Experimental/Helper Scripts (Not in package.json)

- ⚠️ `setup-worktrees.sh` - Setup git worktrees for parallel work
  - **Status:** Referenced in docs/PLAN.md and .cursor/commands/ship.md
  - **Usage:** Experimental feature for parallel agent work
  - **Recommendation:** Keep if experimental feature is still in use, or document as experimental

- ⚠️ `create-test-plan-issue.sh` - Create GitHub issues from test failures
  - **Status:** Referenced in docs, init-project.sh copies it, but not in package.json
  - **Usage:** Helper script for test plan issues
  - **Recommendation:** Add to package.json if actively used, or document as optional helper

### Security

- ✅ `audit-check.sh` - Run npm audit (used by verify.sh, check-readiness.sh, CI)
  - **Status:** Used by other scripts and CI, but not directly in package.json
  - **Recommendation:** Consider adding to package.json for direct access

## Shared Libraries (lib/)

All libraries in `scripts/lib/` are actively used:

- ✅ `common.sh` - Common utilities (sourced by many scripts)
- ✅ `intent.sh` - Intent resolution (sourced by workflow-orchestrator, kill-intent, etc.)
- ✅ `progress.sh` - Progress indicators
- ✅ `suggest-next.sh` - Next-step suggestions
- ✅ `validate-intents.sh` - Intent validation
- ✅ `verify-outputs.sh` - Output verification
- ✅ `workflow_state.sh` - Workflow state management

## Summary

**Total scripts:** ~50+

- **Active (in package.json):** ~35
- **Potentially unused/temporary:** 4
  - `test-headless.sh` - Manual test script
  - `test-workflow-state.sh` - Manual test script
  - `setup-worktrees.sh` - Experimental feature
  - `create-test-plan-issue.sh` - Helper script (not in package.json)

**Recommendations:**

1. **Move test scripts** (`test-headless.sh`, `test-workflow-state.sh`) to `tests/` directory if they're still needed
2. **Document experimental scripts** (`setup-worktrees.sh`) clearly or remove if unused
3. **Add helper scripts to package.json** (`create-test-plan-issue.sh`, `audit-check.sh`) if they should be directly accessible
4. **Review `publish-npm.sh`** - Currently used by both package.json and CI workflow; ensure it's still needed in both places
