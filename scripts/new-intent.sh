#!/bin/bash

# Automated Intent Creation Script
# Creates a new intent file from template with interactive prompts

set -euo pipefail

# Error handling
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

INTENT_BASE_DIR="work/intent"
TEMPLATE_FILE="$INTENT_BASE_DIR/_TEMPLATE.md"

# Validate prerequisites
if [ ! -f "$TEMPLATE_FILE" ]; then
    error_exit "Template file not found: $TEMPLATE_FILE"
fi

# Get intent type
echo -e "${YELLOW}Intent Type:${NC}"
echo "1) Feature (F-###)"
echo "2) Bug (B-###)"
echo "3) Tech Debt (T-###)"
read -p "Select type [1-3]: " type_choice

case $type_choice in
    1) INTENT_TYPE="feature"; PREFIX="F"; INTENT_DIR="$INTENT_BASE_DIR/features" ;;
    2) INTENT_TYPE="bug"; PREFIX="B"; INTENT_DIR="$INTENT_BASE_DIR/bugs" ;;
    3) INTENT_TYPE="tech-debt"; PREFIX="T"; INTENT_DIR="$INTENT_BASE_DIR/tech-debt" ;;
    *) error_exit "Invalid choice" 1 ;;
esac

mkdir -p "$INTENT_DIR"

# Get next intent number without overwriting existing files
LAST_INTENT=0
while IFS= read -r file; do
    [ -e "$file" ] || continue
    base="$(basename "$file")"
    if [[ "$base" =~ ^[FBT]-([0-9]+)\.md$ ]]; then
        num="${BASH_REMATCH[1]}"
        if ((10#$num > LAST_INTENT)); then
            LAST_INTENT=$((10#$num))
        fi
    fi
done < <(find "$INTENT_BASE_DIR" -type f -name '[FBT]-*.md' 2>/dev/null)
NEXT_NUM=$((LAST_INTENT + 1))
INTENT_ID="${PREFIX}-$(printf "%03d" $NEXT_NUM)"

# Get title
read -p "Title: " TITLE
if [ -z "$TITLE" ]; then
    error_exit "Title is required" 1
fi

# Get motivation
echo -e "${YELLOW}Motivation (press Enter after each line, type 'done' when finished):${NC}"
MOTIVATION=""
while IFS= read -r line; do
    [ "$line" = "done" ] && break
    MOTIVATION="${MOTIVATION}- ${line}\n"
done

# Get priority
echo -e "${YELLOW}Priority:${NC}"
echo "1) p0 (Critical)"
echo "2) p1 (High)"
echo "3) p2 (Medium)"
echo "4) p3 (Low)"
read -p "Select priority [1-4, default=2]: " priority_choice

case $priority_choice in
    1) PRIORITY="p0" ;;
    2) PRIORITY="p1" ;;
    3) PRIORITY="p2" ;;
    4) PRIORITY="p3" ;;
    *) PRIORITY="p2" ;;
esac

# Get effort
echo -e "${YELLOW}Effort:${NC}"
echo "1) Small (s)"
echo "2) Medium (m)"
echo "3) Large (l)"
read -p "Select effort [1-3, default=2]: " effort_choice

case $effort_choice in
    1) EFFORT="s" ;;
    2) EFFORT="m" ;;
    3) EFFORT="l" ;;
    *) EFFORT="m" ;;
esac

# Get release target
echo -e "${YELLOW}Release Target:${NC}"
echo "1) R1 (Next release)"
echo "2) R2 (Following release)"
echo "3) R3 (Future)"
echo "4) R4 (Backlog)"
read -p "Select release target [1-4, default=2]: " release_choice

case $release_choice in
    1) RELEASE_TARGET="R1" ;;
    2) RELEASE_TARGET="R2" ;;
    3) RELEASE_TARGET="R3" ;;
    4) RELEASE_TARGET="R4" ;;
    *) RELEASE_TARGET="R2" ;;
esac

# Get dependencies
echo -e "${YELLOW}Dependencies:${NC}"
echo "Enter intent IDs (e.g., F-001, F-002) or 'none' for no dependencies"
echo "Press Enter after each ID, type 'done' when finished:"
DEPENDENCIES=()
while IFS= read -r dep_line; do
    [ "$dep_line" = "done" ] && break
    [ -z "$dep_line" ] && continue
    if [ "$dep_line" = "none" ]; then
        DEPENDENCIES=()
        break
    fi
    # Validate format (F-###, B-###, T-###)
    if [[ "$dep_line" =~ ^[FBT]-[0-9]+$ ]]; then
        DEPENDENCIES+=("$dep_line")
    else
        echo -e "${RED}Invalid format. Use F-###, B-###, or T-###${NC}"
    fi
