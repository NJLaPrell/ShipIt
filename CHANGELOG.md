# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- None

### Changed

- None

### Fixed

- None

## [0.5.0] - 2026-02-09

### Added

- **Web dashboard** (`/dashboard`) — Run with `pnpm dashboard`; exports data first, then launches UI for intents, phases, calibration, doc links.
- **Rollback execution** (`/rollback`) — Execute rollback in guided mode (reads plan from `/revert-plan`).
- **init-project** — Now includes dashboard-app and execute-rollback so `/dashboard` and `/rollback` work out of the box.

### Changed

- None

### Fixed

- None

## [0.4.0] - 2026-02-09

### Added

- **Scripts shared libraries** (`scripts/lib/common.sh`, `scripts/lib/intent.sh`) — `error_exit`, colors, `require_cmd`; intent resolution (`resolve_intent_file`, `require_intent_file`). New scripts should source these to avoid duplication.
- **Workflow phase spec and templates** (`scripts/workflow-templates/phases.yml` + `.tpl` files) — Orchestrator is spec-driven; add a phase by adding a spec entry and template. Placeholders: `{{INTENT_ID}}`, `{{DATE_UTC}}`.
- **Command manifest** (`scripts/command-manifest.yml`) — Single source of truth for slash commands (id, slash, pnpm, description, category). `help.sh` builds the "Available commands" list from it.

### Changed

- **workflow-orchestrator.sh** — Now reads phase spec and templates; no inline heredocs for phase content. Legacy `05_verification.md` still generated for backward compatibility.
- **workflow-orchestrator.sh, kill-intent.sh** — Use `lib/intent.sh` for intent resolution; removed duplicated `error_exit` and `resolve_intent_file`.
- **help.sh** — General "Available commands" list is built from `command-manifest.yml`; detailed per-command help unchanged.
- **init-project.sh** — New projects now receive `scripts/lib/`, `scripts/workflow-templates/`, and `scripts/command-manifest.yml`; `fix-intents.sh` and help/status/suggest scripts included so `/ship` and `/fix` work out of the box.

### Fixed

- None

## [0.3.0] - 2026-02-04

### Added

- None

### Changed

- **Reorganization (Plan C + Plan B):** Project layout now uses `work/` (intent, workflow-state, roadmap, release) and `_system/` (architecture, do-not-repeat, drift, behaviors, security, artifacts, reports, golden-data). Docs moved to `docs/` (DIRECTORY_STRUCTURE, PLAN, PILOT_GUIDE). All scripts, .cursor, CI, and docs updated. New projects from `/init-project` get the new layout.

### Fixed

- None

## [0.2.1] - 2026-02-04

### Added

- None

### Changed

- None

### Fixed

- None

## [0.2.0] - 2026-01-27

### Added

- **Intent validation and auto-fix** (`/fix` command)
  - Proactive validation for dependency ordering conflicts
  - Auto-fix for whitespace formatting issues
  - Detection of missing dependencies and circular dependencies
  - Preview before applying fixes
- **Output verification system**
  - Scripts automatically verify their outputs
  - Automatic chaining of dependent generators (e.g., `/scope-project` → `/generate-release-plan` → `/generate-roadmap`)
  - Clear verification summaries with checkmarks
- **Unified status dashboard** (`/status` command)
  - Comprehensive project status view
  - Intent counts by status
  - Active workflow phase tracking
  - Recent test results summary
  - Recent git commits
  - Context-aware next-step suggestions
- **Progress indicators**
  - Clear phase progress for long-running operations
  - `[Phase X/5] PhaseName... ⏳` format during execution
  - Visual completion indicators
- **Batched interactive prompts**
  - `/scope-project` now shows all questions at once with defaults
  - Review and edit answers before confirmation
  - Significantly faster scoping workflow
- **Context-aware suggestions**
  - Commands show relevant next steps after completion
  - Intelligent suggestions based on project state
  - Improved workflow discoverability

### Changed

- Enhanced `/scope-project` with batched prompts and auto-chaining
- Enhanced `/generate-release-plan` with validation warnings
- Enhanced `/generate-roadmap` with verification summaries
- Enhanced `/status` with comprehensive dashboard view
- Enhanced `/ship` workflow with progress indicators
- Improved error handling and edge case coverage

### Fixed

- Numeric validation in dependency ordering checks (prevents crashes on invalid formats)
- Temp file cleanup in fix-intents.sh (prevents leftover files)
- False positive grep matches in suggest-next.sh (more accurate intent detection)
- Fragile test parsing in status.sh (more robust pattern matching)
- Removed extraneous documentation files (cursor_todo_list_app_project_scope.md, PROJECT_NAME_IDEAS.md)
- Updated outdated reference in architecture/invariants.yml

## [0.1.0] - 2026-01-23

### Added

- Hello World API endpoint at `/hello`
- Basic HTTP server implementation
- Test suite for hello endpoint
- ShipIt framework and tooling
- Project initialization script (`/init-project`)
- Project scoping script (`/scope-project`)
- Intent management (`/new_intent`, `/kill`)
- Release planning (`/generate-release-plan`)
- Roadmap generation (`/generate-roadmap`)
- Workflow orchestration (`/ship`, `/verify`)
- Deployment readiness checks (`/deploy`)
- Drift detection (`/drift_check`)
- Comprehensive test suite with end-to-end validation

### Changed

- None

### Fixed

- Dependency ordering in release plans
- Missing dependencies detection
- Intent ID generation to prevent overwrites
- Release target handling in release plans
- Kill intent flow to update active.md
- ESLint configuration for TypeScript projects
- Workflow state file generation
