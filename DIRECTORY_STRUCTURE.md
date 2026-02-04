# Directory Structure

Quick reference for ShipIt project layout. **Authoritative source:** [architecture/CANON.md](./architecture/CANON.md).

## First-Class Directories

| Directory         | Purpose                                                                                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `intent/`         | Planned work (features/, bugs/, tech-debt/)                                                                                                               |
| `architecture/`   | CANON.md, invariants.yml, schemas, ADRs                                                                                                                   |
| `workflow-state/` | Phase files (01_analysis → 05_release_notes), status (active, blocked, shipped), assumptions                                                              |
| `do-not-repeat/`  | Failed approaches: abandoned-designs, bad-patterns, failed-experiments, rejected-libraries                                                                |
| `src/`            | Production source code                                                                                                                                    |
| `tests/`          | Test code (routes/, release-plan/), fixtures.json, run logs (ISSUES\*.md), process docs (TEST_PLAN, templates). See [tests/README.md](./tests/README.md). |
| `artifacts/`      | Generated files (SYSTEM_STATE.md, dependencies.md, confidence-calibration.json)                                                                           |
| `release/`        | Generated release plan (plan.md)                                                                                                                          |
| `roadmap/`        | Generated triage (now.md, next.md, later.md)                                                                                                              |
| `scripts/`        | Shell scripts + lib/ for shared helpers                                                                                                                   |
| `security/`       | audit-allowlist.json                                                                                                                                      |
| `behaviors/`      | Release procedures, issue tracking rules, platform work                                                                                                   |
| `reports/`        | Generated reports (mutation/, etc.)                                                                                                                       |
| `golden-data/`    | Replay validation test data                                                                                                                               |
| `projects/`       | Initialized ShipIt projects (from /init-project). See [projects/README.md](./projects/README.md). Contents gitignored except .gitkeep.                    |
| `drift/`          | Baselines and metrics for entropy monitoring                                                                                                              |
| `.cursor/`        | commands/, rules/, agents/ (Cursor config)                                                                                                                |

## artifacts/ (Generated)

- `artifacts/SYSTEM_STATE.md` — Generated summary for Steward
- `artifacts/dependencies.md` — Generated dependency graph
- `artifacts/confidence-calibration.json` — Confidence vs outcomes

## Root Files (Key)

- `AGENTS.md` — Role definitions, conventions
- `README.md` — Quick start, usage
- `project.json` — Project metadata (in initialized projects)
