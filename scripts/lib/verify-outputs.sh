#!/bin/bash

# Output Verification Library
# Provides functions to verify script outputs and display summaries

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verify a file exists
verify_file_exists() {
    local filepath="$1"
    local description="${2:-$(basename "$filepath")}"
    
    if [ -f "$filepath" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (missing)"
        return 1
    fi
}

# Verify intent files were created
verify_intent_files() {
    local count="${1:-0}"
    local pattern="${2:-F-*.md}"
    local intent_dir="${INTENT_DIR:-intent}"
    
    if [ $count -eq 0 ]; then
        return 0
    fi
    
    local actual_count=$(find "$intent_dir" -name "$pattern" ! -name "_TEMPLATE.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$actual_count" -ge "$count" ]; then
        echo -e "${GREEN}✓${NC} Generated $actual_count intent file(s)"
        return 0
    else
        echo -e "${RED}✗${NC} Expected $count intent file(s), found $actual_count"
        return 1
    fi
}

# Print summary header
print_summary_header() {
    local title="${1:-Summary}"
    echo ""
    echo -e "${YELLOW}$title${NC}"
    echo ""
}
