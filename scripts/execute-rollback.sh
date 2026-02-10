#!/bin/bash
# Execute rollback for an intent in guided mode.
# Reads rollback plan from work/workflow-state/ (flat or per-intent per workflow-state-layout).
# High-risk steps: display only. Safe steps: prompt [y/N], execute if confirmed.
# Audit log: work/workflow-state/rollback-log.md
# Usage: ./scripts/execute-rollback.sh <intent-id> [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# shellcheck source=scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

INTENT_ID=""
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    -*)
      error_exit "Unknown option: $1. Usage: $0 <intent-id> [--dry-run]" 1
      ;;
    *)
      [ -z "$INTENT_ID" ] || error_exit "Multiple intent IDs given. Usage: $0 <intent-id> [--dry-run]" 1
      INTENT_ID="$1"
      shift
      ;;
  esac
done

[ -n "$INTENT_ID" ] || error_exit "Missing intent-id. Usage: $0 <intent-id> [--dry-run]" 1

WS="work/workflow-state"
LOG_FILE="$WS/rollback-log.md"

# Resolve rollback plan path per workflow-state-layout.md
resolve_rollback_plan() {
  local per_intent="$WS/$INTENT_ID"
  if [ -d "$per_intent" ]; then
    if [ -f "$per_intent/rollback.md" ]; then
      echo "$per_intent/rollback.md"
      return 0
    fi
    if [ -f "$per_intent/02_plan.md" ]; then
      echo "$per_intent/02_plan.md"
      return 0
    fi
  fi
  if [ -f "$WS/rollback.md" ]; then
    echo "$WS/rollback.md"
    return 0
  fi
  if [ -f "$WS/02_plan.md" ]; then
    echo "$WS/02_plan.md"
    return 0
  fi
  return 1
}

ROLLBACK_SOURCE="$(resolve_rollback_plan)" || error_exit "No rollback plan found. Run /revert-plan $INTENT_ID first." 1

# Extract rollback content: from rollback.md (full file) or from 02_plan.md (rollback section)
get_rollback_content() {
  if [[ "$ROLLBACK_SOURCE" == *rollback.md ]]; then
    cat "$ROLLBACK_SOURCE"
  else
    awk '/## Rollback|## rollback|# Rollback Plan/,/^## [^R]|^## [^r]|^$/ {print}' "$ROLLBACK_SOURCE" || cat "$ROLLBACK_SOURCE"
  fi
}

# High-risk keywords: do NOT offer execution, display only
HIGH_RISK_PATTERNS="force|drop|delete|migration down|production|auth|secret|--force|-f |rm -r|rm -rf"

# Safe pattern: simple git revert (single sha, no force)
is_safe_git_revert() {
  local step="$1"
  [[ "$step" =~ ^-[[:space:]]*git[[:space:]]+revert[[:space:]]+[a-fA-F0-9]+([[:space:]]*$|[[:space:]]+-m) ]] && \
  ! echo "$step" | grep -qEi "$HIGH_RISK_PATTERNS"
}

is_high_risk() {
  echo "$1" | grep -qEi "$HIGH_RISK_PATTERNS"
}

log_entry() {
  local outcome="$1"
  local step_preview="$2"
  mkdir -p "$(dirname "$LOG_FILE")"
  {
    echo ""
    echo "## $(date -u +"%Y-%m-%dT%H:%M:%SZ") - $INTENT_ID"
    echo "- **Outcome:** $outcome"
    echo "- **Step:** ${step_preview:0:100}..."
    echo ""
  } >> "$LOG_FILE"
}

CONTENT="$(get_rollback_content)"

if [ -z "$CONTENT" ]; then
  error_exit "Rollback plan is empty or has no rollback section." 1
fi

echo -e "${BLUE}Rollback Plan for $INTENT_ID${NC}"
echo -e "${BLUE}Source: $ROLLBACK_SOURCE${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would process the following steps:${NC}"
  echo "$CONTENT" | grep -E '^[[:space:]]*- ' | sed 's/^/  /'
  echo ""
  echo "Run without --dry-run to execute (safe steps only, with confirmation)."
  exit 0
fi

# Extract bullet steps (lines starting with - )
steps=()
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.+) ]]; then
    steps+=("${BASH_REMATCH[1]}")
  fi
done < <(echo "$CONTENT")

if [ ${#steps[@]} -eq 0 ]; then
  echo "No bullet steps found in rollback plan. Displaying full plan:"
  echo "$CONTENT"
  exit 0
fi

echo "Before executing any step that touches production, infra, or data, ensure you have reviewed the rollback plan."
echo ""

for step in "${steps[@]}"; do
  step_trimmed="${step#"${step%%[![:space:]]*}"}"
  if [ -z "$step_trimmed" ]; then
    continue
  fi

  if is_high_risk "$step_trimmed"; then
    echo -e "${RED}[MANUAL]${NC} $step_trimmed"
    echo "  → Run this manually. Do not auto-execute."
    log_entry "manual" "$step_trimmed"
    continue
  fi

  if is_safe_git_revert "$step_trimmed"; then
    echo -e "${YELLOW}[CONFIRM]${NC} $step_trimmed"
    read -r -p "Run this? [y/N] " resp
    if [[ "$resp" =~ ^[yY]$ ]]; then
      sha="$(echo "$step_trimmed" | grep -oE '[a-fA-F0-9]{7,40}' | head -1)"
      if [ -n "$sha" ] && git revert --no-edit "$sha"; then
        echo -e "${GREEN}Done.${NC}"
        log_entry "confirmed" "$step_trimmed"
      else
        echo -e "${RED}Failed. Run manually if needed.${NC}"
        log_entry "failed" "$step_trimmed"
      fi
    else
      echo "Skipped."
      log_entry "skipped" "$step_trimmed"
    fi
  else
    echo -e "${YELLOW}[MANUAL]${NC} $step_trimmed"
    echo "  → Not in safe allowlist. Run manually."
    log_entry "manual" "$step_trimmed"
  fi
  echo ""
done

echo -e "${GREEN}Rollback flow complete. Log: $LOG_FILE${NC}"
