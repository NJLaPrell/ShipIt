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

    if pnpm -s run audit >/dev/null 2>&1; then
        if [ -f "scripts/audit-check.sh" ]; then
            if ./scripts/audit-check.sh moderate; then
                AUDIT_STATUS="pass"
            else
                AUDIT_STATUS="fail (unlisted or expired advisories)"
                FAILED=1
            fi
        else
            if pnpm audit --audit-level=moderate; then
                AUDIT_STATUS="pass"
            else
                AUDIT_STATUS="fail (moderate+ vulnerabilities)"
                FAILED=1
            fi
        fi
    else
        AUDIT_STATUS="skipped (audit not available)"
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

exit "$FAILED"
