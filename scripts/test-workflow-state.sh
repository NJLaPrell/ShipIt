#!/usr/bin/env bash
# Smoke test for workflow-state flat vs per-intent layout (issue #60).
# Run from repo root: bash scripts/test-workflow-state.sh
# Requires: project.json, work/intent (with at least one intent).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { echo -e "${RED}FAIL: $*${NC}" >&2; exit 1; }
ok()   { echo -e "${GREEN}OK: $*${NC}"; }

# Source the lib (use ORCHESTRATOR_DIR pattern so SCRIPT_DIR in lib is lib dir)
source "$SCRIPT_DIR/lib/workflow_state.sh"

# 1) list_active_intent_ids: should not crash; may be empty or list ids
ids=($(list_active_intent_ids))
ok "list_active_intent_ids returned ${#ids[@]} active(s)"

# 2) get_workflow_state_dir with no arg: when flat in use, returns WS_BASE
dir="$(get_workflow_state_dir)"
if flat_in_use; then
  [ "$dir" = "$WS_BASE" ] || fail "get_workflow_state_dir (no arg) should be WS_BASE when flat in use, got: $dir"
  ok "get_workflow_state_dir () returns flat when flat in use"
fi

# 3) get_workflow_state_dir with intent id: returns path (flat or per-intent)
if [ ${#ids[@]} -gt 0 ]; then
  first="${ids[0]}"
  dir="$(get_workflow_state_dir "$first")"
  [ -n "$dir" ] || fail "get_workflow_state_dir $first returned empty"
  [[ "$dir" == *"workflow-state"* ]] || fail "get_workflow_state_dir $first should contain workflow-state, got: $dir"
  ok "get_workflow_state_dir $first = $dir"
fi

# 4) ensure_workflow_state_dir with new id: creates per-intent when flat already has one active
# Skip if we don't have two intents - just ensure ensure_workflow_state_dir runs
d="$(ensure_workflow_state_dir "F-DUMMY")"
[ -n "$d" ] || fail "ensure_workflow_state_dir F-DUMMY returned empty"
ok "ensure_workflow_state_dir F-DUMMY = $d"

echo ""
echo -e "${GREEN}Workflow state layout smoke test passed.${NC}"
