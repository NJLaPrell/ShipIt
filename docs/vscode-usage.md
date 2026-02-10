# Using ShipIt in VS Code

You can use ShipIt from **VS Code** (with GitHub Copilot or another AI assistant) without Cursor. The same artifacts, workflow state, and scripts apply; only how you **invoke** the workflow differs.

## Same layout and scripts

- **Artifacts:** `work/intent/`, `work/workflow-state/`, `_system/`, `.cursor/commands/`, `.cursor/rules/` — all the same. Open the repo in VS Code and run scripts from the integrated terminal.
- **Scripts:** From repo root, run `pnpm workflow-orchestrator <intent-id>`, `pnpm verify <intent-id>`, `pnpm status`, etc. Same as in Cursor.
- **Headless mode:** If you want the LLM to run phases without Cursor, use [Headless mode](headless-mode.md) and set `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`; run `./scripts/headless/run-phase.sh <intent-id> <phase>` from the terminal.

## Doc-based workflow in VS Code (until the extension exists)

Cursor uses slash commands (e.g. `/ship F-001`) that inject the full command and rule content into chat. In VS Code you don’t have those slash commands by default, but you can get the same instructions into Copilot Chat:

1. **Open the command file** — e.g. `.cursor/commands/ship.md` (or the relevant command).
2. **Open the role rule** — e.g. `.cursor/rules/pm.mdc` for Phase 1 (Analysis).
3. **In Copilot Chat**, reference or paste the content: e.g. “Follow the instructions in ship.md for Phase 1 (Analysis). I am the PM. Intent: F-001. Use the PM rule in .cursor/rules/pm.mdc.”
4. **Run scripts in the terminal** — `pnpm workflow-orchestrator F-001`, then `pnpm verify F-001`, etc.

**Prompt pattern:** Tell the model which phase you’re in, which role (PM, Architect, Implementer, QA, Docs), the intent id, and point it at the command and rule files. Same content as Cursor; you’re just loading it manually or via a snippet.

## Full parity: VS Code extension (#68)

Issue **#68** tracks a **VS Code extension** that will:

- Register ShipIt commands in the Command Palette (e.g. “ShipIt: Ship”, “ShipIt: Verify”).
- Open Copilot Chat with the **exact same context** Cursor injects for slash commands (command + rule content, intent id).
- One action in VS Code → same UX as `/ship` in Cursor.

Until that extension exists, use the doc-based flow above or headless mode from the terminal.
