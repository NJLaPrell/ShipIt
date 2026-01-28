#!/bin/bash

# Workflow Orchestrator Script
# Automates workflow state file generation and phase transitions

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: $0 <intent-id>" 1
fi

resolve_intent_file() {
    local intent_id="$1"

    # If the caller passed a direct path, respect it.
    if [ -f "$intent_id" ]; then
        echo "$intent_id"
        return 0
    fi

    # Common/expected locations (init-project + new-intent + scope-project write to subfolders).
    local candidates=(
        "intent/$intent_id.md"
        "intent/features/$intent_id.md"
        "intent/bugs/$intent_id.md"
        "intent/tech-debt/$intent_id.md"
    )

    local candidate=""
    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    # Fallback: search one level deep under intent/ (portable; no find/globstar needed).
    local matches=()
    shopt -s nullglob
    matches=( intent/*/"$intent_id".md )
    shopt -u nullglob

    if [ "${#matches[@]}" -eq 1 ]; then
        echo "${matches[0]}"
        return 0
    fi

    if [ "${#matches[@]}" -gt 1 ]; then
        error_exit "Multiple intent files found for $intent_id: ${matches[*]}" 1
    fi

    return 1
}

INTENT_FILE="$(resolve_intent_file "$INTENT_ID")" || error_exit "Intent file not found for id '$INTENT_ID' (looked under intent/ and intent/*/)" 1

WORKFLOW_DIR="workflow-state"
mkdir -p "$WORKFLOW_DIR"

# Source progress library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/progress.sh" ]; then
    source "$SCRIPT_DIR/lib/progress.sh"
fi

echo -e "${BLUE}Orchestrating workflow for $INTENT_ID...${NC}"
echo -e "${BLUE}Using intent file: ${INTENT_FILE}${NC}"
echo ""

# Phase 1: Analysis
create_analysis() {
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 1 5 "Analysis" "running"
    else
        echo -e "${YELLOW}[Phase 1/5] Analysis... ⏳${NC}"
    fi
    
    cat > "$WORKFLOW_DIR/01_analysis.md" << EOF || error_exit "Failed to create analysis state"
# Analysis: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Requirements

[To be filled by PM agent]

## Acceptance Criteria

[To be filled by PM agent]

## Confidence Scores

- Requirements clarity: [0.0-1.0]
- Domain assumptions: [0.0-1.0]

## Do-Not-Repeat Check

[Results from /do-not-repeat/ check]

## Next Steps

Proceed to Planning phase.
EOF

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 1 5 "Analysis" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/01_analysis.md${NC}"
    fi
}

# Phase 2: Planning
create_plan() {
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 2 5 "Planning" "running"
    else
        echo -e "${YELLOW}[Phase 2/5] Planning... ⏳${NC}"
    fi
    
    cat > "$WORKFLOW_DIR/02_plan.md" << EOF || error_exit "Failed to create plan state"
# Plan: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Technical Approach

[To be filled by Architect agent]

## Files to Create/Modify

- [File list]

## CANON.md Compliance

[Compliance check results]

## Rollback Strategy

[Rollback plan]

## Approval Status

- [ ] Human approval required
- [ ] Approved
- [ ] Blocked

## Next Steps

Proceed to Test Writing phase.
EOF

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 2 5 "Planning" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/02_plan.md${NC}"
    fi
}

# Phase 3: Implementation
create_implementation() {
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 3 5 "Implementation" "running"
    else
        echo -e "${YELLOW}[Phase 3/5] Implementation... ⏳${NC}"
    fi
    
    cat > "$WORKFLOW_DIR/03_implementation.md" << EOF || error_exit "Failed to create implementation state"
# Implementation: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Implementation Progress

[To be filled by Implementer agent]

## Files Modified

- [List of files]

## Tests Status

- [ ] All tests pass
- [ ] Coverage meets threshold

## Deviations from Plan

[Any deviations and rationale]

## Next Steps

Proceed to Verification phase.
EOF

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 3 5 "Implementation" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/03_implementation.md${NC}"
    fi
}

# Phase 4: Verification
create_verification() {
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 4 5 "Verification" "running"
    else
        echo -e "${YELLOW}[Phase 4/5] Verification... ⏳${NC}"
    fi
    
    cat > "$WORKFLOW_DIR/04_verification.md" << EOF || error_exit "Failed to create verification state"
# Verification: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Test Results

[QA agent results]

## Mutation Testing

[Mutation test results]

## Security Review

[Security agent findings]

## Dependency Audit

[Audit results]

## Verification Status

- [ ] All checks pass
- [ ] Ready for release

## Next Steps

Proceed to Release phase.
EOF

    # Backward compatibility: some docs/tests still look for 05_verification.md
    cat > "$WORKFLOW_DIR/05_verification.md" << EOF || error_exit "Failed to create legacy verification state"
# Verification (Legacy): $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

This file is deprecated. Use `workflow-state/04_verification.md`.
EOF

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 4 5 "Verification" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/04_verification.md${NC}"
    fi
}

# Phase 5: Release Notes
create_release() {
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 5 5 "Release" "running"
    else
        echo -e "${YELLOW}[Phase 5/5] Release... ⏳${NC}"
    fi
    
    cat > "$WORKFLOW_DIR/05_release_notes.md" << EOF || error_exit "Failed to create release notes state"
# Release Notes: $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

## Documentation Updates

[Docs agent updates]

## Release Notes

[Release notes]

## Approval Summary

[Steward decision and rationale]
EOF

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress 5 5 "Release" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/05_release_notes.md${NC}"
    fi
}

# Update active.md
update_active() {
    cat > "$WORKFLOW_DIR/active.md" << EOF || error_exit "Failed to update active.md"
# Active Intent

**Intent ID:** $INTENT_ID
**Status:** active
**Current Phase:** [Phase name]
**Started:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Progress

- [ ] Phase 1: Analysis
- [ ] Phase 2: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 4: Verification
- [ ] Phase 5: Release Notes

## Assigned Agents

[Agent assignments]
EOF

    echo -e "${GREEN}✓ Updated $WORKFLOW_DIR/active.md${NC}"
}

# Check gate
check_gate() {
    local phase="$1"
    local gate_file="$2"
    
    if [ ! -f "$gate_file" ]; then
        return 1
    fi
    
    # Check for approval markers
    if grep -q "\[ \].*approval\|\[ \].*Approval" "$gate_file" 2>/dev/null; then
        # Check if approved
        if grep -q "\[x\].*approval\|\[x\].*Approval\|Approved\|APPROVE" "$gate_file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
    
    return 0
}

# Main workflow
main() {
    # Initialize all state files
    create_analysis
    create_plan
    create_implementation
    create_verification
    create_release
    update_active
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Workflow state files created${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Fill in $WORKFLOW_DIR/01_analysis.md (PM role)"
    echo "2. Fill in $WORKFLOW_DIR/02_plan.md (Architect role)"
    echo "3. Fill in $WORKFLOW_DIR/03_implementation.md (Implementer role)"
    echo "4. Fill in $WORKFLOW_DIR/04_verification.md (QA + Security roles)"
    echo "5. Fill in $WORKFLOW_DIR/05_release_notes.md (Docs + Steward roles)"
    echo ""
}

main
