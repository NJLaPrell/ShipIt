#!/bin/bash

# Generate SYSTEM_STATE.md Script
# Creates a global summary for agents to maintain understanding

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p artifacts
STATE_FILE="artifacts/SYSTEM_STATE.md"

echo -e "${BLUE}Generating SYSTEM_STATE.md...${NC}"

# Check prerequisites
if [ -f "project.json" ]; then
    PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")
else
    PROJECT_NAME=$(jq -r '.name' package.json 2>/dev/null || echo "shipit")
fi

# Collect state information
INTENT_TOTAL=$(find intent -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null | wc -l | tr -d ' ')
INTENT_ACTIVE=$(find intent -name "*.md" ! -name "_TEMPLATE.md" -print0 2>/dev/null | xargs -0 grep -l "Status.*active" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
INTENT_PLANNED=$(find intent -name "*.md" ! -name "_TEMPLATE.md" -print0 2>/dev/null | xargs -0 grep -l "Status.*planned" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
INTENT_SHIPPED=$(find intent -name "*.md" ! -name "_TEMPLATE.md" -print0 2>/dev/null | xargs -0 grep -l "Status.*shipped" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Get active intent
ACTIVE_INTENT=$(grep -h "Intent ID:" workflow-state/active.md 2>/dev/null | grep -o "F-[0-9]*\|B-[0-9]*\|T-[0-9]*" | head -1 || echo "none")

# Get recent intents
RECENT_INTENTS=$(find intent -name "*.md" ! -name "_TEMPLATE.md" -type f -exec basename {} .md \; 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//' || echo "none")

# Generate system state
cat > "$STATE_FILE" << EOF || error_exit "Failed to generate SYSTEM_STATE.md"
# System State

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Project:** $PROJECT_NAME

## Global Summary

This file provides a global view of the system state for agents to maintain coherence.

## Intent Status

- **Total:** $INTENT_TOTAL
- **Active:** $INTENT_ACTIVE
- **Planned:** $INTENT_PLANNED
- **Shipped:** $INTENT_SHIPPED

## Current Work

- **Active Intent:** $ACTIVE_INTENT
- **Recent Intents:** $RECENT_INTENTS

## System Health

- **Workflow State:** [Check workflow-state/active.md]
- **Drift Status:** [Check drift/metrics.md]
- **Test Coverage:** [Run: pnpm test:coverage]

## Key Decisions

[Recent architectural decisions]

## Blockers

[Current blockers and dependencies]

## Next Actions

[Planned next actions]

---

*This file is auto-generated. Run \`pnpm generate-system-state\` to update.*
*Agents should read this file first to understand global state.*
EOF

echo -e "${GREEN}✓ Generated $STATE_FILE${NC}"
echo ""
echo -e "${YELLOW}System State Summary:${NC}"
echo "  Total Intents: $INTENT_TOTAL"
echo "  Active Intent: $ACTIVE_INTENT"
echo ""
