# Using ShipIt in VS Code

ShipIt runs the **same workflow** in Cursor and in VS Code (with GitHub Copilot). Same steps: ship an intent, verify, open PR, etc. Only **how you invoke** differs.

## One workflow

- **Ship an intent:** Run the full 6-phase SDLC for an intent id (e.g. F-001).
- **Verify:** Re-run verification only (`pnpm verify <intent-id>`).
- **PR / Create PR:** Generate PR summary or create the GitHub PR for an intent.
- **Status, help, suggest, drift-check, deploy, rollback, etc.** — same commands and scripts in both editors.

Artifacts and layout are identical: `work/intent/`, `work/workflow-state/`, `_system/`, `.cursor/commands/`, `.cursor/rules/`. Scripts: `pnpm workflow-orchestrator <intent-id>`, `pnpm verify <intent-id>`, `pnpm status`, etc.

## How to invoke (editor-specific)

### Cursor

- Slash commands: `/ship F-001`, `/verify F-001`, `/pr F-001`, etc.
- Commands inject the full command and rule content into chat.

### VS Code (with ShipIt extension + Copilot Chat)

1. **Install the ShipIt extension** from the repo: open `vscode-extension/` in VS Code and run “Run Extension” from the debug sidebar, or build a VSIX with `vsce package` and install from VSIX.
2. **Command Palette** (Ctrl+Shift+P / Cmd+Shift+P) → e.g. **ShipIt: Ship**, **ShipIt: Verify**, **ShipIt: PR**.
3. For commands that need an intent id (Ship, Verify, PR, Rollback, etc.), enter the intent id when prompted or use “Use intent from open file” if an intent file is active.
4. Copilot Chat opens with the **same context** Cursor would inject (command content + intent id). Press Enter to send.

One action in VS Code (Command Palette → ShipIt: Ship → intent id) gives the same UX as `/ship <intent-id>` in Cursor.

## Validation

- **Cursor:** From repo root, run `pnpm validate-cursor`.
- **VS Code:** From repo root, run `pnpm validate-vscode`. Then in VS Code, confirm Command Palette shows ShipIt commands and that running one opens Copilot Chat with the prompt.

## Headless / terminal-only

Scripts and headless mode work the same in any editor. From the terminal: `pnpm workflow-orchestrator <intent-id>`, `pnpm verify <intent-id>`, `./scripts/headless/run-phase.sh <intent-id> <phase>`. See [Headless mode](headless-mode.md).

## Fallback: doc-based workflow in VS Code (no extension)

If you don’t use the extension, you can still run the same workflow by loading context manually:

1. Open the command file (e.g. `.cursor/commands/ship.md`) and, if needed, the role rule (e.g. `.cursor/rules/pm.mdc`).
2. In Copilot Chat, reference or paste the content and state intent id and phase/role.
3. Run scripts in the terminal as usual.

Same content as Cursor; you’re just loading it manually.
