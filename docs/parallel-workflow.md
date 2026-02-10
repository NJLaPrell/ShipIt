# Parallel Workflow (Multiple Intents)

This doc describes how to work on **multiple intents in progress** at once (e.g. F-001 in one Cursor window and F-002 in another) without clobbering shared workflow state.

## Supported model (v1)

- **Multiple intents in progress:** More than one intent can be "active" at a time. Each intent has its own workflow state under `work/workflow-state/<intent-id>/`, so phases and artifacts do not collide.
- **Single-intent parallel phases** (e.g. QA and Implementer in parallel on the same intent) are **not** supported in v1; phases for one intent run in order.

## How to run in parallel

1. **Start the first intent** (unchanged): `/ship F-001` — state stays in flat `work/workflow-state/` (backward compatible).
2. **Start a second intent:** Run `/ship F-002` (or `pnpm workflow-orchestrator F-002`). State for F-002 is created under `work/workflow-state/F-002/`. `work/workflow-state/active.md` lists both F-001 and F-002.
3. **Use separate Cursor windows or worktrees** so each session has a clear "current" intent:
   - Window A: work on F-001 — use `/ship F-001`, `/verify F-001`, and read/write under flat or `work/workflow-state/F-001/`.
   - Window B: work on F-002 — use `/ship F-002`, `/verify F-002`; state is under `work/workflow-state/F-002/`.
4. **Status and suggestions:** `/status` shows all active intents and their phases. `/suggest` considers all actives; use `/ship <id>` or `/verify <id>` to target one.

## Conflict and safety rules

- **No shared files (v1):** Parallel intents must not touch the same files in the same phase. If two intents modify the same code paths, merge conflicts are likely; resolve them manually. We do not auto-merge or detect file-level conflicts in v1.
- **Explicit intent-id:** When multiple intents are active, always pass the intent id to slash commands and scripts (e.g. `/verify F-002`, `pnpm verify F-002`). If you omit it, scripts use "current" (e.g. the single intent in `active.md` or the first listed).
- **"Current" intent:** For a given Cursor session or terminal, "current" is either the intent-id you passed to the last command or the single intent in `active.md`. See [AGENTS.md](../AGENTS.md) and [workflow-state-layout.md](../_system/architecture/workflow-state-layout.md).

## Worktrees (optional)

To isolate work per intent at the git level, use worktrees:

```bash
git worktree add ../shipit-F-002 main
cd ../shipit-F-002
# Run /ship F-002 here; workflow state is in this worktree's work/workflow-state/
```

Share the same repo clone or use separate worktrees; `work/workflow-state/` is per clone/worktree, so each worktree can have its own active intents.

## Experimental: agent-coordinator

The script `experimental/agent-coordinator.sh` manages a task queue and agent assignment (e.g. for headless or multi-agent runs). It is **not** part of the main `/ship` workflow. To use it:

- Run from repo root: `./experimental/agent-coordinator.sh` (see script for subcommands).
- It does not replace `/ship` or the workflow-orchestrator; it is an optional layer for coordinating multiple agents or runners. Main workflow state (flat or per-intent) is still under `work/workflow-state/` as described above.
