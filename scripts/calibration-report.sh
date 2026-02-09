#!/bin/bash

# Confidence calibration report: stated confidence vs actual outcomes.
# Reads _system/artifacts/confidence-calibration.json; prints metrics and optional alert.
# Usage: calibration-report.sh [--last N] [--json] [--fail-on-threshold X]
#   --last N: show last N decisions in table
#   --json: output metrics as JSON (for dashboard)
#   --fail-on-threshold X: exit 1 if calibration error (MAE) > X (e.g. 0.2)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# shellcheck source=scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_cmd jq

CALIBRATION_FILE="_system/artifacts/confidence-calibration.json"
LAST_N=""
OUTPUT_JSON=false
FAIL_THRESHOLD=""

while [ $# -gt 0 ]; do
    case "$1" in
        --last)
            LAST_N="${2:-}"
            shift 2
            ;;
        --json)
            OUTPUT_JSON=true
            shift
            ;;
        --fail-on-threshold)
            FAIL_THRESHOLD="${2:-}"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--last N] [--json] [--fail-on-threshold X]" >&2
            exit 1
            ;;
    esac
done

if [ ! -f "$CALIBRATION_FILE" ]; then
    echo "No calibration data (missing $CALIBRATION_FILE). Run /verify to record decisions." >&2
    [ "$OUTPUT_JSON" = true ] && echo '{"decisions_count":0,"message":"No calibration file"}' || true
    exit 0
fi

DECISIONS=$(jq -c '.decisions // []' "$CALIBRATION_FILE")
COUNT=$(echo "$DECISIONS" | jq 'length')
if [ "$COUNT" -eq 0 ]; then
    echo "No decisions yet. Run /verify to record confidence vs outcomes." >&2
    [ "$OUTPUT_JSON" = true ] && echo "{\"decisions_count\":0,\"message\":\"No decisions\"}" || true
    exit 0
fi

# Decisions with stated_confidence for metrics (exclude null)
WITH_CONF=$(echo "$DECISIONS" | jq '[.[] | select(.stated_confidence != null)]')
N_WITH_CONF=$(echo "$WITH_CONF" | jq 'length')

