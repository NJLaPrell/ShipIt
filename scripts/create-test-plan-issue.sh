#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/create-test-plan-issue.sh \
    --title "..." \
    --severity low|medium|high \
    --step "4-1" \
    --expected "..." \
    --actual "..." \
    --error "..." \
    --impl "Action item 1" \
    [--impl "Action item 2"] \
    [--repo owner/name]

Notes:
  - If --repo is omitted, the script will try to resolve it via:
      gh repo view --json nameWithOwner -q .nameWithOwner
  - This script intentionally avoids literal '\n' sequences in the issue body.
EOF
}

TITLE=""
SEVERITY=""
STEP_ID=""
EXPECTED=""
ACTUAL=""
ERROR_TEXT=""
REPO=""
IMPL_ITEMS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE="${2:-}"; shift 2 ;;
    --severity) SEVERITY="${2:-}"; shift 2 ;;
    --step) STEP_ID="${2:-}"; shift 2 ;;
    --expected) EXPECTED="${2:-}"; shift 2 ;;
    --actual) ACTUAL="${2:-}"; shift 2 ;;
    --error) ERROR_TEXT="${2:-}"; shift 2 ;;
    --impl) IMPL_ITEMS+=("${2:-}"); shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$TITLE" ] || [ -z "$SEVERITY" ] || [ -z "$STEP_ID" ] || [ -z "$EXPECTED" ] || [ -z "$ACTUAL" ] || [ -z "$ERROR_TEXT" ]; then
  echo "Missing required arguments." >&2
  usage
  exit 2
fi

case "$SEVERITY" in
  low|medium|high) ;;
  *) echo "Invalid --severity: $SEVERITY (expected low|medium|high)" >&2; exit 2 ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed (required)." >&2
  exit 1
fi

gh auth status >/dev/null

if [ -z "$REPO" ]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
fi

if [ -z "$REPO" ]; then
  echo "Could not resolve GitHub repo. Provide --repo owner/name." >&2
  exit 1
fi

FIRST_SEEN="$(date +%F)"

BODY_FILE="$(mktemp)"
{
  echo "**Severity:** $SEVERITY"
  echo "**Step:** $STEP_ID"
  echo "**First Seen:** $FIRST_SEEN"
  echo
  echo "## Expected"
  echo
  echo "$EXPECTED"
  echo
  echo "## Actual"
  echo
  echo "$ACTUAL"
  echo
  echo "## Error"
  echo
  echo "$ERROR_TEXT"
  echo
  echo "## Implementation"
  echo
  if [ "${#IMPL_ITEMS[@]}" -eq 0 ]; then
    echo "- (none provided)"
  else
    for item in "${IMPL_ITEMS[@]}"; do
      echo "- $item"
    done
  fi
} >"$BODY_FILE"

gh issue create --repo "$REPO" --title "$TITLE" --body-file "$BODY_FILE"

rm -f "$BODY_FILE"

