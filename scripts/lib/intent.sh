#!/bin/bash

# Intent domain helpers: resolve intent file path, require intent file.
# Sources common.sh. Use this in scripts that work with intent IDs (e.g. workflow-orchestrator, kill-intent).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"

INTENT_DIR="${INTENT_DIR:-work/intent}"

# Resolve an intent ID (e.g. F-042) or path to the actual intent file path.
# Outputs the path; returns 0 if found, 1 if not. Use with require_intent_file to exit on failure.
resolve_intent_file() {
    local intent_id="$1"

    if [ -f "$intent_id" ]; then
        echo "$intent_id"
        return 0
    fi

    local candidates=(
        "work/intent/$intent_id.md"
        "work/intent/features/$intent_id.md"
        "work/intent/bugs/$intent_id.md"
        "work/intent/tech-debt/$intent_id.md"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    local matches=()
    shopt -s nullglob
    matches=( work/intent/*/"$intent_id".md )
    shopt -u nullglob

    if [ "${#matches[@]}" -eq 1 ]; then
        echo "${matches[0]}"
        return 0
    fi

    if [ "${#matches[@]}" -gt 1 ]; then
        error_exit "Multiple intent files found for $intent_id: ${matches[*]}" 1
    fi

    return 1
}

# Resolve intent and exit with error if not found. Sets INTENT_FILE in caller.
# Usage: INTENT_FILE="$(require_intent_file "$INTENT_ID")"
require_intent_file() {
    local intent_id="$1"
    local path
    path="$(resolve_intent_file "$intent_id")" || error_exit "Intent file not found for id '$intent_id' (looked under work/intent/ and work/intent/*/)" 1
    echo "$path"
}
