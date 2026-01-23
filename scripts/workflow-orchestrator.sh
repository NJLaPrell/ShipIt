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

INTENT_FILE="intent/$INTENT_ID.md"
if [ ! -f "$INTENT_FILE" ]; then
    error_exit "Intent file not found: $INTENT_FILE" 1
fi

WORKFLOW_DIR="workflow-state"
mkdir -p "$WORKFLOW_DIR"

echo -e "${BLUE}Orchestrating workflow for $INTENT_ID...${NC}"
echo ""

# Phase 1: Analysis
create_analysis() {
    echo -e "${YELLOW}[Phase 1] Creating analysis state...${NC}"
    
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

    echo -e "${GREEN}✓ Created $WORKFLOW_DIR/01_analysis.md${NC}"
}

# Phase 2: Planning
create_plan() {
    echo -e "${YELLOW}[Phase 2] Creating plan state...${NC}"
    
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

    echo -e "${GREEN}✓ Created $WORKFLOW_DIR/02_plan.md${NC}"
}

# Phase 3: Implementation
create_implementation() {
    echo -e "${YELLOW}[Phase 3] Creating implementation state...${NC}"
    
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

    echo -e "${GREEN}✓ Created $WORKFLOW_DIR/03_implementation.md${NC}"
}

# Phase 4: Verification
create_verification() {
    echo -e "${YELLOW}[Phase 4] Creating verification state...${NC}"
    
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

    echo -e "${GREEN}✓ Created $WORKFLOW_DIR/04_verification.md${NC}"

    # Backward compatibility: some docs/tests still look for 05_verification.md
    cat > "$WORKFLOW_DIR/05_verification.md" << EOF || error_exit "Failed to create legacy verification state"
# Verification (Legacy): $INTENT_ID

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Intent:** $INTENT_ID

This file is deprecated. Use `workflow-state/04_verification.md`.
EOF
}

# Phase 5: Release Notes
create_release() {
    echo -e "${YELLOW}[Phase 5] Creating release notes state...${NC}"
    
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

    echo -e "${GREEN}✓ Created $WORKFLOW_DIR/05_release_notes.md${NC}"
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
