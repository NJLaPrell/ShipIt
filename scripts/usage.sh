#!/bin/bash

# Record token-usage (or cost) for a phase/intent.
# Values are estimates unless source is "api" (e.g. from provider response).
# Usage: usage.sh <intent_id> <phase> <tokens_in> <tokens_out> [estimated_cost_usd] [source]
# Example: ./scripts/usage.sh F-001 analysis 1500 800
# Example: ./scripts/usage.sh F-001 plan 2000 1200 0.02 cursor_estimate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# shellcheck source=scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_cmd jq

USAGE_FILE="_system/artifacts/usage.json"

if [ $# -lt 4 ]; then
    echo "Usage: $0 <intent_id> <phase> <tokens_in> <tokens_out> [estimated_cost_usd] [source]" >&2
    echo "  source: cursor_estimate (default) | api" >&2
    exit 1
fi

INTENT_ID="$1"
PHASE="$2"
TOKENS_IN="$3"
TOKENS_OUT="$4"
COST="${5:-null}"
SOURCE="${6:-cursor_estimate}"

if ! [[ "$TOKENS_IN" =~ ^[0-9]+$ ]] || ! [[ "$TOKENS_OUT" =~ ^[0-9]+$ ]]; then
    error_exit "tokens_in and tokens_out must be non-negative integers" 1
fi

mkdir -p _system/artifacts

if [ ! -f "$USAGE_FILE" ]; then
    echo '{"entries":[]}' > "$USAGE_FILE"
fi

TIMESTAMP_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
NEW_ENTRY=$(jq -n \
    --arg intent_id "$INTENT_ID" \
    --arg phase "$PHASE" \
    --argjson tokens_in "$TOKENS_IN" \
    --argjson tokens_out "$TOKENS_OUT" \
    --argjson cost "$COST" \
    --arg ts "$TIMESTAMP_ISO" \
    --arg source "$SOURCE" \
    '{ intent_id: $intent_id, phase: $phase, tokens_in: $tokens_in, tokens_out: $tokens_out, estimated_cost_usd: $cost, timestamp_iso: $ts, source: $source }')

jq --argjson entry "$NEW_ENTRY" '.entries += [$entry]' "$USAGE_FILE" > "$USAGE_FILE.nw" && mv "$USAGE_FILE.nw" "$USAGE_FILE"

echo "Recorded: $INTENT_ID $PHASE (in=$TOKENS_IN out=$TOKENS_OUT) source=$SOURCE"
