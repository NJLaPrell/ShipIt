#!/bin/bash

# Print token/cost usage report from _system/artifacts/usage.json.
# Usage: usage-report.sh [--last N]
# Default: show all entries. --last N: show last N entries only.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CD="${CD:-$REPO_ROOT}"
cd "$CD"

# shellcheck source=scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_cmd jq

USAGE_FILE="_system/artifacts/usage.json"
LAST_N=""

if [ "${1:-}" = "--last" ] && [ -n "${2:-}" ]; then
    LAST_N="$2"
fi

if [ ! -f "$USAGE_FILE" ]; then
    echo "No usage data (missing $USAGE_FILE). Record with: pnpm usage-record <intent_id> <phase> <tokens_in> <tokens_out>" >&2
    exit 0
fi

ENTRIES=$(jq -r '.entries // []' "$USAGE_FILE")
if [ "$ENTRIES" = "[]" ] || [ -z "$ENTRIES" ]; then
    echo "No usage entries yet."
    exit 0
fi

if [ -n "$LAST_N" ]; then
    DATA=$(jq --argjson n "$LAST_N" '.entries | if length > $n then .[length-$n:] else . end' "$USAGE_FILE")
else
    DATA=$(jq '.entries' "$USAGE_FILE")
fi

# Table: intent_id, phase, tokens_in, tokens_out, total, estimated_cost_usd, date, source
printf "%-12s %-14s %10s %10s %10s %12s %-25s %s\n" "intent_id" "phase" "tokens_in" "tokens_out" "total" "cost_usd" "timestamp_iso" "source"
echo "$DATA" | jq -r '.[] | [.intent_id, .phase, (.tokens_in|tostring), (.tokens_out|tostring), ((.tokens_in + .tokens_out)|tostring), (if .estimated_cost_usd == null then "-" else (.estimated_cost_usd | tostring) end), .timestamp_iso, .source] | @tsv' 2>/dev/null | while IFS=$'\t' read -r intent_id phase tokens_in tokens_out total cost ts source; do
    printf "%-12s %-14s %10s %10s %10s %12s %-25s %s\n" "$intent_id" "$phase" "$tokens_in" "$tokens_out" "$total" "$cost" "$ts" "$source"
done
