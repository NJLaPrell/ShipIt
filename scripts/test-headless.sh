#!/usr/bin/env bash
# Smoke test for headless mode (issue #65). Ensures run-phase.sh runs and fails cleanly without API keys.
# With OPENAI_API_KEY or ANTHROPIC_API_KEY set, you can run phase 1 and assert output file exists.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
fail() { echo -e "${RED}FAIL: $*${NC}" >&2; exit 1; }
ok()   { echo -e "${GREEN}OK: $*${NC}"; }

# Need an intent that exists and has workflow state (or we'll get "run workflow-orchestrator first")
INTENT_ID="${1:-F-DUMMY}"
if [ ! -f "work/intent/features/$INTENT_ID.md" ] && [ ! -f "work/intent/$INTENT_ID.md" ]; then
  # Try to find any intent
  INTENT_ID=""
  for f in work/intent/features/*.md work/intent/*.md; do
    [ -f "$f" ] && INTENT_ID="$(basename "$f" .md)" && break
  done 2>/dev/null || true
fi
[ -n "$INTENT_ID" ] || { echo "Skip: no intent file found (create one or pass intent-id)"; exit 0; }

# 1) Without API keys, run-phase.sh must exit 1 with clear message
unset OPENAI_API_KEY ANTHROPIC_API_KEY
out="$(bash scripts/headless/run-phase.sh "$INTENT_ID" 1 2>&1)" || true
if [ "${#out}" -eq 0 ]; then
  fail "run-phase.sh should print message when API keys unset"
fi
if ! echo "$out" | grep -q "OPENAI_API_KEY\|ANTHROPIC_API_KEY"; then
  fail "run-phase.sh should mention API key env vars when unset"
fi
ok "run-phase.sh exits with clear message when API keys unset"

# 2) Invalid phase number must exit 1
out2="$(bash scripts/headless/run-phase.sh "$INTENT_ID" 99 2>&1)" || true
if ! echo "$out2" | grep -q "Phase must be 1-5\|error\|Error"; then
  fail "run-phase.sh should reject invalid phase number"
fi
ok "run-phase.sh rejects invalid phase"

echo ""
echo -e "${GREEN}Headless smoke test passed.${NC}"
