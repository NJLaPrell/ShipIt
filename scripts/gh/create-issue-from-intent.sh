#!/bin/bash
# Create a GitHub issue from an intent and write the issue number back to the intent file.
# Usage: create-issue-from-intent.sh <intent-id>
# Requires: gh (repo from gh repo view)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/intent.sh
[ -f "$SCRIPT_DIR/../lib/intent.sh" ] && source "$SCRIPT_DIR/../lib/intent.sh"
# shellcheck source=../lib/common.sh
[ -f "$SCRIPT_DIR/../lib/common.sh" ] && source "$SCRIPT_DIR/../lib/common.sh"

require_cmd gh

INTENT_ID="${1:-}"
[ -n "$INTENT_ID" ] || error_exit "Usage: create-issue-from-intent.sh <intent-id>" 1

cd "$ROOT_DIR" || error_exit "Failed to cd to repo root" 1
INTENT_FILE="$(require_intent_file "$INTENT_ID")"

# Title: first line of intent (e.g. "F-001: Add feature")
TITLE=$(head -1 "$INTENT_FILE" | sed 's/^# *//')
BODY_FILE=$(mktemp)
trap 'rm -f "$BODY_FILE"' EXIT
cat "$INTENT_FILE" > "$BODY_FILE"

echo -e "${BLUE}Creating GitHub issue: $TITLE${NC}"
OUTPUT=$(gh issue create --title "$TITLE" --body-file "$BODY_FILE" 2>&1) || error_exit "gh issue create failed: $OUTPUT" 1
ISSUE_NUM=$(echo "$OUTPUT" | sed -n 's|.*/issues/\([0-9]*\)|\1|p')
[ -n "$ISSUE_NUM" ] || ISSUE_NUM=$(echo "$OUTPUT" | grep -oE '[0-9]+' | head -1)
[ -n "$ISSUE_NUM" ] || error_exit "Could not parse issue number from: $OUTPUT" 1

# Write #ISSUE_NUM into intent file (add or update ## GitHub issue section)
if grep -q '^## GitHub issue' "$INTENT_FILE"; then
  # Replace value in existing section, or insert #num if section has only placeholder text
  awk -v num="$ISSUE_NUM" '
    /^## GitHub issue$/ { in_sec=1; printed=0; print; next }
    in_sec && /^#?[0-9]+$/ { if (!printed) { print "#" num; printed=1 }; next }
    in_sec && /^## / { in_sec=0; printed=0 }
    in_sec && NF>0 && !printed { print "#" num; printed=1 }
    { print }
  ' "$INTENT_FILE" > "$INTENT_FILE.nw" && mv "$INTENT_FILE.nw" "$INTENT_FILE"
else
  # Insert section before ## Do Not Repeat Check
  awk -v num="$ISSUE_NUM" '
    /^## Do Not Repeat Check/ {
      print "## GitHub issue"
      print ""
      print "#" num
      print ""
    }
    { print }
  ' "$INTENT_FILE" > "$INTENT_FILE.nw" && mv "$INTENT_FILE.nw" "$INTENT_FILE"
fi

echo -e "${GREEN}Created issue #${ISSUE_NUM} and updated $INTENT_FILE${NC}"
echo "$OUTPUT"
