#!/bin/bash
# Create a new intent from a GitHub issue (fetch title/body, create intent file, set GitHub issue field).
# Usage: create-intent-from-issue.sh <issue-number>
# Requires: gh. Creates work/intent/features/F-XXX.md by default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/common.sh
[ -f "$SCRIPT_DIR/../lib/common.sh" ] && source "$SCRIPT_DIR/../lib/common.sh"

require_cmd gh jq

ISSUE_NUM="${1:-}"
[ -n "$ISSUE_NUM" ] || error_exit "Usage: create-intent-from-issue.sh <issue-number>" 1
[[ "$ISSUE_NUM" =~ ^[0-9]+$ ]] || error_exit "Issue number must be numeric" 1

cd "$ROOT_DIR" || error_exit "Failed to cd to repo root" 1

# Fetch issue
JSON=$(gh issue view "$ISSUE_NUM" --json title,body,number 2>/dev/null) || error_exit "Failed to fetch issue #$ISSUE_NUM (gh issue view)" 1
TITLE=$(echo "$JSON" | jq -r '.title')
BODY=$(echo "$JSON" | jq -r '.body // ""')

# Next intent ID (feature F-XXX)
INTENT_BASE="work/intent"
INTENT_DIR="$INTENT_BASE/features"
mkdir -p "$INTENT_DIR"
LAST=0
while IFS= read -r f; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  if [[ "$base" =~ ^F-([0-9]+)\.md$ ]]; then
    num="${BASH_REMATCH[1]}"
    ((10#$num > LAST)) && LAST=$((10#$num))
  fi
done < <(find "$INTENT_BASE" -type f -name 'F-*.md' 2>/dev/null)
NEXT=$((LAST + 1))
INTENT_ID="F-$(printf "%03d" "$NEXT")"
INTENT_FILE="$INTENT_DIR/$INTENT_ID.md"

# Minimal intent content: title, status, motivation from issue, GitHub issue link
MOTIVATION=$(echo "$BODY" | head -15 | grep -v '^$' | sed 's/^/- /')
[ -z "$MOTIVATION" ] && MOTIVATION="- (From issue #$ISSUE_NUM)"

cat > "$INTENT_FILE" << EOF
# $INTENT_ID: $TITLE

## Type

feature

## Status

planned

## Motivation

$MOTIVATION

## Release Target

R1

## Dependencies

-

## GitHub issue

#$ISSUE_NUM

## Do Not Repeat Check

- [ ] Checked _system/do-not-repeat/abandoned-designs.md
- [ ] Checked _system/do-not-repeat/failed-experiments.md
EOF

echo -e "${GREEN}Created $INTENT_FILE from issue #${ISSUE_NUM}${NC}"
echo "Intent ID: $INTENT_ID"
echo "Title: $TITLE"
