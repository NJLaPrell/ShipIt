#!/bin/bash

# Metrics Collection Script
# Tracks workflow success rates and time-per-phase metrics

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

METRICS_FILE="metrics.json"

echo -e "${BLUE}Collecting workflow metrics...${NC}"

# Initialize metrics if needed
if [ ! -f "$METRICS_FILE" ]; then
    cat > "$METRICS_FILE" << EOF
{
  "version": "1.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "workflows": [],
  "summary": {
    "totalWorkflows": 0,
    "successfulWorkflows": 0,
    "failedWorkflows": 0,
    "averagePhaseTime": {},
    "bottlenecks": []
  }
}
EOF
fi

# Collect intent metrics
intent_files=()
while IFS= read -r file; do
    intent_files+=("$file")
done < <(find intent -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

INTENT_TOTAL=${#intent_files[@]}
if [ "$INTENT_TOTAL" -gt 0 ]; then
    INTENT_SHIPPED=$(grep -l "Status.*shipped" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
    INTENT_FAILED=$(grep -l "Status.*killed" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
else
    INTENT_SHIPPED=0
    INTENT_FAILED=0
fi

# Calculate success rate
if [ "$INTENT_TOTAL" -gt 0 ]; then
    SUCCESS_RATE=$((INTENT_SHIPPED * 100 / INTENT_TOTAL))
else
    SUCCESS_RATE=0
fi

# Collect phase completion times (if workflow state files have timestamps)
collect_phase_times() {
    local intent_id="$1"
    local phases=("01_analysis" "02_plan" "03_implementation" "04_verification" "05_release_notes")
    
    for phase in "${phases[@]}"; do
        local file="work/workflow-state/${phase}.md"
        if [ -f "$file" ]; then
            # Extract timestamp if available
            local created=$(grep -i "generated\|created" "$file" | head -1 | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" | head -1 || echo "")
            echo "$phase:$created"
        fi
    done
}

# Generate metrics summary
cat > "metrics-summary.md" << EOF || error_exit "Failed to generate metrics summary"
# Workflow Metrics Summary

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Success Metrics

| Metric | Value |
|--------|-------|
| **Total Intents** | $INTENT_TOTAL |
| **Shipped** | $INTENT_SHIPPED |
| **Failed/Killed** | $INTENT_FAILED |
| **Success Rate** | $SUCCESS_RATE% |

## Phase Completion

[Phase completion times will be tracked here]

## Bottlenecks

[Identified bottlenecks will be listed here]

## Recommendations

[Recommendations based on metrics]

---

*Run \`pnpm collect-metrics\` to update metrics.*
EOF

echo -e "${GREEN}✓ Metrics collected${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  Total Intents: $INTENT_TOTAL"
echo "  Success Rate: $SUCCESS_RATE%"
echo "  Metrics saved to: metrics-summary.md"
echo ""
