# /help

Show context-aware help for ShipIt commands.

## Usage

```
/help [command]
```

If no command is specified, shows a list of all available commands.

If a command is specified, shows detailed help for that command.

## Examples

```bash
/help                    # Show all commands
/help ship               # Show help for /ship
/help new_intent         # Show help for /new_intent
/help generate-roadmap    # Show help for /generate-roadmap
```

## Available Commands

- `/init-project` - Initialize a new ShipIt project
- `/scope-project` - AI-assisted feature breakdown
- `/new_intent` - Create a new intent (interactive wizard)
- `/ship` - Run full SDLC workflow
- `/verify` - Re-run verification phase
- `/kill` - Kill an intent
- `/generate-release-plan` - Build release plan
- `/generate-roadmap` - Generate roadmap
- `/deploy` - Deploy with readiness checks
- `/drift_check` - Check for entropy
- `/status` - Show project status
- `/suggest` - Get suggested next actions