if [ "$OUTPUT_JSON" = true ]; then
    # JSON output: metrics for dashboard
    MAE="null"
    BRIER="null"
    OVER_UNDER="null"
    BINS_JSON="[]"
    if [ "$N_WITH_CONF" -gt 0 ]; then
        MAE=$(echo "$WITH_CONF" | jq '
            [.[] | (.stated_confidence - (if .actual_outcome == "success" then 1 else 0 end)) | if . < 0 then -. else . end] | add / length
        ')
        BRIER=$(echo "$WITH_CONF" | jq '
            [.[] | ((.stated_confidence - (if .actual_outcome == "success" then 1 else 0 end)) | . * .)] | add / length
        ')
        AVG_STATED=$(echo "$WITH_CONF" | jq '[.[].stated_confidence] | add / length')
        SUCCESS_RATE=$(echo "$WITH_CONF" | jq '[.[] | if .actual_outcome == "success" then 1 else 0 end] | add / length')
        if [ "$(echo "$AVG_STATED" | jq '. > '"$SUCCESS_RATE"'')" = "true" ]; then
            OVER_UNDER="over-confident"
        elif [ "$(echo "$AVG_STATED" | jq '. < '"$SUCCESS_RATE"'')" = "true" ]; then
            OVER_UNDER="under-confident"
        else
            OVER_UNDER="well-calibrated"
        fi
        BINS_JSON=$(echo "$WITH_CONF" | jq '
            def bin_label(c):
                if c < 0.5 then "0.0-0.5"
                elif c < 0.7 then "0.5-0.7"
                elif c < 0.9 then "0.7-0.9"
                else "0.9-1.0" end;
            [.[] | {bin: bin_label(.stated_confidence), stated: .stated_confidence, success: (if .actual_outcome == "success" then 1 else 0 end)}]
            | group_by(.bin)
            | map({
                bin: .[0].bin,
                total: length,
                successes: (map(.success) | add),
                success_rate: ((map(.success) | add) / length)
              })
        ')
    fi
    jq -n \
        --argjson decisions_count "$COUNT" \
        --argjson with_confidence "$N_WITH_CONF" \
        --argjson mae "$MAE" \
        --argjson brier "$BRIER" \
        --argjson bins "$BINS_JSON" \
        --arg over_under "$OVER_UNDER" \
        '{decisions_count: $decisions_count, with_confidence: $with_confidence, calibration_error_mae: $mae, brier_score: $brier, bins: $bins, over_under: $over_under}'
    exit 0
fi

# Human-readable report
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Confidence Calibration Report${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if [ "$N_WITH_CONF" -eq 0 ]; then
    echo "No decisions with stated_confidence yet (run /verify after analysis phases that output confidence)."
    echo "Total decisions: $COUNT (outcomes only)."
    echo ""
    echo "Last decisions:"
    echo "$DECISIONS" | jq -r '.[-10:] | .[] | "  \(.id)  outcome=\(.actual_outcome)  stated_confidence=\(.stated_confidence // "n/a")"' 2>/dev/null || true
    exit 0
fi

# Calibration error (MAE)
MAE=$(echo "$WITH_CONF" | jq '[.[] | (.stated_confidence - (if .actual_outcome == "success" then 1 else 0 end)) | if . < 0 then -. else . end] | add / length')
BRIER=$(echo "$WITH_CONF" | jq '[.[] | ((.stated_confidence - (if .actual_outcome == "success" then 1 else 0 end)) | . * .)] | add / length')

echo -e "${CYAN}Metrics (decisions with stated_confidence: $N_WITH_CONF)${NC}"
echo "  Calibration error (MAE): $MAE"
echo "  Brier score:             $BRIER"
echo ""

# Over/under confidence
AVG_STATED=$(echo "$WITH_CONF" | jq '[.[].stated_confidence] | add / length')
SUCCESS_RATE=$(echo "$WITH_CONF" | jq '[.[] | if .actual_outcome == "success" then 1 else 0 end] | add / length')
echo -e "${CYAN}Calibration summary${NC}"
echo "  Avg stated confidence: $AVG_STATED  |  Actual success rate: $SUCCESS_RATE"
if [ "$(echo "$AVG_STATED" | jq '. > '"$SUCCESS_RATE"'')" = "true" ]; then
    echo -e "  ${YELLOW}→ Over-confident: stated confidence is higher than actual success rate. Consider lowering stated confidence when uncertain.${NC}"
elif [ "$(echo "$AVG_STATED" | jq '. < '"$SUCCESS_RATE"'')" = "true" ]; then
    echo -e "  ${GREEN}→ Under-confident: stated confidence is lower than actual success. You may be more confident when outcomes are good.${NC}"
else
    echo -e "  ${GREEN}→ Well-calibrated.${NC}"
fi
echo ""

# Bins table
echo -e "${CYAN}Success rate by confidence bin${NC}"
printf "  %-12s %6s %8s %10s\n" "Bin" "Total" "Success" "Rate"
echo "$WITH_CONF" | jq -r '
    def bin_label(c):
        if c < 0.5 then "0.0-0.5"
        elif c < 0.7 then "0.5-0.7"
        elif c < 0.9 then "0.7-0.9"
        else "0.9-1.0" end;
    [.[] | {bin: bin_label(.stated_confidence), success: (if .actual_outcome == "success" then 1 else 0 end)}]
    | group_by(.bin)
    | map({bin: .[0].bin, total: length, successes: (map(.success) | add)})
    | sort_by(.bin)
    | .[]
    | "  \(.bin)  \(.total)  \(.successes)  \((.successes / .total * 100) | floor / 100)"
' 2>/dev/null | while read -r line; do echo "$line"; done
echo ""

# Optional alert: last K with high stated confidence but low success
ALERT_K=10
RECENT_HIGH=$(echo "$DECISIONS" | jq '[.[-'"$ALERT_K"':] | .[] | select(.stated_confidence != null and .stated_confidence > 0.8)]')
N_RECENT_HIGH=$(echo "$RECENT_HIGH" | jq 'length')
if [ "$N_RECENT_HIGH" -ge 3 ]; then
    RECENT_SUCCESS_RATE=$(echo "$RECENT_HIGH" | jq '[.[] | if .actual_outcome == "success" then 1 else 0 end] | add / length')
    if [ "$(echo "$RECENT_SUCCESS_RATE" | jq '. < 0.5')" = "true" ]; then
        echo -e "${YELLOW}⚠ Possible over-confidence: last $ALERT_K decisions with stated_confidence > 0.8 have success rate < 50%. Review recent decisions.${NC}"
        echo ""
    fi
fi

# Last N decisions table
if [ -n "$LAST_N" ]; then
    echo -e "${CYAN}Last $LAST_N decisions${NC}"
    printf "  %-8s %8s %-8s %s\n" "ID" "Stated" "Outcome" "Notes (truncated)"
    echo "$DECISIONS" | jq -r --argjson n "$LAST_N" '.[-$n:] | .[] | "  \(.id)  \(.stated_confidence // "n/a")  \(.actual_outcome)  \(.notes | .[0:50])"' 2>/dev/null | while read -r line; do echo "$line"; done
    echo ""
fi

# Exit 1 if --fail-on-threshold and MAE > threshold
if [ -n "$FAIL_THRESHOLD" ]; then
    if [ "$(echo "$MAE" | jq '. > '"$FAIL_THRESHOLD"'')" = "true" ]; then
        echo -e "${RED}Calibration error ($MAE) exceeds threshold ($FAIL_THRESHOLD).${NC}" >&2
        exit 1
    fi
fi

exit 0
