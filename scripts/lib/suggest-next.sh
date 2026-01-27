#!/bin/bash

# Next-Step Suggestion Library
# Provides context-aware suggestions for next commands based on project state

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

INTENT_DIR="${INTENT_DIR:-intent}"
WORKFLOW_DIR="${WORKFLOW_DIR:-workflow-state}"

# Analyze current project state
analyze_state() {
    local state=""
    
    # Count intents by status
    local planned=0
    local active=0
    local shipped=0
    
    if [ -d "$INTENT_DIR" ]; then
        for file in "$INTENT_DIR"/*.md; do
            [ -f "$file" ] || continue
            [ "$(basename "$file")" = "_TEMPLATE.md" ] && continue
            
            local status=$(awk '
                $0 ~ /^## Status/ {found=1; next}
                found && $0 ~ /^## / {exit}
                found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
            ' "$file" 2>/dev/null || echo "planned")
            
            case "$status" in
                planned) planned=$((planned + 1)) ;;
                active) active=$((active + 1)) ;;
                shipped) shipped=$((shipped + 1)) ;;
            esac
        done
    fi
    
    # Check for active workflow
    local has_active_workflow=false
    if [ -f "$WORKFLOW_DIR/active.md" ]; then
        local active_status=$(grep -E "^\\*\\*Status:\\*\\*" "$WORKFLOW_DIR/active.md" 2>/dev/null | sed 's/.*\*\*Status:\*\* //' | tr -d ' ' || echo "")
        if [ "$active_status" = "active" ]; then
            has_active_workflow=true
        fi
    fi
    
    # Check for release plan
    local has_release_plan=false
    if [ -f "release/plan.md" ]; then
        has_release_plan=true
    fi
    
    echo "$planned|$active|$shipped|$has_active_workflow|$has_release_plan"
}

# Generate suggestions based on state
suggest_commands() {
    local state="$1"
    local planned=$(echo "$state" | cut -d'|' -f1)
    local active=$(echo "$state" | cut -d'|' -f2)
    local shipped=$(echo "$state" | cut -d'|' -f3)
    local has_active_workflow=$(echo "$state" | cut -d'|' -f4)
    local has_release_plan=$(echo "$state" | cut -d'|' -f5)
    
    local suggestions=()
    
    # Logic for suggestions
    if [ "$planned" -eq 0 ] && [ "$active" -eq 0 ]; then
        # No intents yet
        suggestions+=("Run /scope-project to break down your project")
        suggestions+=("Run /new_intent to create your first intent")
    elif [ "$active" -gt 0 ]; then
        # Active workflow
        suggestions+=("Continue workflow for active intent")
        suggestions+=("Run /status to see current phase")
    elif [ "$planned" -gt 0 ] && [ "$has_release_plan" = "true" ]; then
        # Planned intents with release plan
        # Get first planned intent (more specific pattern to avoid false matches)
        local first_intent=$(find "$INTENT_DIR" -name "*.md" ! -name "_TEMPLATE.md" -exec awk '
            $0 ~ /^## Status/ {found=1; next}
            found && $0 ~ /^## / {exit}
            found && $0 ~ /^[[:space:]]*planned[[:space:]]*$/ {print FILENAME; exit}
        ' {} \; 2>/dev/null | head -1)
        if [ -n "$first_intent" ]; then
            local intent_id=$(basename "$first_intent" .md)
            suggestions+=("Run /ship $intent_id to start implementing")
        fi
        suggestions+=("Run /new_intent to create another intent")
        suggestions+=("Edit intents or review release plan")
    elif [ "$planned" -gt 0 ]; then
        # Planned intents but no release plan
        suggestions+=("Run /generate-release-plan to create release plan")
        suggestions+=("Run /ship <intent-id> to start implementing")
    elif [ "$has_release_plan" = "true" ]; then
        # Release plan exists
        suggestions+=("Run /ship <intent-id> to start implementing")
        suggestions+=("Run /generate-roadmap to update roadmap")
    else
        # Default suggestions
        suggestions+=("Run /scope-project to break down your project")
        suggestions+=("Run /new_intent to create an intent")
    fi
    
    # Print suggestions
    for suggestion in "${suggestions[@]}"; do
        echo "  💡 $suggestion"
    done
}

# Display suggestions after command completion
display_suggestions() {
    local context="${1:-}"
    local state=$(analyze_state)
    
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    suggest_commands "$state"
    echo ""
}
