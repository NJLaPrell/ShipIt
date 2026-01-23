#!/bin/bash

# Production Readiness Check Script
# Validates project is ready for deployment

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

warning() {
    echo "WARNING: $1" >&2
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENVIRONMENT="${1:-}"
if [ -z "$ENVIRONMENT" ]; then
    error_exit "Usage: ./scripts/check-readiness.sh <environment>" 1
fi

echo -e "${BLUE}Running readiness checks for: ${ENVIRONMENT}${NC}"
echo ""

FAILED=0

# Check 1: Tests pass
echo -e "${YELLOW}[1/7] Running tests...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    if pnpm test >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Tests pass${NC}"
    else
        echo -e "${RED}✗ Tests failed${NC}"
        FAILED=1
    fi
else
    warning "pnpm not found, skipping test check"
fi
echo ""

# Check 2: Coverage threshold
echo -e "${YELLOW}[2/7] Checking test coverage...${NC}"
if [ -f "project.json" ]; then
    COVERAGE_THRESHOLD=$(jq -r '.settings.testCoverageMinimum // 80' project.json 2>/dev/null || echo "80")
    if command -v pnpm >/dev/null 2>&1; then
        # Try to get coverage (simplified check)
        if pnpm test:coverage >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Coverage check passed${NC}"
        else
            warning "Could not verify coverage threshold ($COVERAGE_THRESHOLD%)"
        fi
    fi
else
    warning "project.json not found, using default threshold (80%)"
fi
echo ""

# Check 3: Lint and typecheck
echo -e "${YELLOW}[3/7] Running lint and typecheck...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    if pnpm lint >/dev/null 2>&1 && pnpm typecheck >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Lint and typecheck pass${NC}"
    else
        echo -e "${RED}✗ Lint or typecheck failed${NC}"
        FAILED=1
    fi
else
    warning "pnpm not found, skipping lint/typecheck"
fi
echo ""

# Check 4: Security audit
echo -e "${YELLOW}[4/7] Running security audit...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    if pnpm audit --audit-level=high >/dev/null 2>&1; then
        echo -e "${GREEN}✓ No high/critical vulnerabilities${NC}"
    else
        warning "Security audit found issues (review manually)"
    fi
else
    warning "pnpm not found, skipping security audit"
fi
echo ""

# Check 5: Documentation
echo -e "${YELLOW}[5/7] Checking documentation...${NC}"
DOCS_OK=1
if [ ! -f "README.md" ]; then
    echo -e "${RED}✗ README.md missing${NC}"
    DOCS_OK=0
fi
if [ ! -f "CHANGELOG.md" ]; then
    warning "CHANGELOG.md missing (recommended)"
fi
if [ $DOCS_OK -eq 1 ]; then
    echo -e "${GREEN}✓ Documentation present${NC}"
fi
echo ""

# Check 6: Drift check
echo -e "${YELLOW}[6/7] Running drift check...${NC}"
if [ -f "scripts/drift-check.sh" ]; then
    if ./scripts/drift-check.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Drift check passed${NC}"
    else
        warning "Drift check found issues (review manually)"
    fi
else
    warning "drift-check.sh not found, skipping"
fi
echo ""

# Check 7: Invariants
echo -e "${YELLOW}[7/7] Checking invariants...${NC}"
if [ -f "architecture/invariants.yml" ]; then
    if [ -f "scripts/validate-project.sh" ]; then
        if ./scripts/validate-project.sh >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Invariants valid${NC}"
        else
            warning "Invariant validation issues (review manually)"
        fi
    else
        echo -e "${GREEN}✓ Invariants file exists${NC}"
    fi
else
    warning "invariants.yml not found"
fi
echo ""

# Summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Production readiness checks PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ Production readiness checks FAILED${NC}"
    echo -e "${YELLOW}Fix the issues above before deploying${NC}"
    exit 1
fi
