# Scripts

Shell scripts for the ShipIt framework. Run via `pnpm <script-name>` (see `package.json`).

## Categories

### Intent Management

- `new-intent.sh` — Create a new intent file (feature, bug, tech-debt)
- `fix-intents.sh` — Auto-fix common intent issues (dependency ordering, whitespace)
- `kill-intent.sh` — Kill an intent with rationale

### Workflow Orchestration

- `workflow-orchestrator.sh` — Generate workflow state files for `/ship` phases
- `verify.sh` — Run verification phase (tests, mutation, audit)
- `agent-coordinator.sh` — Manage task queue and agent assignment

### Generation

- `generate-release-plan.sh` — Build release plan from intents
- `generate-roadmap.sh` — Generate roadmap (now/next/later) and dependency graph
- `generate-docs.sh` — Update README, CHANGELOG, release notes
- `generate-dashboard.sh` — Generate project dashboard
- `generate-project-context.sh` — Generate project context for agents
- `generate-system-state.sh` — Generate SYSTEM_STATE.md for Steward

### Validation

- `validate-project.sh` — Validate project.json against schema
- `validate-cursor.sh` — Validate Cursor integration (rules, commands)

### Deployment

- `deploy.sh` — Deploy with readiness checks
- `check-readiness.sh` — Run readiness checks before deploy

### Project Setup

- `init-project.sh` — Initialize a new ShipIt project
- `scope-project.sh` — AI-assisted feature breakdown

### Drift & Metrics

- `drift-check.sh` — Calculate drift metrics (PR size, test ratio, deps)
- `collect-metrics.sh` — Collect metrics for reporting
- `audit-check.sh` — Run npm audit for vulnerabilities

### Utilities

- `help.sh` — List all commands with descriptions
- `status.sh` — Unified dashboard (intents, workflow, tests)
- `suggest.sh` — Suggest next intent to work on

### Test & Issue Tooling

- `create-test-plan-issue.sh` — Create GitHub issues from test failures
- `setup-worktrees.sh` — Setup git worktrees for parallel work

## Shared Libraries (`lib/`)

- `progress.sh` — Progress indicator helpers
- `suggest-next.sh` — Next-step suggestion logic
- `validate-intents.sh` — Intent validation (dependencies, circular deps)
- `verify-outputs.sh` — Output verification and generator chaining
