#!/bin/bash

# Show current ShipIt project status
# Displays active intent(s), workflow phase(s), intent counts. Supports flat and per-intent layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/workflow_state.sh
[ -f "$SCRIPT_DIR/lib/workflow_state.sh" ] && source "$SCRIPT_DIR/lib/workflow_state.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

INTENT_DIR="work/intent"
WS_BASE="work/workflow-state"

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

# Active intent(s) — from flat active.md or per-intent dirs
ACTIVE_IDS=($(list_active_intent_ids))
if [ "${#ACTIVE_IDS[@]}" -gt 0 ]; then
    echo -e "${CYAN}Active Intent(s):${NC}"
    for aid in "${ACTIVE_IDS[@]}"; do
        dir="$(get_workflow_state_dir "$aid")"
        phase=""
        if [ -n "$dir" ] && [ -f "$dir/02_plan.md" ]; then
            phase="Planning"
        elif [ -n "$dir" ] && [ -f "$dir/03_implementation.md" ]; then
            phase="Implementation"
        elif [ -n "$dir" ] && [ -f "$dir/04_verification.md" ]; then
            phase="Verification"
        elif [ -n "$dir" ] && [ -f "$dir/01_analysis.md" ]; then
            phase="Analysis"
        else
            phase="(see workflow state)"
        fi
        echo "  $aid — $phase"
    done
    echo ""
fi
if [ -f "$WS_BASE/active.md" ]; then
    ACTIVE_STATUS=$(grep -E "^\\*\\*Status:\\*\\*" "$WS_BASE/active.md" 2>/dev/null | sed 's/.*\*\*Status:\*\* //' | tr -d ' ' || echo "")
    if [ "$ACTIVE_STATUS" = "idle" ] && [ "${#ACTIVE_IDS[@]}" -eq 0 ]; then
        echo -e "${CYAN}Active Intent:${NC} none (idle)"
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

# Workflow state files (flat or per-intent)
if [ -d "$WS_BASE" ]; then
    echo -e "${CYAN}Workflow State:${NC}"
    if [ "${#ACTIVE_IDS[@]}" -eq 0 ]; then
        WORKFLOW_DIR="$WS_BASE"
        for phase in 01_analysis 02_plan 03_implementation 04_verification 05_release_notes 06_shipped; do
            if [ -f "$WORKFLOW_DIR/${phase}.md" ]; then
                echo -e "  ${GREEN}✓${NC} $phase"
            else
                echo -e "  ${YELLOW}○${NC} $phase (not started)"
            fi
        done
    else
        for aid in "${ACTIVE_IDS[@]}"; do
            dir="$(get_workflow_state_dir "$aid")"
            [ -z "$dir" ] && continue
            echo "  [$aid]"
            for phase in 01_analysis 02_plan 03_implementation 04_verification 05_release_notes 06_shipped; do
                if [ -f "$dir/${phase}.md" ]; then
                    echo -e "    ${GREEN}✓${NC} $phase"
                else
                    echo -e "    ${YELLOW}○${NC} $phase (not started)"
                fi
            done
        done
    fi
    echo ""
fi

# Workflow state sanity check (top-level required files)
required_top_files=( "active.md" "blocked.md" "validating.md" "shipped.md" "disagreements.md" )
required_phase_files=( "01_analysis.md" "02_plan.md" "03_implementation.md" "04_verification.md" "05_release_notes.md" )
if [ -d "$WS_BASE" ]; then
    missing_top=()
    for file in "${required_top_files[@]}"; do
        [ ! -f "$WS_BASE/$file" ] && missing_top+=("$file")
    done
    for aid in "${ACTIVE_IDS[@]}"; do
        dir="$(get_workflow_state_dir "$aid")"
        [ -z "$dir" ] && continue
        for file in "${required_phase_files[@]}"; do
            [ ! -f "$dir/$file" ] && missing_top+=("$aid/$file")
        done
    done
    if [ "${#ACTIVE_IDS[@]}" -eq 0 ]; then
        for file in "${required_phase_files[@]}"; do
            [ ! -f "$WS_BASE/$file" ] && missing_top+=("$file")
        done
    fi
    if [ "${#missing_top[@]}" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Workflow State Check:${NC}"
        echo "  Missing: ${missing_top[*]}"
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

# Pending approvals (check flat or each active's plan)
check_pending_approval() {
    local f="$1"
    [ ! -f "$f" ] && return 0
    if grep -q "\[ \].*approval\|\[ \].*Approval" "$f" 2>/dev/null && ! grep -q "\[x\].*approval\|\[x\].*Approval\|Approved\|APPROVE" "$f" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Pending Approval:${NC}"
        echo "  Plan approval required in $f"
        echo ""
        return 1
    fi
    return 0
}
if [ "${#ACTIVE_IDS[@]}" -eq 0 ] && [ -f "$WS_BASE/02_plan.md" ]; then
    check_pending_approval "$WS_BASE/02_plan.md" || true
else
    for aid in "${ACTIVE_IDS[@]}"; do
        dir="$(get_workflow_state_dir "$aid")"
        [ -n "$dir" ] && [ -f "$dir/02_plan.md" ] && check_pending_approval "$dir/02_plan.md" || true
    done
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
