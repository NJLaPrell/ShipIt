#!/bin/bash
# Link an existing GitHub issue to an intent (write issue number into intent file).
# Usage: link-issue.sh <intent-id> <issue-number>
# Requires: gh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/intent.sh
[ -f "$SCRIPT_DIR/../lib/intent.sh" ] && source "$SCRIPT_DIR/../lib/intent.sh"
# shellcheck source=../lib/common.sh
[ -f "$SCRIPT_DIR/../lib/common.sh" ] && source "$SCRIPT_DIR/../lib/common.sh"

require_cmd gh

INTENT_ID="${1:-}"
ISSUE_NUM="${2:-}"
[ -n "$INTENT_ID" ] && [ -n "$ISSUE_NUM" ] || error_exit "Usage: link-issue.sh <intent-id> <issue-number>" 1
[[ "$ISSUE_NUM" =~ ^[0-9]+$ ]] || error_exit "Issue number must be numeric" 1

cd "$ROOT_DIR" || error_exit "Failed to cd to repo root" 1
INTENT_FILE="$(require_intent_file "$INTENT_ID")"

if grep -q '^## GitHub issue' "$INTENT_FILE"; then
  awk -v num="$ISSUE_NUM" '
    /^## GitHub issue$/ { in_sec=1; print; next }
    in_sec && /^#?[0-9]+$/ { print "#" num; in_sec=0; next }
    in_sec && /^## / { in_sec=0 }
    { print }
  ' "$INTENT_FILE" > "$INTENT_FILE.nw" && mv "$INTENT_FILE.nw" "$INTENT_FILE"
else
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

echo -e "${GREEN}Linked issue #${ISSUE_NUM} to $INTENT_FILE${NC}"
