#!/bin/bash
# Create a GitHub PR from work/workflow-state/pr.md for the given intent.
# Resolves pr.md per workflow-state-layout: work/workflow-state/<intent-id>/pr.md or work/workflow-state/pr.md.
# Usage: create-pr.sh <intent-id>
# Requires: gh. Run /pr first if pr.md is missing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/intent.sh
[ -f "$SCRIPT_DIR/../lib/intent.sh" ] && source "$SCRIPT_DIR/../lib/intent.sh"
# shellcheck source=../lib/common.sh
[ -f "$SCRIPT_DIR/../lib/common.sh" ] && source "$SCRIPT_DIR/../lib/common.sh"

require_cmd gh

INTENT_ID="${1:-}"
[ -n "$INTENT_ID" ] || error_exit "Usage: create-pr.sh <intent-id>" 1

cd "$ROOT_DIR" || error_exit "Failed to cd to repo root" 1
require_intent_file "$INTENT_ID" >/dev/null

# Resolve pr.md per workflow-state-layout.md
PR_PER_INTENT="work/workflow-state/${INTENT_ID}/pr.md"
PR_FLAT="work/workflow-state/pr.md"
if [ -f "$PR_PER_INTENT" ]; then
  PR_FILE="$PR_PER_INTENT"
elif [ -f "$PR_FLAT" ]; then
  PR_FILE="$PR_FLAT"
else
  error_exit "pr.md not found. Run /pr $INTENT_ID first to generate work/workflow-state/pr.md (or work/workflow-state/$INTENT_ID/pr.md)." 1
fi

# PR title from first line of pr.md (e.g. "# PR: F-001 - Title")
TITLE=$(head -1 "$PR_FILE" | sed 's/^# *PR: *//;s/^# *//')
[ -n "$TITLE" ] || TITLE="Intent $INTENT_ID"

echo -e "${BLUE}Creating PR: $TITLE${NC}"
gh pr create --title "$TITLE" --body-file "$PR_FILE" || error_exit "gh pr create failed" 1
echo -e "${GREEN}PR created from $PR_FILE${NC}"
