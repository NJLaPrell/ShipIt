#!/bin/bash

# Progress Indicator Library
# Provides functions to display progress for long-running operations

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Show phase progress
# Usage: show_phase_progress phase_num total_phases phase_name status
# Status: "running", "complete", "pending"
show_phase_progress() {
    local phase_num="$1"
    local total_phases="$2"
    local phase_name="$3"
    local status="${4:-running}"
    
    case "$status" in
        complete)
            echo -e "[Phase $phase_num/$total_phases] $phase_name... ${GREEN}✓${NC}"
            ;;
        running)
            echo -e "[Phase $phase_num/$total_phases] $phase_name... ${YELLOW}⏳${NC}"
            ;;
        pending)
            echo -e "[Phase $phase_num/$total_phases] $phase_name... ${CYAN}○${NC}"
            ;;
    esac
}

# Show subtask progress
# Usage: show_subtask task_num total_tasks task_name
show_subtask_progress() {
    local task_num="$1"
    local total_tasks="$2"
    local task_name="$3"
    
    echo -e "  ${BLUE}→${NC} [$task_num/$total_tasks] $task_name"
}

# Update progress in place (overwrite same line)
# Usage: update_progress_line "message"
update_progress_line() {
    local message="$1"
    echo -ne "\r\033[K$message"
}

# Complete progress line (move to next line)
complete_progress_line() {
    echo ""
}
