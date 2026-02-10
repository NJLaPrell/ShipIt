#!/bin/bash

# Kill Intent Script
# Marks an intent as killed and records rationale

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/intent.sh
[ -f "$SCRIPT_DIR/lib/intent.sh" ] && source "$SCRIPT_DIR/lib/intent.sh"

INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: ./scripts/kill-intent.sh <intent-id> [reason]" 1
fi

REASON="${2:-No reason provided}"
INTENT_FILE="$(require_intent_file "$INTENT_ID")"
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

# Remove intent from active list (flat active.md); support multi-intent layout
ACTIVE_FILE="work/workflow-state/active.md"
if [ -f "$ACTIVE_FILE" ]; then
    ACTIVE_TEMP="$(mktemp)"
    # 1) Drop lines in "## Active intents" that start with this intent_id
    # 2) If **Intent ID:** is this intent, set to none and set Status/Phase to idle/none
    awk -v id="$INTENT_ID" '
        /^## Active intents/ { in_section=1; print; next }
        in_section && /^[FBT]-[0-9]+[[:space:]]*\|/ {
            if ($0 !~ "^" id "[[:space:]]*\\|") print
            next
        }
        in_section { in_section=0 }
        /^\*\*Intent ID:\*\* / {
            if ($0 == "**Intent ID:** " id) { killed_single=1; print "**Intent ID:** none"; next }
            print; next
        }
        killed_single && /^\*\*Status:\*\* / { print "**Status:** idle"; killed_single=0; next }
        killed_single && /^\*\*Current Phase:\*\* / { print "**Current Phase:** none"; killed_single=0; next }
        { print }
    ' "$ACTIVE_FILE" > "$ACTIVE_TEMP"
    # Legacy: if file had **Intent ID:** intent (no newline exact match), sed fallback
    if grep -q "^\*\*Intent ID:\*\* $INTENT_ID" "$ACTIVE_FILE"; then
        sed -e "s/^\*\*Intent ID:\*\* $INTENT_ID/**Intent ID:** none/" \
            -e "s/^\*\*Status:\*\* .*/**Status:** idle/" \
            -e "s/^\*\*Current Phase:\*\* .*/**Current Phase:** none/" \
            "$ACTIVE_TEMP" > "${ACTIVE_TEMP}.2" && mv "${ACTIVE_TEMP}.2" "$ACTIVE_TEMP"
    fi
    mv "$ACTIVE_TEMP" "$ACTIVE_FILE"
fi

echo "✓ Marked $INTENT_ID as killed"
