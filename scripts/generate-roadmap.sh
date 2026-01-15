#!/bin/bash

# Generate Project Roadmap from Intents
# Creates roadmap files and dependency visualization

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

INTENT_DIR="intent"
ROADMAP_DIR="roadmap"

if [ ! -d "$INTENT_DIR" ]; then
    error_exit "Intent directory not found: $INTENT_DIR" 1
fi

echo -e "${BLUE}Generating project roadmap...${NC}"

# Initialize roadmap files
mkdir -p "$ROADMAP_DIR"

# Extract intents and categorize
NOW_INTENTS=()
NEXT_INTENTS=()
LATER_INTENTS=()

for intent_file in "$INTENT_DIR"/*.md; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    
    # Skip template
    if [ "$INTENT_ID" = "_TEMPLATE" ]; then
        continue
    fi
    
    # Extract status and dependencies
    STATUS=$(grep "^## Status" "$intent_file" | head -1 | awk '{print $3}' || echo "planned")
    DEPENDENCIES=$(grep -A 10 "^## Dependencies" "$intent_file" | grep "^-" | sed 's/^- //' || echo "")
    
    # Simple categorization (can be enhanced)
    if [ "$STATUS" = "active" ] || [ "$STATUS" = "planned" ]; then
        if [ -z "$DEPENDENCIES" ]; then
            NOW_INTENTS+=("$INTENT_ID")
        else
            NEXT_INTENTS+=("$INTENT_ID")
        fi
    elif [ "$STATUS" = "blocked" ]; then
        NEXT_INTENTS+=("$INTENT_ID")
    else
        LATER_INTENTS+=("$INTENT_ID")
    fi
done

# Generate roadmap files
generate_roadmap_file() {
    local file="$1"
    local title="$2"
    local intents=("${@:3}")
    
    cat > "$file" << EOF || error_exit "Failed to create $file"
# $title

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Intents

EOF

    if [ ${#intents[@]} -eq 0 ]; then
        echo "(No intents yet. Add intents as they're planned.)" >> "$file"
    else
        for intent_id in "${intents[@]}"; do
            INTENT_FILE="$INTENT_DIR/$intent_id.md"
            if [ -f "$INTENT_FILE" ]; then
                TITLE=$(grep "^# " "$INTENT_FILE" | head -1 | sed 's/^# //' || echo "$intent_id")
                echo "- **$intent_id:** $TITLE" >> "$file"
            fi
        done
    fi
    
    echo "" >> "$file"
    echo "## Dependencies" >> "$file"
    echo "" >> "$file"
    echo "(Dependencies will be shown here)" >> "$file"
}

generate_roadmap_file "$ROADMAP_DIR/now.md" "Now (Current Sprint)" "${NOW_INTENTS[@]}"
generate_roadmap_file "$ROADMAP_DIR/next.md" "Next (Upcoming)" "${NEXT_INTENTS[@]}"
generate_roadmap_file "$ROADMAP_DIR/later.md" "Later (Backlog)" "${LATER_INTENTS[@]}"

echo -e "${GREEN}✓ Generated roadmap files${NC}"

# Generate dependency graph
DEPENDENCY_FILE="dependencies.md"
cat > "$DEPENDENCY_FILE" << EOF || error_exit "Failed to create dependency file"
# Feature Dependency Graph

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Dependency Graph

EOF

for intent_file in "$INTENT_DIR"/*.md; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    [ "$INTENT_ID" = "_TEMPLATE" ] && continue
    
    TITLE=$(grep "^# " "$intent_file" | head -1 | sed 's/^# //' || echo "$intent_id")
    DEPENDENCIES=$(grep -A 10 "^## Dependencies" "$intent_file" | grep "^-" | sed 's/^- //' || echo "")
    
    echo "### $INTENT_ID: $TITLE" >> "$DEPENDENCY_FILE"
    if [ -n "$DEPENDENCIES" ]; then
        echo "$DEPENDENCIES" | while read -r dep; do
            echo "  └─> $dep" >> "$DEPENDENCY_FILE"
        done
    else
        echo "  (no dependencies)" >> "$DEPENDENCY_FILE"
    fi
    echo "" >> "$DEPENDENCY_FILE"
done

echo -e "${GREEN}✓ Generated dependency graph: $DEPENDENCY_FILE${NC}"
echo ""
echo -e "${YELLOW}Roadmap generated:${NC}"
echo "  - $ROADMAP_DIR/now.md (${#NOW_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/next.md (${#NEXT_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/later.md (${#LATER_INTENTS[@]} intents)"
echo "  - $DEPENDENCY_FILE"
