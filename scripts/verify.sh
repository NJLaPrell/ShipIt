#!/bin/bash

# Verification Script
# Runs verification checks and writes workflow-state/04_verification.md

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: ./scripts/verify.sh <intent-id>" 1
fi

WORKFLOW_DIR="workflow-state"
mkdir -p "$WORKFLOW_DIR"

FAILED=0
TEST_STATUS="not run"
MUTATE_STATUS="not run"
AUDIT_STATUS="not run"

if command -v pnpm >/dev/null 2>&1; then
    if pnpm test; then
        TEST_STATUS="pass"
    else
        TEST_STATUS="fail"
        FAILED=1
    fi

    if pnpm -s run test:mutate >/dev/null 2>&1; then
        if pnpm test:mutate; then
            MUTATE_STATUS="pass"
        else
            MUTATE_STATUS="fail"
            FAILED=1
        fi
    else
        MUTATE_STATUS="skipped (test:mutate not defined)"
    fi

    # Always run audit (no script gate). Use audit-level=high per verification requirements.
    if [ -f "scripts/audit-check.sh" ]; then
        if ./scripts/audit-check.sh high; then
            AUDIT_STATUS="pass"
        else
            AUDIT_STATUS="fail (unlisted or expired advisories)"
            FAILED=1
        fi
    else
        if pnpm audit --audit-level=high; then
            AUDIT_STATUS="pass"
        else
            AUDIT_STATUS="fail (high+ vulnerabilities)"
            FAILED=1
        fi
    fi
else
    error_exit "pnpm is required to run verification checks" 1
fi

cat > "$WORKFLOW_DIR/04_verification.md" << EOF
# Verification: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Test Results

- pnpm test: $TEST_STATUS
- pnpm test:mutate: $MUTATE_STATUS

## Security Review

- pnpm audit --audit-level=high: $AUDIT_STATUS

## Verification Status

$(if [ "$FAILED" -eq 0 ]; then echo "- [x] All checks pass"; else echo "- [ ] All checks pass"; fi)
- [ ] Ready for release
EOF

# Append to confidence-calibration.json if it exists
CALIBRATION_FILE="confidence-calibration.json"
if [ -f "$CALIBRATION_FILE" ] && command -v jq >/dev/null 2>&1; then
    # Determine outcome
    if [ "$FAILED" -eq 0 ]; then
        OUTCOME="success"
    else
        OUTCOME="failure"
    fi
    
    # Generate next decision ID
    LAST_ID=$(jq -r '.decisions[-1].id // "D-000"' "$CALIBRATION_FILE" 2>/dev/null || echo "D-000")
    LAST_NUM=$(echo "$LAST_ID" | sed 's/D-//' | awk '{print int($1)}')
    NEXT_NUM=$((LAST_NUM + 1))
    NEXT_ID=$(printf "D-%03d" "$NEXT_NUM")
    
    # Try to read stated_confidence from analysis file if available
    STATED_CONFIDENCE="null"
    ANALYSIS_FILE="$WORKFLOW_DIR/01_analysis.md"
    if [ -f "$ANALYSIS_FILE" ]; then
        # Try to extract confidence from analysis file (look for "Requirements clarity: X.XX" pattern)
        CONF_LINE=$(grep -i "requirements clarity:" "$ANALYSIS_FILE" 2>/dev/null | head -1)
        if [ -n "$CONF_LINE" ]; then
            EXTRACTED_CONF=$(echo "$CONF_LINE" | grep -oE '[0-9]+\.[0-9]+' | head -1)
            if [ -n "$EXTRACTED_CONF" ]; then
                STATED_CONFIDENCE="$EXTRACTED_CONF"
            fi
        fi
    fi
    
    # Build notes
    NOTES="Intent: $INTENT_ID. Tests: $TEST_STATUS, Mutation: $MUTATE_STATUS, Audit: $AUDIT_STATUS"
    
    # Append new decision
    if [ "$STATED_CONFIDENCE" != "null" ]; then
        # Use --argjson when we have a numeric value
        jq --arg id "$NEXT_ID" \
           --argjson confidence "$STATED_CONFIDENCE" \
           --arg outcome "$OUTCOME" \
           --arg notes "$NOTES" \
           '.decisions += [{
             "id": $id,
             "stated_confidence": $confidence,
             "actual_outcome": $outcome,
             "notes": $notes
           }]' "$CALIBRATION_FILE" > "${CALIBRATION_FILE}.tmp" && \
        mv "${CALIBRATION_FILE}.tmp" "$CALIBRATION_FILE" || true
    else
        # Use null explicitly when confidence is not available
        jq --arg id "$NEXT_ID" \
           --arg outcome "$OUTCOME" \
           --arg notes "$NOTES" \
           '.decisions += [{
             "id": $id,
             "stated_confidence": null,
             "actual_outcome": $outcome,
             "notes": $notes
           }]' "$CALIBRATION_FILE" > "${CALIBRATION_FILE}.tmp" && \
        mv "${CALIBRATION_FILE}.tmp" "$CALIBRATION_FILE" || true
    fi
fi

exit "$FAILED"
