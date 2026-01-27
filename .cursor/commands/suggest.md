# /suggest

Get suggested next actions based on current project state.

## Usage

```
/suggest
```

## What It Does

Analyzes your project state and suggests actionable next steps, such as:

- **No intents?** → Suggest scoping or creating first intent
- **Planned intents?** → Suggest starting work on one
- **Active intent?** → Suggest continuing workflow based on current phase
- **Pending approval?** → Remind you to approve the plan
- **Stale plans?** → Suggest regenerating release plan or roadmap

## Example Output

```
ShipIt Suggestions

1. Start working on an intent: /ship F-001
2. Update release plan: /generate-release-plan
3. Update roadmap: /generate-roadmap

More help: /help [command]
Project status: /status
```

## When to Use

- You're not sure what to do next
- You want to see what needs attention
- You want actionable suggestions based on your project state
- You're onboarding to a new ShipIt project

## Related Commands

- `/status` - See detailed project status
- `/help` - Get help on specific commands
