#!/bin/bash

# Suggest next actions based on current project state
# Supports flat and per-intent workflow state; considers all active intents.

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

echo -e "${BLUE}ShipIt Suggestions${NC}"
echo ""

# Check if project exists
if [ ! -f "project.json" ]; then
    echo -e "${YELLOW}→ Initialize a project:${NC} /init-project \"My Project\""
    exit 0
fi

# Count intents by status (initialize to 0)
PLANNED=0
ACTIVE=0
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
            shipped) SHIPPED=$((SHIPPED + 1)) ;;
            killed) KILLED=$((KILLED + 1)) ;;
        esac
    done
fi

TOTAL=$((PLANNED + ACTIVE + SHIPPED + KILLED))

# Active intent(s) — use first for phase-based suggestions; show all if multiple
ACTIVE_IDS=($(list_active_intent_ids))
ACTIVE_ID=""
ACTIVE_PHASE=""
WORKFLOW_DIR=""
if [ "${#ACTIVE_IDS[@]}" -gt 0 ]; then
    ACTIVE_ID="${ACTIVE_IDS[0]}"
    WORKFLOW_DIR="$(get_workflow_state_dir "$ACTIVE_ID")"
    [ -z "$WORKFLOW_DIR" ] && WORKFLOW_DIR="$WS_BASE"
    if [ -n "$WORKFLOW_DIR" ]; then
        if [ -f "$WORKFLOW_DIR/02_plan.md" ]; then ACTIVE_PHASE="Plan"; fi
        if [ -f "$WORKFLOW_DIR/03_implementation.md" ]; then ACTIVE_PHASE="Implementation"; fi
        if [ -f "$WORKFLOW_DIR/04_verification.md" ]; then ACTIVE_PHASE="Verification"; fi
        if [ -f "$WORKFLOW_DIR/01_analysis.md" ] && [ -z "$ACTIVE_PHASE" ]; then ACTIVE_PHASE="Analysis"; fi
    fi
fi

# Generate suggestions
SUGGESTIONS=()

# No intents at all
if [ "$TOTAL" -eq 0 ]; then
    SUGGESTIONS+=("${CYAN}1. Scope your project:${NC} /scope-project \"project description\"")
    SUGGESTIONS+=("${CYAN}2. Create your first intent:${NC} /new_intent")
fi

# Has planned intents but no active
if [ "$PLANNED" -gt 0 ] && [ -z "$ACTIVE_ID" ]; then
    # Find first planned intent (actually check status)
    FIRST_PLANNED=""
    for file in "${intent_files[@]}"; do
        [ -f "$file" ] || continue
        STATUS=$(awk '
            $0 ~ /^## Status/ {found=1; next}
            found && $0 ~ /^## / {exit}
            found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
        ' "$file" 2>/dev/null || echo "")
        if [ "$STATUS" = "planned" ]; then
            FIRST_PLANNED=$(basename "$file" .md)
            break
        fi
    done
    if [ -n "$FIRST_PLANNED" ]; then
        SUGGESTIONS+=("${CYAN}1. Start working on an intent:${NC} /ship $FIRST_PLANNED")
    fi
fi

# Has active intent(s)
if [ -n "$ACTIVE_ID" ]; then
    if [ "${#ACTIVE_IDS[@]}" -gt 1 ]; then
        SUGGESTIONS+=("${CYAN}Multiple active intents:${NC} ${ACTIVE_IDS[*]} — use /ship <id> or /verify <id>")
    fi
    case "$ACTIVE_PHASE" in
        *analysis*|*Analysis*)
            SUGGESTIONS+=("${CYAN}1. Continue analysis:${NC} Fill in $WORKFLOW_DIR/01_analysis.md")
            SUGGESTIONS+=("${CYAN}2. Move to planning:${NC} Run /ship $ACTIVE_ID (will proceed to Phase 2)")
            ;;
        *plan*|*Plan*)
            if [ -n "$WORKFLOW_DIR" ] && [ -f "$WORKFLOW_DIR/02_plan.md" ] && grep -q "\[ \].*approval\|\[ \].*Approval" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null && ! grep -q "\[x\].*approval\|\[x\].*Approval\|Approved\|APPROVE" "$WORKFLOW_DIR/02_plan.md" 2>/dev/null; then
                SUGGESTIONS+=("${YELLOW}1. ⚠ Approval required:${NC} Review and approve $WORKFLOW_DIR/02_plan.md")
            else
                SUGGESTIONS+=("${CYAN}1. Continue to implementation:${NC} Run /ship $ACTIVE_ID")
            fi
            ;;
        *implementation*|*Implementation*)
            SUGGESTIONS+=("${CYAN}1. Continue implementation:${NC} Fill in $WORKFLOW_DIR/03_implementation.md")
            SUGGESTIONS+=("${CYAN}2. Move to verification:${NC} Run /verify $ACTIVE_ID")
            ;;
        *verification*|*Verification*)
            SUGGESTIONS+=("${CYAN}1. Complete verification:${NC} Fill in $WORKFLOW_DIR/04_verification.md")
            SUGGESTIONS+=("${CYAN}2. Move to release:${NC} Run /ship $ACTIVE_ID")
            ;;
        *)
            SUGGESTIONS+=("${CYAN}1. Continue workflow:${NC} Run /ship $ACTIVE_ID")
            ;;
    esac
fi

# Release plan needs update
if [ "$PLANNED" -gt 0 ] || [ "$ACTIVE" -gt 0 ]; then
    if [ ! -f "work/release/plan.md" ] || [ -n "$(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" -newer "work/release/plan.md" -print -quit 2>/dev/null)" ]; then
        SUGGESTIONS+=("${CYAN}Update release plan:${NC} /generate-release-plan")
    fi
fi

# Roadmap needs update
if [ "$PLANNED" -gt 0 ] || [ "$ACTIVE" -gt 0 ]; then
    if [ ! -f "work/roadmap/now.md" ] || [ -n "$(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" -newer "work/roadmap/now.md" -print -quit 2>/dev/null)" ]; then
        SUGGESTIONS+=("${CYAN}Update roadmap:${NC} /generate-roadmap")
    fi
fi

# Show suggestions
if [ ${#SUGGESTIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ Everything looks good!${NC}"
    echo ""
    echo "You might want to:"
    echo "  → Create a new intent: /new_intent"
    echo "  → Check project status: /status"
    echo "  → Review release plan: /generate-release-plan"
else
    for suggestion in "${SUGGESTIONS[@]}"; do
        echo -e "$suggestion"
    done
fi

echo ""
echo -e "${CYAN}More help:${NC} /help [command]"
echo -e "${CYAN}Project status:${NC} /status"
