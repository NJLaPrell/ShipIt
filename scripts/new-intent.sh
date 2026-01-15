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

INTENT_DIR="intent"
TEMPLATE_FILE="$INTENT_DIR/_TEMPLATE.md"

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
    1) INTENT_TYPE="feature"; PREFIX="F" ;;
    2) INTENT_TYPE="bug"; PREFIX="B" ;;
    3) INTENT_TYPE="tech-debt"; PREFIX="T" ;;
    *) error_exit "Invalid choice" 1 ;;
esac

# Get next intent number
LAST_INTENT=$(ls -1 "$INTENT_DIR"/*.md 2>/dev/null | grep -E "^-?[FBT]-[0-9]+\.md$" | sed 's/.*\([FBT]-\([0-9]*\)\)\.md/\2/' | sort -n | tail -1 || echo "0")
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

# Get risk level
echo -e "${YELLOW}Risk Level:${NC}"
echo "1) Low"
echo "2) Medium"
echo "3) High"
read -p "Select risk [1-3]: " risk_choice

case $risk_choice in
    1) RISK_LEVEL="low" ;;
    2) RISK_LEVEL="medium" ;;
    3) RISK_LEVEL="high" ;;
    *) RISK_LEVEL="low" ;;
esac

# Create intent file
INTENT_FILE="$INTENT_DIR/$INTENT_ID.md"

# Read template and replace placeholders
sed -e "s/# F-###: Title/# $INTENT_ID: $TITLE/" \
    -e "s/feature | bug | tech-debt/$INTENT_TYPE/" \
    -e "s/planned | active | blocked | validating | shipped | killed/planned/" \
    -e "/## Motivation/,/^$/c\\
## Motivation\\
$(echo -e "$MOTIVATION" | sed 's/^/  /')
" \
    -e "s/low | medium | high/$RISK_LEVEL/" \
    "$TEMPLATE_FILE" > "$INTENT_FILE" || error_exit "Failed to create intent file"

echo -e "${GREEN}✓ Created intent: $INTENT_FILE${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit $INTENT_FILE to fill in acceptance criteria, invariants, etc."
echo "2. Run: /ship $INTENT_ID"
