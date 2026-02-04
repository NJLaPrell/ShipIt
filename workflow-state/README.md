# Workflow State

Execution state for the ShipIt workflow. Files fall into three lifecycles:

## Phase files (per-intent)

- `01_analysis.md` — PM analysis and acceptance criteria
- `02_plan.md` — Architect plan (requires approval)
- `03_implementation.md` — Implementer progress
- `04_verification.md` — QA + Security results
- `05_release_notes.md` — Docs and release notes

**Lifecycle:** Per intent. Overwritten each `/ship` run for the active intent.

## Status files (global)

- `active.md` — Current active intent
- `blocked.md` — Blocked intents
- `shipped.md` — Shipped intents
- `validating.md` — Intents in verification

**Lifecycle:** Global. Persist across intents and runs.

## Meta files (cross-cutting)

- `assumptions.md` — Logged assumptions
- `disagreements.md` — Recorded disagreements

**Lifecycle:** Cross-cutting. Append-only during execution.
