#!/bin/bash

# AI-Assisted Project Scoping Script
# Breaks down project into features and generates initial intents

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

# Check if project.json exists
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

# Get project description
PROJECT_DESC="${1:-}"
if [ -z "$PROJECT_DESC" ]; then
    read -p "Project description: " PROJECT_DESC
    if [ -z "$PROJECT_DESC" ]; then
        error_exit "Project description is required" 1
    fi
fi

echo -e "${BLUE}Scoping project: $PROJECT_DESC${NC}"
echo ""

# Read project metadata
PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")
TECH_STACK=$(jq -r '.techStack' project.json 2>/dev/null || echo "typescript-nodejs")
HIGH_RISK=$(jq -r '.highRiskDomains | join(", ")' project.json 2>/dev/null || echo "none")

echo -e "${YELLOW}Project Context:${NC}"
echo "  Name: $PROJECT_NAME"
echo "  Tech Stack: $TECH_STACK"
echo "  High-Risk Domains: $HIGH_RISK"
echo ""

# Create project-scope.md
SCOPE_FILE="project-scope.md"
cat > "$SCOPE_FILE" << EOF || error_exit "Failed to create project-scope.md"
# Project Scope: $PROJECT_NAME

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Description:** $PROJECT_DESC

## AI Analysis

> **Note:** This is a template. In Cursor, use the \`/scope-project\` command to get AI-assisted scoping.

## Follow-Up Questions

[AI will ask targeted questions until scope is clear]

## Open Questions

[Unresolved questions that need human input]

## Feature Candidates

[AI will break down the project into features here]

## Dependency Graph

[AI will create dependency graph here]

## Architecture Suggestions

[AI will suggest architecture here]

## Risk Assessment

[AI will identify risks here]

## Intent Selection

[Which features were selected to generate intents]

## Generated Intents

[List of generated intent files]

---

*This file should be populated by running \`/scope-project\` in Cursor with AI assistance.*
EOF

echo -e "${GREEN}✓ Created $SCOPE_FILE${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. In Cursor, run: /scope-project \"$PROJECT_DESC\""
echo "2. AI will ask follow-up questions and populate $SCOPE_FILE"
echo "3. You will select which features to generate as intents"
echo "4. AI will generate selected intent files"
echo "5. Review and adjust as needed"
echo ""
