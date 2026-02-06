# Workflow State Layout

> **Authority:** This document defines how `work/workflow-state/` is structured. All scripts and features that read or write workflow state MUST follow this contract. See [CANON.md](./CANON.md) for directory boundaries.

## Purpose

Workflow state holds phase outputs (analysis, plan, implementation, verification, release) and supporting artifacts (rollback plan, PR summary, active intent). This layout supports both **single active intent** (flat files) and **multiple active intents** (per-intent directories) so that parallel work does not collide.

## Layouts

### Flat layout (current / single active intent)

When only one intent is active, state lives at the top level of `work/workflow-state/`:

- `01_analysis.md`, `02_plan.md`, `03_implementation.md`, `04_verification.md`, `05_release_notes.md`
- `active.md` — current active intent id (or list; see below)
- `rollback.md` — rollback plan (output of /revert-plan)
- `pr.md` — PR summary (output of /pr)
- `assumptions.md`, `blocked.md`, etc.

All consumers (scripts, commands, dashboard export) that read these files use these paths when no per-intent directory exists for the intent in question.

### Per-intent layout (multiple active intents)

When multiple intents are active (see Planning issue for parallel execution), each intent MAY have its own subdirectory:

- `work/workflow-state/<intent-id>/` — e.g. `work/workflow-state/F-001/`, `work/workflow-state/F-002/`
- Inside: `01_analysis.md`, `02_plan.md`, `03_implementation.md`, `04_verification.md`, `05_release_notes.md`, `rollback.md`, `pr.md` as needed.

`work/workflow-state/active.md` (flat) lists active intent ids and optionally current phase per intent. It remains at the top level.

## Contract: consumers MUST support both layouts

**Rule:** Any script or feature that reads or writes workflow state MUST resolve paths so that both layouts work:

1. **When an intent-id is known:**  
   If `work/workflow-state/<intent-id>/` exists, read/write phase files and intent-specific artifacts (e.g. `rollback.md`, `pr.md`) under `work/workflow-state/<intent-id>/`.  
   Otherwise, use the flat paths under `work/workflow-state/` (e.g. `work/workflow-state/rollback.md`).

2. **When aggregating (e.g. dashboard, status):**  
   If any subdirectories matching `work/workflow-state/[FBT]-[0-9]+/` exist, aggregate state from those directories (and optionally from flat files for backward compatibility).  
   Otherwise, read only from flat files.

3. **Creation:**  
   New workflow state for an intent MAY be written to `work/workflow-state/<intent-id>/` when the workflow supports multiple active intents; otherwise write to flat paths. Do not mix: for a given intent, use either flat or per-intent, not both.

## References

- **Parallel execution (per-intent dirs):** Implemented per the Planning issue for multiple active intents. This layout doc is the contract those changes and all consumers must follow.
- **Consumers:** Dashboard export (#62), rollback execution (#64), PR creation (#59), workflow-orchestrator, status, verify — all must resolve paths per this document.

---

_Last updated: 2026-02-05_
