#!/bin/bash
# Start the ShipIt dashboard: export data first, then launch the dev server.
# Ensures fresh data whenever the dashboard is opened.
# Usage: ./scripts/dashboard-start.sh  or  pnpm dashboard

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "Exporting dashboard data..."
node scripts/export-dashboard-json.js

echo "Starting dashboard dev server..."
cd dashboard-app && pnpm dev
