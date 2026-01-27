# /status

Show current ShipIt project status.

## Usage

```
/status
```

## What It Shows

- **Active Intent** - Current intent being worked on (if any)
- **Intent Status** - Counts of intents by status (planned, active, shipped, killed, etc.)
- **Workflow State** - Which workflow phase files exist
- **Recent Intents** - Last 5 intents created
- **Pending Approvals** - Any approvals waiting for human input
- **Quick Actions** - Suggested next steps

## Example Output

```
════════════════════════════════════════
ShipIt Project Status
════════════════════════════════════════

Project: my-project

Active Intent:
  ID: F-001
  Status: active
  Phase: 02_planning

Intent Status:
  Planned: 3
  Active: 1
  Blocked: 0
  Validating: 0
  Shipped: 2
  Killed: 1
  Total: 7

Workflow State:
  ✓ 01_analysis
  ✓ 02_plan
  ○ 03_implementation (not started)
  ○ 04_verification (not started)
  ○ 05_release_notes (not started)
  ○ 06_shipped (not started)

Recent Intents:
  F-005: Add user authentication (planned)
  F-004: Database migration (shipped)
  F-003: API endpoint (shipped)
  F-002: Data model (active)
  F-001: Initial setup (killed)

⚠ Pending Approval:
  Plan approval required in workflow-state/02_plan.md

Quick Actions:
  → Continue workflow for active intent
  → Run /status to see current phase
```

## When to Use

- Check what's currently active in your project
- See how many intents are in each status
- Find out what phase you're in
- Get quick suggestions for next steps
