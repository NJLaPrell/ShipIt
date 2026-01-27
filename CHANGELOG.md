# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
