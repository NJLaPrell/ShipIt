#!/bin/bash

# Cursor Integration Validation Script
# Checks if Cursor recognizes .mdc files and slash commands

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

echo -e "${BLUE}Validating Cursor Integration...${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# Check 1: .mdc files exist
echo -e "${YELLOW}[1/6] Checking .mdc rule files...${NC}"
MDC_COUNT=$(find .cursor/rules -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
if [ "$MDC_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $MDC_COUNT .mdc rule files${NC}"
    PASSED=$((PASSED + 1))
    find .cursor/rules -name "*.mdc" | sed 's/^/  - /'
else
    echo -e "${RED}✗ No .mdc rule files found${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check 2: Slash commands exist
echo -e "${YELLOW}[2/6] Checking slash command files...${NC}"
CMD_COUNT=$(find .cursor/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CMD_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $CMD_COUNT slash command files${NC}"
    PASSED=$((PASSED + 1))
    find .cursor/commands -name "*.md" | sed 's/^/  - /'
else
    echo -e "${RED}✗ No slash command files found${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Check 3: Required commands exist
echo -e "${YELLOW}[3/6] Checking required commands...${NC}"
REQUIRED_CMDS=("ship.md" "new_intent.md" "init_project.md" "scope_project.md" "deploy.md" "verify.md" "kill.md" "drift_check.md")
MISSING=0
for cmd in "${REQUIRED_CMDS[@]}"; do
    if [ -f ".cursor/commands/$cmd" ]; then
        echo -e "  ${GREEN}✓${NC} $cmd"
    else
        echo -e "  ${RED}✗${NC} $cmd (missing)"
        MISSING=$((MISSING + 1))
    fi
done
if [ $MISSING -eq 0 ]; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi
echo ""

# Check 4: Required rules exist
echo -e "${YELLOW}[4/6] Checking required rule files...${NC}"
REQUIRED_RULES=("steward.mdc" "pm.mdc" "architect.mdc" "implementer.mdc" "qa.mdc" "security.mdc" "docs.mdc")
MISSING=0
for rule in "${REQUIRED_RULES[@]}"; do
    if [ -f ".cursor/rules/$rule" ]; then
        echo -e "  ${GREEN}✓${NC} $rule"
    else
        echo -e "  ${RED}✗${NC} $rule (missing)"
        MISSING=$((MISSING + 1))
    fi
done
if [ $MISSING -eq 0 ]; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi
echo ""

# Check 5: Scripts are executable
echo -e "${YELLOW}[5/6] Checking script executability...${NC}"
SCRIPTS=("init-project.sh" "scope-project.sh" "deploy.sh" "workflow-orchestrator.sh")
MISSING=0
for script in "${SCRIPTS[@]}"; do
    if [ -f "scripts/$script" ] && [ -x "scripts/$script" ]; then
        echo -e "  ${GREEN}✓${NC} $script"
    else
        echo -e "  ${YELLOW}⚠${NC} $script (not executable or missing)"
        MISSING=$((MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done
if [ $MISSING -eq 0 ]; then
    PASSED=$((PASSED + 1))
else
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check 6: Project structure
echo -e "${YELLOW}[6/6] Checking project structure...${NC}"
REQUIRED_DIRS=("intent" "workflow-state" "architecture" "scripts" ".cursor/rules" ".cursor/commands")
MISSING=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir/"
    else
        echo -e "  ${RED}✗${NC} $dir/ (missing)"
        MISSING=$((MISSING + 1))
    fi
done
if [ $MISSING -eq 0 ]; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo -e "${YELLOW}Manual Validation Required:${NC}"
    echo "1. Open Cursor and type '/' - verify commands appear"
    echo "2. Try /ship F-001 - verify command works"
    echo "3. Check if .mdc rules are recognized (Cursor may show them in settings)"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Fix issues above.${NC}"
    exit 1
fi
