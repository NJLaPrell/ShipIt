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
