#!/bin/bash

# Workflow state path resolution for flat vs per-intent layout.
# Source this after common.sh. See _system/architecture/workflow-state-layout.md.
# Usage: source scripts/lib/workflow_state.sh
#   get_workflow_state_dir [intent_id]  -> path (no trailing slash for dir)
#   list_active_intent_ids             -> space-separated list
#   ensure_workflow_state_dir intent_id -> path (for writing)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WS_BASE="$REPO_ROOT/work/workflow-state"
ACTIVE_FILE="$WS_BASE/active.md"

# List intent IDs that have per-intent state directories (F-*, B-*, T-*).
list_per_intent_dirs() {
    local ids=()
    if [ ! -d "$WS_BASE" ]; then
        echo ""
        return 0
    fi
    local d
    for d in "$WS_BASE"/F-* "$WS_BASE"/B-* "$WS_BASE"/T-*; do
        [ -d "$d" ] || continue
        ids+=("$(basename "$d")")
    done 2>/dev/null || true
    [ ${#ids[@]} -eq 0 ] && echo "" || echo "${ids[*]}"
}

# Parse active.md for active intent id(s).
# Legacy: **Intent ID:** F-001 (single). Multi: ## Active intents block with "F-001 | Phase | status" lines.
# Output: space-separated list of intent ids considered active (from active.md and/or per-intent dirs).
list_active_intent_ids() {
    local from_file=()
    local from_dirs=()
    if [ -f "$ACTIVE_FILE" ]; then
        local line
        while IFS= read -r line; do
            if [[ "$line" =~ \*\*Intent\ ID:\*\*\ ([^[:space:]]+) ]]; then
                local id="${BASH_REMATCH[1]}"
                [[ "$id" != "none" ]] && from_file+=("$id")
            fi
            if [[ "$line" =~ ^(F-[0-9]+|B-[0-9]+|T-[0-9]+)[[:space:]]*\| ]]; then
                from_file+=("${BASH_REMATCH[1]}")
            fi
        done < "$ACTIVE_FILE"
    fi
    local dirs
    dirs="$(list_per_intent_dirs)"
    if [ -n "$dirs" ]; then
        from_dirs=($dirs)
    fi
    # Merge: unique list, file first then dirs
    local seen=()
    local out=()
    for id in "${from_file[@]}" "${from_dirs[@]}"; do
        [ -z "$id" ] && continue
        found=0
        if [ ${#seen[@]} -gt 0 ]; then
            for s in "${seen[@]}"; do [ "$s" = "$id" ] && found=1 && break; done
        fi
        [ "$found" -eq 0 ] && seen+=("$id") && out+=("$id")
    done
    [ ${#out[@]} -eq 0 ] && echo "" || echo "${out[*]}"
}

# Is flat layout in use? (flat phase files exist and no per-intent dirs, or flat is only state)
flat_in_use() {
    if [ -f "$WS_BASE/01_analysis.md" ] || [ -f "$WS_BASE/02_plan.md" ]; then
        local dirs
        dirs="$(list_per_intent_dirs)"
        [ -z "$dirs" ] && return 0
    fi
    return 1
}

# Resolve workflow state directory for reading or writing.
# Usage: get_workflow_state_dir [intent_id]
# - With intent_id: returns work/workflow-state/<intent_id> (per-intent).
# - Without intent_id: returns flat work/workflow-state if flat layout in use; otherwise empty (caller must pass intent_id when multiple actives).
get_workflow_state_dir() {
    local intent_id="${1:-}"
    if [ -n "$intent_id" ]; then
        if [ -d "$WS_BASE/$intent_id" ]; then
            echo "$WS_BASE/$intent_id"
            return 0
        fi
        # Flat in use and active.md single intent matches: return flat so existing single-intent repos keep working.
        if flat_in_use; then
            local actives
            actives=($(list_active_intent_ids))
            if [ "${#actives[@]}" -eq 1 ] && [ "${actives[0]}" = "$intent_id" ]; then
                echo "$WS_BASE"
                return 0
            fi
        fi
        echo "$WS_BASE/$intent_id"
        return 0
    fi
    # No intent_id: return flat if flat in use (single-intent backward compat).
    if flat_in_use; then
        echo "$WS_BASE"
        return 0
    fi
    # Multiple per-intent dirs or no flat: no single "current" dir.
    echo ""
    return 0
}

# For writing: ensure we have a directory path for this intent. When to use flat vs per-intent:
# - If flat is in use and this is the only active intent, use flat.
# - Otherwise use work/workflow-state/<intent_id>/.
# Usage: ensure_workflow_state_dir <intent_id>
# Output: path to dir (no trailing slash). Creates dir if per-intent.
ensure_workflow_state_dir() {
    local intent_id="$1"
    [ -n "$intent_id" ] || { echo ""; return 1; }
    if [ -d "$WS_BASE/$intent_id" ]; then
        echo "$WS_BASE/$intent_id"
        return 0
    fi
    if flat_in_use; then
        local actives
        actives=($(list_active_intent_ids))
        if [ "${#actives[@]}" -le 1 ] && { [ "${#actives[@]}" -eq 0 ] || [ "${actives[0]}" = "$intent_id" ]; }; then
            echo "$WS_BASE"
            return 0
        fi
    fi
    mkdir -p "$WS_BASE/$intent_id"
    echo "$WS_BASE/$intent_id"
    return 0
}

# Append an intent to active.md's active list (for multi-intent). Call when starting workflow for intent_id.
# If active.md has legacy single **Intent ID:** and it's "none" or same intent, update in place.
# If we're adding a second intent, ensure "## Active intents" exists and append "intent_id | Phase | active".
append_or_set_active_intent() {
    local intent_id="$1"
    local phase_name="${2:-Analysis}"
    [ -n "$intent_id" ] || return 1
    mkdir -p "$(dirname "$ACTIVE_FILE")"
    if [ ! -f "$ACTIVE_FILE" ]; then
        cat > "$ACTIVE_FILE" << EOF
# Active Intent

**Intent ID:** $intent_id
**Status:** active
**Current Phase:** $phase_name
**Started:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Progress

- [ ] Phase 1: Analysis
- [ ] Phase 2: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 4: Verification
- [ ] Phase 5: Release Notes

## Active intents

$intent_id | $phase_name | active
EOF
        return 0
    fi
    local actives
    actives=($(list_active_intent_ids))
    if [ "${#actives[@]}" -eq 0 ]; then
        # Replace legacy "none" or empty with this intent
        sed -e "s/**Intent ID:\*\* .*/**Intent ID:** $intent_id/" \
            -e "s/**Status:\*\* .*/**Status:** active/" \
            -e "s/**Current Phase:\*\* .*/**Current Phase:** $phase_name/" \
            -e "s/**Started:\*\* .*/**Started:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")/" \
            "$ACTIVE_FILE" > "${ACTIVE_FILE}.tmp" && mv "${ACTIVE_FILE}.tmp" "$ACTIVE_FILE"
        if ! grep -q "## Active intents" "$ACTIVE_FILE"; then
            printf '\n## Active intents\n\n%s | %s | active\n' "$intent_id" "$phase_name" >> "$ACTIVE_FILE"
        else
            grep -q "$intent_id" "$ACTIVE_FILE" || printf '%s | %s | active\n' "$intent_id" "$phase_name" >> "$ACTIVE_FILE"
        fi
        return 0
    fi
    if [[ " ${actives[*]} " == *" $intent_id "* ]]; then
        # Already listed; update phase if we have ## Active intents
        if grep -q "## Active intents" "$ACTIVE_FILE"; then
            local tmp
            tmp="$(mktemp)"
            awk -v id="$intent_id" -v ph="$phase_name" '
                $0 ~ "^" id "[[:space:]]*\\|" { print id " | " ph " | active"; next }
                { print }
            ' "$ACTIVE_FILE" > "$tmp" && mv "$tmp" "$ACTIVE_FILE"
        fi
        return 0
    fi
    # Add new intent to list
    if ! grep -q "## Active intents" "$ACTIVE_FILE"; then
        printf '\n## Active intents\n\n%s | %s | active\n' "$intent_id" "$phase_name" >> "$ACTIVE_FILE"
    else
        printf '%s | %s | active\n' "$intent_id" "$phase_name" >> "$ACTIVE_FILE"
    fi
    return 0
}
