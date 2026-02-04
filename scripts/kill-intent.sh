#!/bin/bash

# Kill Intent Script
# Marks an intent as killed and records rationale

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: ./scripts/kill-intent.sh <intent-id> [reason]" 1
fi

# Resolve intent file: same locations as workflow-orchestrator (intent/, intent/features/, etc.)
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
    local c
    for c in "${candidates[@]}"; do
        if [ -f "$c" ]; then
            echo "$c"
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

REASON="${2:-No reason provided}"
INTENT_FILE="$(resolve_intent_file "$INTENT_ID")" || error_exit "Intent file not found for id '$INTENT_ID' (looked under work/intent/ and work/intent/*/)" 1
DATE_UTC="$(date -u +"%Y-%m-%d")"

TEMP_FILE="$(mktemp)"

awk -v status_value="killed" '
    BEGIN { in_status=0; replaced=0 }
    /^## Status/ {
        print;
        in_status=1;
        next;
    }
    in_status && /^## / {
        if (!replaced) {
            print status_value;
            replaced=1;
        }
        in_status=0;
        print;
        next;
    }
    in_status {
        if ($0 ~ /[^[:space:]]/ && !replaced) {
            print status_value;
            replaced=1;
        }
        next;
    }
    { print }
    END {
        if (in_status && !replaced) {
            print status_value;
        }
    }
' "$INTENT_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$INTENT_FILE"

# Handle Kill Rationale section - replace entire section if it exists, create if it doesn't
TEMP_FILE2="$(mktemp)"
awk -v reason="$REASON" -v date="$DATE_UTC" '
    BEGIN { in_section=0; section_written=0 }
    /^## Kill Rationale/ {
        in_section=1;
        section_written=1;
        print "";
        print "## Kill Rationale";
        print "- Kill criterion: (unspecified)";
        print "- Reason: " reason;
        print "- Date: " date;
        next;
    }
    in_section && /^## / {
        # Hit next section, stop skipping
        in_section=0;
        print;
        next;
    }
    in_section {
        # Skip all lines in the Kill Rationale section (we already wrote the replacement)
        next;
    }
    { print }
    END {
        if (!section_written) {
            print "";
            print "## Kill Rationale";
            print "- Kill criterion: (unspecified)";
            print "- Reason: " reason;
            print "- Date: " date;
        }
    }
' "$INTENT_FILE" > "$TEMP_FILE2"

mv "$TEMP_FILE2" "$INTENT_FILE"

ACTIVE_FILE="work/workflow-state/active.md"
if [ -f "$ACTIVE_FILE" ]; then
    ACTIVE_TEMP="$(mktemp)"
    awk -v intent="$INTENT_ID" '
        /^\*\*Intent ID:\*\*/ { print "**Intent ID:** " intent; next }
        /^\*\*Status:\*\*/ { print "**Status:** killed"; next }
        /^\*\*Current Phase:\*\*/ { print "**Current Phase:** killed"; next }
        { print }
    ' "$ACTIVE_FILE" > "$ACTIVE_TEMP" && mv "$ACTIVE_TEMP" "$ACTIVE_FILE"
fi

echo "✓ Marked $INTENT_ID as killed"
