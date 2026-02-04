#!/bin/bash

# Generate Project Dashboard Script
# Creates a project status dashboard

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

DASHBOARD_FILE="DASHBOARD.md"

echo -e "${BLUE}Generating project dashboard...${NC}"

# Check prerequisites
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")

# Collect metrics
intent_files=()
while IFS= read -r file; do
    intent_files+=("$file")
done < <(find intent -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

INTENT_TOTAL=${#intent_files[@]}
if [ "$INTENT_TOTAL" -gt 0 ]; then
    INTENT_PLANNED=$(grep -l "Status.*planned" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
    INTENT_ACTIVE=$(grep -l "Status.*active" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
    INTENT_SHIPPED=$(grep -l "Status.*shipped" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
    INTENT_BLOCKED=$(grep -l "Status.*blocked" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
else
    INTENT_PLANNED=0
    INTENT_ACTIVE=0
    INTENT_SHIPPED=0
    INTENT_BLOCKED=0
fi

# Calculate progress
if [ "$INTENT_TOTAL" -gt 0 ]; then
    PROGRESS=$((INTENT_SHIPPED * 100 / INTENT_TOTAL))
else
    PROGRESS=0
fi

# Get active intent details
ACTIVE_INTENT=$(grep -h "Intent ID:" workflow-state/active.md 2>/dev/null | grep -o "F-[0-9]*\|B-[0-9]*\|T-[0-9]*" | head -1 || echo "none")
ACTIVE_PHASE=$(grep -h "Current Phase:" workflow-state/active.md 2>/dev/null | sed 's/.*Current Phase: *//' || echo "unknown")

# Test coverage (if available)
if command -v pnpm >/dev/null 2>&1 && [ -f "package.json" ]; then
    COVERAGE=$(pnpm test:coverage 2>/dev/null | grep -o "[0-9]*%" | head -1 || echo "N/A")
else
    COVERAGE="N/A"
fi

# Generate dashboard
cat > "$DASHBOARD_FILE" << EOF || error_exit "Failed to generate dashboard"
# Project Dashboard: $PROJECT_NAME

**Last Updated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## 📊 Status Overview

| Metric | Value |
|--------|-------|
| **Total Intents** | $INTENT_TOTAL |
| **Planned** | $INTENT_PLANNED |
| **Active** | $INTENT_ACTIVE |
| **Shipped** | $INTENT_SHIPPED |
| **Blocked** | $INTENT_BLOCKED |
| **Progress** | $PROGRESS% |

## 🎯 Current Work

- **Active Intent:** $ACTIVE_INTENT
- **Current Phase:** $ACTIVE_PHASE

## 📈 Progress Visualization

\`\`\`
Shipped:    [$(printf '#%.0s' $(seq 1 $((PROGRESS / 2))))$(printf ' %.0s' $(seq 1 $((50 - PROGRESS / 2))))] $PROGRESS%
\`\`\`

## 🔄 Intent Status Breakdown

- ✅ Shipped: $INTENT_SHIPPED
- 🔄 Active: $INTENT_ACTIVE
- 📋 Planned: $INTENT_PLANNED
- ⛔ Blocked: $INTENT_BLOCKED

## 🧪 Quality Metrics

- **Test Coverage:** $COVERAGE
- **Lint Status:** [Run: pnpm lint]
- **Type Check:** [Run: pnpm typecheck]

## 📋 Recent Intents

$(if [ "$INTENT_TOTAL" -gt 0 ]; then printf "%s\n" "${intent_files[@]}" | head -5 | xargs -I{} basename "{}" .md | sed 's/^/- /'; else echo "No intents yet"; fi)

## 🔗 Quick Links

- [Project Context](./PROJECT_CONTEXT.md)
- [Roadmap](./generated/roadmap/now.md)
- [Dependencies](./generated/artifacts/dependencies.md)
- [Deployment History](./deployment-history.md)

## 🚀 Next Actions

1. Review active intent: $ACTIVE_INTENT
2. Check workflow state: workflow-state/
3. Update roadmap: generated/roadmap/

---

*This dashboard is auto-generated. Run \`pnpm generate-dashboard\` to update.*
EOF

echo -e "${GREEN}✓ Generated $DASHBOARD_FILE${NC}"
echo ""
echo -e "${YELLOW}Dashboard Metrics:${NC}"
echo "  Total Intents: $INTENT_TOTAL"
echo "  Progress: $PROGRESS%"
echo "  Active: $ACTIVE_INTENT"
echo ""
