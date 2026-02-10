# /dashboard

Start the ShipIt web dashboard.

## Usage

```
/dashboard
```

Or from CLI: `pnpm dashboard`

## What It Does

1. Runs `pnpm export-dashboard` to export intents, workflow state, calibration, drift, and doc links to `dashboard-app/public/dashboard.json`
2. Starts the dashboard dev server (Vite + React)
3. Opens the dashboard in your browser (or visit the URL shown)

## When to Use

- View intents (planned/active/shipped/killed) at a glance
- See current phase and active intent
- Check "waiting for approval" status for human gates
- View confidence calibration metrics
- Access documentation links
- Monitor drift metrics

## Data Source

Read-only. Data is sourced from:

- work/intent/
- work/workflow-state/
- \_system/artifacts/ (confidence-calibration.json, usage.json)
- \_system/drift/metrics.md

## Refresh

The dashboard has a "Refresh" button that reloads the JSON. For fresh data, restart `pnpm dashboard` so the export runs again before the UI loads.
