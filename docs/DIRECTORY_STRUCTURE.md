# Directory Structure

Quick reference for ShipIt project layout. **Authoritative source:** [\_system/architecture/CANON.md](../_system/architecture/CANON.md).

## work/ (current work)

| Directory              | Purpose                                                                                                                             |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `work/intent/`         | Planned work (features/, bugs/, tech-debt/); templates/ for kind-specific intent templates (API, frontend, infra, bugfix, refactor) |
| `work/workflow-state/` | Phase files (01_analysis → 05_release_notes), status (active, blocked, shipped), assumptions                                        |
| `work/roadmap/`        | Generated triage (now.md, next.md, later.md)                                                                                        |
| `work/release/`        | Generated release plan (plan.md)                                                                                                    |

## \_system/ (framework and generated)

| Directory                | Purpose                                                                                    |
| ------------------------ | ------------------------------------------------------------------------------------------ |
| `_system/architecture/`  | CANON.md, invariants.yml, schemas, ADRs                                                    |
| `_system/artifacts/`     | SYSTEM_STATE.md, dependencies.md, confidence-calibration.json                              |
| `_system/drift/`         | Baselines and metrics for entropy monitoring                                               |
| `_system/do-not-repeat/` | Failed approaches: abandoned-designs, bad-patterns, failed-experiments, rejected-libraries |
| `_system/behaviors/`     | Release procedures, issue tracking rules, platform work                                    |
| `_system/security/`      | audit-allowlist.json                                                                       |
| `_system/reports/`       | Generated reports (mutation/, etc.)                                                        |
| `_system/golden-data/`   | Replay validation test data                                                                |

## Other (root)

| Directory   | Purpose                                                                                                                                                                                  |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/`      | Production source code                                                                                                                                                                   |
| `tests/`    | Test code (routes/, release-plan/), fixtures.json, run logs. See [tests/README.md](../tests/README.md).                                                                                  |
| `scripts/`  | Shell scripts; `lib/` (common.sh, intent.sh, etc.); `workflow-templates/` (phases.yml + .tpl); `command-manifest.yml` for slash commands. See [scripts/README.md](../scripts/README.md). |
| `docs/`     | DIRECTORY_STRUCTURE.md, PLAN.md, PILOT_GUIDE.md                                                                                                                                          |
| `projects/` | Initialized ShipIt projects (from /init-project). See [projects/README.md](../projects/README.md).                                                                                       |
| `.cursor/`  | commands/, rules/ (Cursor config)                                                                                                                                                        |

## Root Files (Key)

- `AGENTS.md` — Role definitions and conventions
- `README.md` — Quick start, usage
- `project.json` — Project metadata (in initialized projects)
