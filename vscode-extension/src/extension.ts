import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

// Commands that require an intent id (prompt user or infer from open file)
const NEEDS_INTENT = new Set([
  'ship',
  'verify',
  'pr',
  'rollback',
  'kill',
  'create-pr',
  'revert-plan',
  'risk',
]);

// Map manifest id -> .cursor/commands filename (most: hyphen -> underscore; revert-plan stays)
function commandFileName(id: string): string {
  if (id === 'revert-plan') {
    return 'revert-plan.md';
  }
  return id.replace(/-/g, '_') + '.md';
}

function getWorkspaceRoot(): string | undefined {
  const folder = vscode.workspace.workspaceFolders?.[0];
  return folder?.uri.fsPath;
}

function inferIntentFromActiveEditor(): string | undefined {
  const doc = vscode.window.activeTextEditor?.document;
  if (!doc) {
    return undefined;
  }
  const p = doc.uri.fsPath;
  // work/intent/features/F-001.md or work/intent/bugs/B-001.md etc.
  const match = p.match(/[/\\]work[/\\]intent[/\\][^/\\]+[/\\]([^/\\]+)\.md$/);
  return match ? match[1] : undefined;
}

async function resolveIntentId(commandId: string): Promise<string | undefined> {
  const inferred = inferIntentFromActiveEditor();
  const choices: string[] = [];
  if (inferred) {
    choices.push(`Use intent from open file (${inferred})`);
  }
  choices.push('Enter intent id manually...');

  const pick = await vscode.window.showQuickPick(choices, {
    title: `ShipIt: ${commandId}`,
    placeHolder: 'Select or enter intent id',
  });

  if (!pick) {
    return undefined;
  }
  if (inferred && pick.startsWith('Use intent')) {
    return inferred;
  }
  return vscode.window.showInputBox({
    prompt: 'Intent id (e.g. F-001)',
    placeHolder: 'F-001',
    validateInput: (value) => (value.trim().length > 0 ? null : 'Intent id is required'),
  });
}

function buildPrompt(
  commandContent: string,
  commandId: string,
  intentId: string | undefined
): string {
  const intentLine = intentId !== undefined ? `Intent: ${intentId}. ` : '';
  return `You are running the ShipIt "${commandId}" workflow. ${intentLine}Follow the instructions below exactly.\n\n${commandContent}`;
}

async function runShipitCommand(commandId: string): Promise<void> {
  const root = getWorkspaceRoot();
  if (!root) {
    vscode.window.showErrorMessage('ShipIt: No workspace folder open.');
    return;
  }

  const commandsDir = path.join(root, '.cursor', 'commands');
  const fileName = commandFileName(commandId);
  const filePath = path.join(commandsDir, fileName);

  if (!fs.existsSync(filePath)) {
    vscode.window.showErrorMessage(`ShipIt: Command file not found: .cursor/commands/${fileName}`);
    return;
  }

  let intentId: string | undefined;
  if (NEEDS_INTENT.has(commandId)) {
    intentId = await resolveIntentId(commandId);
    if (intentId === undefined) {
      return; // user cancelled
    }
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  const prompt = buildPrompt(content, commandId, intentId);

  try {
    await vscode.commands.executeCommand('workbench.action.chat.open', {
      query: prompt,
      isPartialQuery: false,
    });
  } catch (err) {
    vscode.window.showErrorMessage(
      `ShipIt: Failed to open chat — ${err instanceof Error ? err.message : String(err)}`
    );
  }
}

export function activate(context: vscode.ExtensionContext): void {
  const commandIds = [
    'init-project',
    'scope-project',
    'new-intent',
    'kill',
    'ship',
    'verify',
    'generate-release-plan',
    'generate-roadmap',
    'deploy',
    'drift-check',
    'risk',
    'help',
    'status',
    'suggest',
    'pr',
    'create-pr',
    'create-intent-from-issue',
    'revert-plan',
    'rollback',
    'dashboard',
  ];

  for (const id of commandIds) {
    context.subscriptions.push(
      vscode.commands.registerCommand(`shipit.${id}`, () => runShipitCommand(id))
    );
  }
}

export function deactivate(): void {}
