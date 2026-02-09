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

INTENT_DIR="work/intent"
WORKFLOW_DIR="work/workflow-state"

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
    intent_files=()
    while IFS= read -r file; do
        intent_files+=("$file")
    done < <(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

    for file in "${intent_files[@]}"; do
        [ -f "$file" ] || continue

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

# Workflow state sanity check
required_state_files=(
    "active.md"
    "blocked.md"
    "validating.md"
    "shipped.md"
    "disagreements.md"
    "01_analysis.md"
    "02_plan.md"
    "03_implementation.md"
    "04_verification.md"
    "05_release_notes.md"
)

if [ -d "$WORKFLOW_DIR" ]; then
    missing_state_files=()
    for file in "${required_state_files[@]}"; do
        if [ ! -f "$WORKFLOW_DIR/$file" ]; then
            missing_state_files+=("$file")
        fi
    done

    if [ "${#missing_state_files[@]}" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Workflow State Check:${NC}"
        echo "  Missing files:"
        for file in "${missing_state_files[@]}"; do
            echo "  - $WORKFLOW_DIR/$file"
        done
        echo "  💡 Run /ship <id> or re-run /init-project to seed files"
        echo ""
    fi
fi

# Recent intents
if [ -d "$INTENT_DIR" ] && [ "${TOTAL:-0}" -gt 0 ]; then
    echo -e "${CYAN}Recent Intents:${NC}"
    if [ "${#intent_files[@]}" -gt 0 ]; then
        ls -t "${intent_files[@]}" 2>/dev/null | head -5 | while read -r file; do
        ID=$(basename "$file" .md)
        TITLE=$(grep "^# " "$file" 2>/dev/null | head -1 | sed 's/^# [^:]*: //' || echo "$ID")
        STATUS=$(awk '
            $0 ~ /^## Status/ {found=1; next}
            found && $0 ~ /^## / {exit}
            found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
        ' "$file" 2>/dev/null || echo "unknown")
        echo "  $ID: $TITLE ($STATUS)"
        done
    fi
    echo ""
fi

# Pending approvals
if [ -f "$WORKFLOW_DIR/02_plan.md" ]; then
    if grep -q "\[ \].*approval\|\[ \].*Approval" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null && ! grep -q "\[x\].*approval\|\[x\].*Approval\|Approved\|APPROVE" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Pending Approval:${NC}"
        echo "  Plan approval required in work/workflow-state/02_plan.md"
        echo ""
    fi
fi

# Test results summary
if command -v pnpm >/dev/null 2>&1 && [ -f "package.json" ]; then
    echo -e "${CYAN}Test Status:${NC}"
    if [ -f "package.json" ] && grep -q '"test"' package.json; then
        # Try to get test results (non-blocking, timeout to avoid hanging)
        test_output=$(timeout 10 pnpm test 2>&1 | tail -5 || echo "")
        if [ -n "$test_output" ] && echo "$test_output" | grep -q "PASS\|pass\|✓\|Test Files.*passed"; then
            test_count=$(echo "$test_output" | grep -oE "[0-9]+ passing\|[0-9]+ passed\|Test Files.*[0-9]+" | head -1 || echo "")
            echo -e "  ${GREEN}✓${NC} Tests passing${test_count:+ ($test_count)}"
        elif [ -n "$test_output" ] && echo "$test_output" | grep -q "FAIL\|fail\|✗\|failed"; then
            echo -e "  ${RED}✗${NC} Tests failing (run 'pnpm test' for details)"
        else
            echo "  ${YELLOW}○${NC} Run 'pnpm test' to check test status"
        fi
    else
        echo "  ${YELLOW}○${NC} No test script configured"
    fi
    echo ""
fi

# Token/usage summary (if usage.json exists)
USAGE_FILE="_system/artifacts/usage.json"
if [ -f "$USAGE_FILE" ] && command -v jq >/dev/null 2>&1; then
    ENTRY_COUNT=$(jq '.entries | length' "$USAGE_FILE" 2>/dev/null || echo "0")
    if [ "${ENTRY_COUNT:-0}" -gt 0 ]; then
        echo -e "${CYAN}Usage (tokens/cost):${NC}"
        LAST=$(jq -r '.entries[-1] | "\(.intent_id) \(.phase): \(.tokens_in + .tokens_out) tokens" + (if .estimated_cost_usd != null then " (~$" + (.estimated_cost_usd|tostring) + ")" else " (estimate)" end)' "$USAGE_FILE" 2>/dev/null || true)
        if [ -n "$LAST" ]; then
            echo "  Last: $LAST"
        fi
        echo "  Run \`pnpm usage-report\` for full table"
        echo ""
    fi
fi

# Recent changes (git)
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${CYAN}Recent Changes:${NC}"
    recent_commits=$(git log --oneline -5 2>/dev/null | head -5 || true)
    if [ -n "$recent_commits" ]; then
        echo "$recent_commits" | while IFS= read -r line; do
            [ -n "$line" ] && echo "  $line"
        done
    else
        echo "  (No commits yet)"
    fi
    echo ""
fi

# Suggestions
echo -e "${CYAN}Next Steps:${NC}"
if [ "$TOTAL" -eq 0 ]; then
    echo "  💡 Run /scope-project to break down your project"
    echo "  💡 Run /new_intent to create your first intent"
elif [ "$ACTIVE" -eq 0 ] && [ "$PLANNED" -gt 0 ]; then
    echo "  💡 Run /ship <id> to start working on a planned intent"
    echo "  💡 Run /new_intent to create another intent"
elif [ "$ACTIVE" -gt 0 ]; then
    echo "  💡 Continue workflow for active intent"
    echo "  💡 Run /status to see current phase"
else
    echo "  💡 Run /generate-release-plan to update release plan"
    echo "  💡 Run /generate-roadmap to update roadmap"
fi
echo ""