done

# Get risk level
echo -e "${YELLOW}Risk Level:${NC}"
echo "1) Low"
echo "2) Medium"
echo "3) High"
read -p "Select risk [1-3, default=1]: " risk_choice

case $risk_choice in
    1) RISK_LEVEL="low" ;;
    2) RISK_LEVEL="medium" ;;
    3) RISK_LEVEL="high" ;;
    *) RISK_LEVEL="low" ;;
esac

# Create intent file
INTENT_FILE="$INTENT_DIR/$INTENT_ID.md"
if [ -e "$INTENT_FILE" ]; then
    error_exit "Intent file already exists: $INTENT_FILE" 1
fi

# Read template and replace placeholders (portable across BSD/GNU sed)
TEMP_FILE="$(mktemp)"
MOTIVATION_FILE="$(mktemp)"

sed -e "s/# F-###: Title/# $INTENT_ID: $TITLE/" \
    -e "s/feature | bug | tech-debt/$INTENT_TYPE/" \
    -e "s/planned | active | blocked | validating | shipped | killed/planned/" \
    -e "s/p0 | p1 | p2 | p3/$PRIORITY/" \
    -e "s/s | m | l/$EFFORT/" \
    -e "s/R1 | R2 | R3 | R4/$RELEASE_TARGET/" \
    -e "s/low | medium | high/$RISK_LEVEL/" \
    "$TEMPLATE_FILE" > "$TEMP_FILE" || error_exit "Failed to create intent template"

printf "%b" "$MOTIVATION" | sed 's/^/  /' > "$MOTIVATION_FILE"

# Create dependencies file
DEP_FILE="$(mktemp)"
if [ ${#DEPENDENCIES[@]} -eq 0 ]; then
    echo "- (none)" > "$DEP_FILE"
else
    for dep in "${DEPENDENCIES[@]}"; do
        echo "- $dep" >> "$DEP_FILE"
    done
fi

awk -v motivation_file="$MOTIVATION_FILE" -v deps_file="$DEP_FILE" '
    $0 == "(Why it exists, 1–3 bullets)" {
        while ((getline line < motivation_file) > 0) print line;
        close(motivation_file);
        next;
    }
    /^- \(Other intent IDs that must ship first\)$/ {
        while ((getline line < deps_file) > 0) print line;
        close(deps_file);
        # Skip remaining placeholder dependency lines
        while (getline > 0) {
            if (/^## / || /^$/) {
                print;
                break;
            }
            # Skip placeholder lines (lines starting with "- (")
            if (!/^- \(/) {
                print;
            }
        }
        next;
    }
    { print }
' "$TEMP_FILE" > "$INTENT_FILE" || error_exit "Failed to create intent file"

rm -f "$TEMP_FILE" "$MOTIVATION_FILE" "$DEP_FILE"

echo -e "${GREEN}✓ Created intent: $INTENT_FILE${NC}"

# Refresh roadmap after creating a new intent (best effort)
if [ -x "./scripts/generate-roadmap.sh" ]; then
    echo -e "${YELLOW}Updating roadmap...${NC}"
    ./scripts/generate-roadmap.sh || echo "WARNING: roadmap generation failed"
fi

# Refresh release plan after creating a new intent (best effort)
if [ -x "./scripts/generate-release-plan.sh" ]; then
    echo -e "${YELLOW}Updating release plan...${NC}"
    ./scripts/generate-release-plan.sh || echo "WARNING: release plan generation failed"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Intent created successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Intent Details:${NC}"
echo "  ID: $INTENT_ID"
echo "  Title: $TITLE"
echo "  Type: $INTENT_TYPE"
echo "  Priority: $PRIORITY"
echo "  Effort: $EFFORT"
echo "  Release Target: $RELEASE_TARGET"
echo "  Risk Level: $RISK_LEVEL"
if [ ${#DEPENDENCIES[@]} -gt 0 ]; then
    echo "  Dependencies: ${DEPENDENCIES[*]}"
else
    echo "  Dependencies: (none)"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review $INTENT_FILE"
echo "2. Fill in acceptance criteria, invariants, and other details"
echo "3. Run: /ship $INTENT_ID"
