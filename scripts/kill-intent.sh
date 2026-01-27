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
