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

REASON="${2:-No reason provided}"
INTENT_FILE="intent/$INTENT_ID.md"
DATE_UTC="$(date -u +"%Y-%m-%d")"

if [ ! -f "$INTENT_FILE" ]; then
    error_exit "Intent file not found: $INTENT_FILE" 1
fi

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

if ! grep -qi "^## Kill Rationale" "$INTENT_FILE"; then
    {
        echo ""
        echo "## Kill Rationale"
        echo "- Kill criterion: (unspecified)"
        echo "- Reason: $REASON"
        echo "- Date: $DATE_UTC"
    } >> "$INTENT_FILE"
else
    if ! grep -qF "- Reason: $REASON" "$INTENT_FILE" || ! grep -qF "- Date: $DATE_UTC" "$INTENT_FILE"; then
        {
            echo ""
            echo "- Reason: $REASON"
            echo "- Date: $DATE_UTC"
        } >> "$INTENT_FILE"
    fi
fi

ACTIVE_FILE="workflow-state/active.md"
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
