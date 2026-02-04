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

INTENT_DIR="work/intent"
ROADMAP_DIR="work/roadmap"

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

while IFS= read -r intent_file; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    
    # Skip template
    if [ "$INTENT_ID" = "_TEMPLATE" ]; then
        continue
    fi
    
    # Extract status (next non-empty line after header)
    STATUS=$(awk '
        $0 ~ /^## Status/ {found=1; next}
        found && $0 ~ /^## / {exit}
        found && $0 ~ /[^[:space:]]/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print tolower($0); exit}
    ' "$intent_file")
    [ -n "$STATUS" ] || STATUS="planned"

    # Extract dependencies (lines between header and next header)
    # Skip "None", "(none)", placeholder text in brackets, and empty lines
    DEPENDENCIES=$(awk '
        $0 ~ /^## Dependencies/ {found=1; next}
        found && $0 ~ /^## / {exit}
        found && $0 ~ /^[[:space:]]*- / {
            line=$0; sub(/^[[:space:]]*-[[:space:]]*/,"",line); gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            # Skip empty, "(none)", lines starting with "None", or placeholder brackets
            if (line == "" || line == "(none)" || tolower(line) ~ /^none/ || line ~ /^\[.*\]$/) next
            print line
        }
    ' "$intent_file")
    
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
done < <(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

# Generate roadmap files
generate_roadmap_file() {
    local file="$1"
    local title="$2"
    shift 2
    local intents=()
    if [ $# -gt 0 ]; then
        intents=("$@")
    fi
    
    cat > "$file" << EOF || error_exit "Failed to create $file"
# $title

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Intents

EOF

    if [ ${#intents[@]} -eq 0 ]; then
        echo "(No intents yet. Add intents as they're planned.)" >> "$file"
    else
        for intent_id in "${intents[@]}"; do
            INTENT_FILE=$(find "$INTENT_DIR" -type f -name "${intent_id}.md" -print -quit 2>/dev/null || true)
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

# Handle empty arrays safely (macOS bash + set -u workaround)
generate_roadmap_file "$ROADMAP_DIR/now.md" "Now (Current Sprint)" ${NOW_INTENTS[@]+"${NOW_INTENTS[@]}"}
generate_roadmap_file "$ROADMAP_DIR/next.md" "Next (Upcoming)" ${NEXT_INTENTS[@]+"${NEXT_INTENTS[@]}"}
generate_roadmap_file "$ROADMAP_DIR/later.md" "Later (Backlog)" ${LATER_INTENTS[@]+"${LATER_INTENTS[@]}"}

# Verify outputs and show summary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/verify-outputs.sh" ]; then
    source "$SCRIPT_DIR/lib/verify-outputs.sh"
    echo ""
    verify_file_exists "$ROADMAP_DIR/now.md" "Updated work/roadmap/now.md"
    verify_file_exists "$ROADMAP_DIR/next.md" "Updated work/roadmap/next.md"
    verify_file_exists "$ROADMAP_DIR/later.md" "Updated work/roadmap/later.md"
    
    # Count intents in each roadmap
    now_count=$(grep -c "^\*\*" "$ROADMAP_DIR/now.md" 2>/dev/null || echo "0")
    next_count=$(grep -c "^\*\*" "$ROADMAP_DIR/next.md" 2>/dev/null || echo "0")
    later_count=$(grep -c "^\*\*" "$ROADMAP_DIR/later.md" 2>/dev/null || echo "0")
    echo -e "${GREEN}✓${NC} Roadmap: $now_count in Now, $next_count in Next, $later_count in Later"
    
    # Show next-step suggestions
    if [ -f "$SCRIPT_DIR/lib/suggest-next.sh" ]; then
        source "$SCRIPT_DIR/lib/suggest-next.sh"
        display_suggestions "roadmap"
    fi
else
    echo -e "${GREEN}✓ Generated roadmap files${NC}"
fi

# Generate dependency graph
mkdir -p _system/artifacts
DEPENDENCY_FILE="_system/artifacts/dependencies.md"
cat > "$DEPENDENCY_FILE" << EOF || error_exit "Failed to create dependency file"
# Feature Dependency Graph

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Dependency Graph

EOF

while IFS= read -r intent_file; do
    [ -f "$intent_file" ] || continue
    
    INTENT_ID=$(basename "$intent_file" .md)
    [ "$INTENT_ID" = "_TEMPLATE" ] && continue
    
    TITLE=$(grep "^# " "$intent_file" | head -1 | sed 's/^# //' || echo "$intent_id")
    DEPENDENCIES=$(awk '
        $0 ~ /^## Dependencies/ {found=1; next}
        found && $0 ~ /^## / {exit}
        found && $0 ~ /^[[:space:]]*- / {line=$0; sub(/^[[:space:]]*-[[:space:]]*/,"",line); gsub(/^[[:space:]]+|[[:space:]]+$/, "", line); if (line != "" && line != "(none)") print line}
    ' "$intent_file")
    
    echo "### $INTENT_ID: $TITLE" >> "$DEPENDENCY_FILE"
    if [ -n "$DEPENDENCIES" ]; then
        echo "$DEPENDENCIES" | while read -r dep; do
            echo "  └─> $dep" >> "$DEPENDENCY_FILE"
        done
    else
        echo "  (no dependencies)" >> "$DEPENDENCY_FILE"
    fi
    echo "" >> "$DEPENDENCY_FILE"
done < <(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)

echo -e "${GREEN}✓ Generated dependency graph: $DEPENDENCY_FILE${NC}"
echo ""
echo -e "${YELLOW}Roadmap generated:${NC}"
echo "  - $ROADMAP_DIR/now.md (${#NOW_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/next.md (${#NEXT_INTENTS[@]} intents)"
echo "  - $ROADMAP_DIR/later.md (${#LATER_INTENTS[@]} intents)"
echo "  - $DEPENDENCY_FILE"
