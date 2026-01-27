#!/bin/bash

# Show current ShipIt project status
# Displays active intent, workflow phase, intent counts, and recent activity

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

INTENT_DIR="intent"
WORKFLOW_DIR="workflow-state"

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}ShipIt Project Status${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Check if project.json exists
if [ ! -f "project.json" ]; then
    echo -e "${RED}⚠ Not a ShipIt project (project.json missing)${NC}"
    echo "Run /init-project to initialize a project."
    exit 1
fi

PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "unknown")
echo -e "${CYAN}Project:${NC} $PROJECT_NAME"
echo ""

# Active intent
if [ -f "$WORKFLOW_DIR/active.md" ]; then
    ACTIVE_ID=$(grep -E "^\\*\\*Intent ID:\\*\\*" "$WORKFLOW_DIR/active.md" 2>/dev/null | sed 's/.*\*\*Intent ID:\*\* //' | tr -d ' ' || echo "")
    ACTIVE_STATUS=$(grep -E "^\\*\\*Status:\\*\\*" "$WORKFLOW_DIR/active.md" 2>/dev/null | sed 's/.*\*\*Status:\*\* //' | tr -d ' ' || echo "")
    ACTIVE_PHASE=$(grep -E "^\\*\\*Current Phase:\\*\\*" "$WORKFLOW_DIR/active.md" 2>/dev/null | sed 's/.*\*\*Current Phase:\*\* //' | tr -d ' ' || echo "")
    
    if [ -n "$ACTIVE_ID" ] && [ "$ACTIVE_STATUS" != "idle" ]; then
        echo -e "${CYAN}Active Intent:${NC}"
        echo "  ID: $ACTIVE_ID"
        echo "  Status: $ACTIVE_STATUS"
        if [ -n "$ACTIVE_PHASE" ]; then
            echo "  Phase: $ACTIVE_PHASE"
        fi
        echo ""
    fi
fi

# Intent counts (initialize to 0)
PLANNED=0
ACTIVE=0
BLOCKED=0
VALIDATING=0
SHIPPED=0
KILLED=0
TOTAL=0

if [ -d "$INTENT_DIR" ]; then
    
    for file in "$INTENT_DIR"/*.md; do
        [ -f "$file" ] || continue
        [ "$(basename "$file")" = "_TEMPLATE.md" ] && continue
        
        STATUS=$(awk '
            $0 ~ /^## Status/ {found=1; next}
            found && $0 ~ /^## / {exit}
            found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
        ' "$file" 2>/dev/null || echo "planned")
        
        case "$STATUS" in
            planned) PLANNED=$((PLANNED + 1)) ;;
            active) ACTIVE=$((ACTIVE + 1)) ;;
            blocked) BLOCKED=$((BLOCKED + 1)) ;;
            validating) VALIDATING=$((VALIDATING + 1)) ;;
            shipped) SHIPPED=$((SHIPPED + 1)) ;;
            killed) KILLED=$((KILLED + 1)) ;;
        esac
    done
    
    TOTAL=$((PLANNED + ACTIVE + BLOCKED + VALIDATING + SHIPPED + KILLED))
fi

if [ "$TOTAL" -gt 0 ]; then
    echo -e "${CYAN}Intent Status:${NC}"
    echo "  Planned: $PLANNED"
    echo "  Active: $ACTIVE"
    echo "  Blocked: $BLOCKED"
    echo "  Validating: $VALIDATING"
    echo "  Shipped: $SHIPPED"
    echo "  Killed: $KILLED"
    echo "  Total: $TOTAL"
    echo ""
fi

# Workflow state files
if [ -d "$WORKFLOW_DIR" ]; then
    echo -e "${CYAN}Workflow State:${NC}"
    for phase in 01_analysis 02_plan 03_implementation 04_verification 05_release_notes 06_shipped; do
        if [ -f "$WORKFLOW_DIR/${phase}.md" ]; then
            echo -e "  ${GREEN}✓${NC} $phase"
        else
            echo -e "  ${YELLOW}○${NC} $phase (not started)"
        fi
    done
    echo ""
fi

# Recent intents
if [ -d "$INTENT_DIR" ] && [ "${TOTAL:-0}" -gt 0 ]; then
    echo -e "${CYAN}Recent Intents:${NC}"
    ls -t "$INTENT_DIR"/*.md 2>/dev/null | grep -v "_TEMPLATE.md" | head -5 | while read -r file; do
        ID=$(basename "$file" .md)
        TITLE=$(grep "^# " "$file" 2>/dev/null | head -1 | sed 's/^# [^:]*: //' || echo "$ID")
        STATUS=$(awk '
            $0 ~ /^## Status/ {found=1; next}
            found && $0 ~ /^## / {exit}
            found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
        ' "$file" 2>/dev/null || echo "unknown")
        echo "  $ID: $TITLE ($STATUS)"
    done
    echo ""
fi

# Pending approvals
if [ -f "$WORKFLOW_DIR/02_plan.md" ]; then
    if grep -q "\[ \].*approval\|\[ \].*Approval" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null && ! grep -q "\[x\].*approval\|\[x\].*Approval\|Approved\|APPROVE" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Pending Approval:${NC}"
        echo "  Plan approval required in workflow-state/02_plan.md"
        echo ""
    fi
fi

# Suggestions
echo -e "${CYAN}Quick Actions:${NC}"
if [ "$TOTAL" -eq 0 ]; then
    echo "  → Run /scope-project to break down your project"
    echo "  → Run /new_intent to create your first intent"
elif [ "$ACTIVE" -eq 0 ] && [ "$PLANNED" -gt 0 ]; then
    echo "  → Run /ship <id> to start working on a planned intent"
    echo "  → Run /new_intent to create another intent"
elif [ "$ACTIVE" -gt 0 ]; then
    echo "  → Continue workflow for active intent"
    echo "  → Run /status to see current phase"
else
    echo "  → Run /generate-release-plan to update release plan"
    echo "  → Run /generate-roadmap to update roadmap"
fi
echo ""
