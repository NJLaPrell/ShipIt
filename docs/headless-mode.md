# Headless Mode (Running ShipIt Outside Cursor)

This doc describes how to run the ShipIt workflow from the **CLI** (or from VS Code terminal) without Cursor slash commands. The same phases, artifacts, and rules apply; only the **invocation** differs (script + LLM API instead of Cursor chat).

## What "running ShipIt outside Cursor" means

- **Same workflow:** Analysis → Planning → Implementation → Verification → Release. Same `work/workflow-state/` files and `.cursor/commands` / `.cursor/rules` content.
- **Headless runner:** A script (`scripts/headless/run-phase.sh`) reads the same instruction files Cursor uses, builds a prompt, calls an LLM (OpenAI or Anthropic) via API, and writes the model output to the appropriate workflow-state file.
- **Human gates:** Some phases require human approval before continuing. The runner stops at those points and tells you how to approve and resume.

## Phases that can run headless

| Phase | Name           | Runs headless? | Human gate after?                |
| ----- | -------------- | -------------- | -------------------------------- |
| 1     | Analysis       | Yes            | No                               |
| 2     | Planning       | Yes            | **Yes — plan approval**          |
| 3     | Implementation | Yes            | No                               |
| 4     | Verification   | Yes            | No                               |
| 5     | Release        | Yes            | **Yes — Steward final approval** |

- **After Phase 2:** You must review `work/workflow-state/<intent-id>/02_plan.md` (or flat `work/workflow-state/02_plan.md`) and signal approval before the runner continues to implementation. Add `APPROVED` or check the approval box in the plan file, or run a script that records approval.
- **After Phase 5:** Steward (or human) approves release. Same idea: approve in the release notes or via a documented step, then run the next phase or finish.

## How to run headless

### Prerequisites

- **API key:** Set one of:
  - `OPENAI_API_KEY` — for OpenAI (e.g. GPT-4)
  - `ANTHROPIC_API_KEY` — for Anthropic (e.g. Claude)
- **Secrets:** Never commit API keys. Use env vars or a secure secret manager. Standard names above so scripts and docs stay in sync.
- **Repo layout:** Run from the ShipIt repo root. Same `work/`, `_system/`, `.cursor/` layout as Cursor; headless reads from `.cursor/commands/` and `.cursor/rules/`.

### Running one phase

```bash
# From repo root
./scripts/headless/run-phase.sh <intent-id> <phase-number>
```

Example: `./scripts/headless/run-phase.sh F-001 1` runs Phase 1 (Analysis) for intent F-001. The script:

1. Resolves workflow state dir (flat or per-intent; see [workflow-state-layout.md](../_system/architecture/workflow-state-layout.md)). For multi-intent layout, intent-id is required.
2. Reads phase instructions from `.cursor/commands/ship.md` and the role rule from `.cursor/rules/<role>.mdc`
3. Builds a prompt and calls the LLM
4. Writes the model output to the phase output file (e.g. `01_analysis.md`)
5. If the phase is 2 or 5, prints **Waiting for human approval** and exits; you approve, then run the next phase manually

### After Phase 2 (plan approval)

1. Open `work/workflow-state/02_plan.md` (or `work/workflow-state/<intent-id>/02_plan.md`)
2. Review the plan and add approval (e.g. add a line `APPROVED` or check the approval checkbox)
3. Run the next phase: `./scripts/headless/run-phase.sh <intent-id> 3`

### After Phase 5 (release / Steward)

1. Review release notes and any final gates
2. Approve per your process (edit file or run a script that records approval)
3. No further headless phase; workflow is complete unless you add automation for the final step

### Running all phases in sequence

There is no single "run all" script that bypasses human gates. Run phases 1 and 2; after you approve the plan, run 3, 4, 5. Optionally wrap in a small script that runs 1→2, prompts you to approve, then runs 3→4→5.

## Single source of instructions

Headless mode **must** read the same `.cursor/commands/` and `.cursor/rules/` files as Cursor. No separate "headless" prompt or phase definition. Phase order and content come from `ship.md` and `scripts/workflow-templates/phases.yml`. Any change to the workflow (e.g. new phase or rule) is in one place and applies to both Cursor and headless.

## Compatibility

- Headless mode is compatible with the same `.cursor/` and workflow-state layout as Cursor. If you upgrade ShipIt, re-run headless from the same repo so command and rule content stay in sync.
- Do not copy command or rule text into external systems; always read from the repo at runtime.

## Relation to Cursor and VS Code

- **Cursor:** Remains the primary path. Slash commands and rules work as today. Headless is opt-in.
- **VS Code:** You can run headless scripts from the VS Code terminal. For full VS Code parity (command palette → Copilot with same context as Cursor), see [Using ShipIt in VS Code](vscode-usage.md) and issue #68 (VS Code extension).
