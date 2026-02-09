#!/bin/bash
# When an intent is shipped, update or close the linked GitHub issue.
# Usage: on-ship-update-issue.sh <intent-id> [--close]
# Default: add a comment only. Use --close to close the issue.
# Set SHIP_CLOSE_ISSUE=1 to close (same as --close).
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
[ -n "$INTENT_ID" ] || error_exit "Usage: on-ship-update-issue.sh <intent-id> [--close]" 1
CLOSE_ISSUE=false
[ "${2:-}" = "--close" ] && CLOSE_ISSUE=true
[ "${SHIP_CLOSE_ISSUE:-0}" = "1" ] && CLOSE_ISSUE=true

cd "$ROOT_DIR" || error_exit "Failed to cd to repo root" 1
INTENT_FILE="$(require_intent_file "$INTENT_ID")"

# Extract GitHub issue number from intent (line under ## GitHub issue that looks like #N or N)
ISSUE_NUM=$(awk '/^## GitHub issue$/,/^## /{if (/^#?[0-9]+$/) { gsub(/^#/,""); print; exit }}' "$INTENT_FILE" 2>/dev/null || true)

[ -n "$ISSUE_NUM" ] || { echo -e "${YELLOW}No GitHub issue linked to intent $INTENT_ID; skipping.${NC}"; exit 0; }

COMMENT="Shipped via intent $INTENT_ID."
if [ "$CLOSE_ISSUE" = true ]; then
  echo -e "${BLUE}Closing issue #${ISSUE_NUM} with comment.${NC}"
  gh issue close "$ISSUE_NUM" --comment "$COMMENT" || error_exit "gh issue close failed" 1
  echo -e "${GREEN}Closed issue #${ISSUE_NUM}${NC}"
else
  echo -e "${BLUE}Adding comment to issue #${ISSUE_NUM}.${NC}"
  gh issue comment "$ISSUE_NUM" --body "$COMMENT" || error_exit "gh issue comment failed" 1
  echo -e "${GREEN}Commented on issue #${ISSUE_NUM}${NC}"
fi
