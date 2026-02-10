#!/usr/bin/env bash
# Run one ShipIt phase headless (no Cursor). Reads same .cursor/ content, calls LLM, writes state.
# Usage: ./scripts/headless/run-phase.sh <intent-id> <phase-number>
# Phase: 1=Analysis, 2=Planning, 3=Implementation, 4=Verification, 5=Release.
# Requires OPENAI_API_KEY or ANTHROPIC_API_KEY. See docs/headless-mode.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Source libs (use absolute paths so we find them from repo root)
HELPER_DIR="$SCRIPT_DIR/../lib"
[ -f "$HELPER_DIR/common.sh" ] && source "$HELPER_DIR/common.sh"
[ -f "$HELPER_DIR/intent.sh" ] && source "$HELPER_DIR/intent.sh"
[ -f "$HELPER_DIR/workflow_state.sh" ] && source "$HELPER_DIR/workflow_state.sh"

INTENT_ID="${1:-}"
PHASE_NUM="${2:-}"
if [ -z "$INTENT_ID" ] || [ -z "$PHASE_NUM" ]; then
  echo "Usage: $0 <intent-id> <phase-number>" >&2
  echo "  Phase: 1=Analysis, 2=Planning, 3=Implementation, 4=Verification, 5=Release" >&2
  exit 1
fi

# Require intent file
require_intent_file "$INTENT_ID" >/dev/null || error_exit "Intent file not found for $INTENT_ID" 1

# Resolve workflow state dir (flat or per-intent)
WORKFLOW_DIR="$(get_workflow_state_dir "$INTENT_ID")"
[ -n "$WORKFLOW_DIR" ] || error_exit "No workflow state dir for $INTENT_ID. Run pnpm workflow-orchestrator $INTENT_ID first." 1
mkdir -p "$WORKFLOW_DIR"

# Phase config: output file, role rule name, phase name
case "$PHASE_NUM" in
  1) OUT_FILE="01_analysis.md";   ROLE_RULE="pm";         PHASE_NAME="Analysis (PM)" ;;
  2) OUT_FILE="02_plan.md";       ROLE_RULE="architect";  PHASE_NAME="Planning (Architect)" ;;
  3) OUT_FILE="03_implementation.md"; ROLE_RULE="implementer"; PHASE_NAME="Implementation (Implementer)" ;;
  4) OUT_FILE="04_verification.md"; ROLE_RULE="qa";       PHASE_NAME="Verification (QA)" ;;
  5) OUT_FILE="05_release_notes.md"; ROLE_RULE="docs";    PHASE_NAME="Release (Docs)" ;;
  *) error_exit "Phase must be 1-5, got: $PHASE_NUM" 1 ;;
esac

# Check API key
if [ -z "${OPENAI_API_KEY:-}" ] && [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "Set OPENAI_API_KEY or ANTHROPIC_API_KEY to run headless. Never commit API keys." >&2
  echo "See docs/headless-mode.md for details." >&2
  exit 1
fi

# Read role rule and ship command content (same source as Cursor)
ROLE_FILE=".cursor/rules/${ROLE_RULE}.mdc"
SHIP_FILE=".cursor/commands/ship.md"
[ -f "$ROLE_FILE" ] || error_exit "Role rule not found: $ROLE_FILE" 1
[ -f "$SHIP_FILE" ] || error_exit "Command file not found: $SHIP_FILE" 1

ROLE_CONTENT="$(cat "$ROLE_FILE")"
SHIP_CONTENT="$(cat "$SHIP_FILE")"

# Build prompt: single source of instructions
PROMPT="You are running ShipIt Phase $PHASE_NUM: $PHASE_NAME. Intent ID: $INTENT_ID.
Write the content for the output file: $OUT_FILE (path under work/workflow-state).
Do not include the filename or markdown fence in your response; output only the file body.

=== Role and constraints (follow these) ===
$ROLE_CONTENT

=== Workflow instructions (ship command) ===
$SHIP_CONTENT

=== Task ===
Produce the complete content for $OUT_FILE for intent $INTENT_ID. Output only the file body, no preamble."

# Call LLM and write output
echo "Running Phase $PHASE_NUM ($PHASE_NAME) for $INTENT_ID..." >&2
node "$SCRIPT_DIR/call-llm.js" --prompt "$PROMPT" > "$WORKFLOW_DIR/$OUT_FILE" || exit 1
echo "Wrote $WORKFLOW_DIR/$OUT_FILE" >&2

# Human gates: after phase 2 (plan) and phase 5 (release)
if [ "$PHASE_NUM" = "2" ]; then
  echo "" >&2
  echo "*** Waiting for human approval ***" >&2
  echo "Review $WORKFLOW_DIR/02_plan.md and add APPROVED (or check the approval box)." >&2
  echo "Then run: $0 $INTENT_ID 3" >&2
  exit 0
fi
if [ "$PHASE_NUM" = "5" ]; then
  echo "" >&2
  echo "*** Release phase complete. Steward/human approval may be required. ***" >&2
  echo "Review $WORKFLOW_DIR/05_release_notes.md. Then run verify or ship as needed." >&2
  exit 0
fi

# Next phase hint
NEXT=$((PHASE_NUM + 1))
if [ "$NEXT" -le 5 ]; then
  echo "Next: $0 $INTENT_ID $NEXT" >&2
fi
