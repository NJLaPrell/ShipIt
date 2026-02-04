#!/bin/bash

# Generate Project Context Script
# Creates PROJECT_CONTEXT.md with project state summary

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

CONTEXT_FILE="PROJECT_CONTEXT.md"

echo -e "${BLUE}Generating project context...${NC}"

# Check prerequisites
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")
PROJECT_DESC=$(jq -r '.description' project.json 2>/dev/null || echo "Project description")
TECH_STACK=$(jq -r '.techStack' project.json 2>/dev/null || echo "unknown")

# Count intents
intent_files=()
while IFS= read -r file; do
    intent_files+=("$file")
done < <(find intent -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

INTENT_COUNT=${#intent_files[@]}

# Count active intents
if [ "$INTENT_COUNT" -gt 0 ]; then
    ACTIVE_COUNT=$(grep -l "Status.*active" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
    COMPLETED_COUNT=$(grep -l "Status.*shipped" "${intent_files[@]}" 2>/dev/null | wc -l | tr -d ' ')
else
    ACTIVE_COUNT=0
    COMPLETED_COUNT=0
fi

# Get active intent
ACTIVE_INTENT=$(grep -h "^## Status" work/workflow-state/active.md 2>/dev/null | grep -o "F-[0-9]*\|B-[0-9]*\|T-[0-9]*" | head -1 || echo "none")

# Generate context file
cat > "$CONTEXT_FILE" << EOF || error_exit "Failed to generate PROJECT_CONTEXT.md"
# Project Context: $PROJECT_NAME

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Last Updated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Project Overview

- **Name:** $PROJECT_NAME
- **Description:** $PROJECT_DESC
- **Tech Stack:** $TECH_STACK
- **Status:** Active

## Intent Summary

- **Total Intents:** $INTENT_COUNT
- **Active:** $ACTIVE_COUNT
- **Completed:** $COMPLETED_COUNT
- **Pending:** $((INTENT_COUNT - ACTIVE_COUNT - COMPLETED_COUNT))

## Current Work

- **Active Intent:** $ACTIVE_INTENT

## Project Structure

\`\`\`
.
├── work/intent/         # $INTENT_COUNT intents
│   ├── features/        # Feature intents (F-###.md)
│   ├── bugs/            # Bug intents (B-###.md)
│   └── tech-debt/       # Tech-debt intents (T-###.md)
├── work/workflow-state/ # Current execution state
├── _system/architecture/ # System boundaries
├── src/                 # Source code
├── tests/               # Test files
└── ...
\`\`\`

## Recent Activity

[Auto-generated from git history]

## Key Decisions

[Architectural decisions and ADRs]

## Risks & Blockers

[Current risks and blockers]

## Next Steps

[Planned next steps]

---

*This file is auto-generated. Update source files to change content.*
EOF

echo -e "${GREEN}✓ Generated $CONTEXT_FILE${NC}"

# Update project history if git is available
if git rev-parse --git-dir > /dev/null 2>&1; then
    HISTORY_FILE="project-history.md"
    if [ ! -f "$HISTORY_FILE" ]; then
        cat > "$HISTORY_FILE" << EOF || error_exit "Failed to create project history"
# Project History

## Timeline

EOF
    fi
    
    # Add recent commits
    RECENT_COMMITS=$(git log --oneline -10 --format="%h - %s (%ar)" 2>/dev/null || echo "No git history")
    
    cat >> "$HISTORY_FILE" << EOF || true

### $(date -u +"%Y-%m-%d")

Recent commits:
$RECENT_COMMITS
EOF

    echo -e "${GREEN}✓ Updated project history${NC}"
fi

echo ""
echo -e "${GREEN}Project context generated successfully${NC}"
