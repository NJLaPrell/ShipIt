#!/bin/bash

# Fix Intent Issues Script
# Detects and auto-fixes common intent issues

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
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source validation library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validate-intents.sh" || error_exit "Failed to load validation library" 1

INTENT_DIR="${INTENT_DIR:-intent}"

# Fix whitespace issues in dependencies
fix_whitespace() {
    local intent_file="$1"
    local temp_file=$(mktemp)
    
    if ! awk '
        BEGIN { in_deps=0 }
        /^## Dependencies/ {
            in_deps=1
            print
            next
        }
        in_deps && /^## / {
            in_deps=0
            print
            next
        }
        in_deps && /^[[:space:]]+- / {
            # Remove leading whitespace
            sub(/^[[:space:]]+/, "")
            print
            next
        }
        { print }
    ' "$intent_file" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    mv "$temp_file" "$intent_file"
    echo "✓ Fixed whitespace in $(basename "$intent_file")"
}

# Fix dependency ordering by moving dependency to same/earlier release
fix_dependency_ordering() {
    local intent_id="$1"
    local dep_id="$2"
    local intent_release="$3"
    
    local dep_file="$INTENT_DIR/$dep_id.md"
    if [ ! -f "$dep_file" ]; then
        warning "Cannot fix: $dep_id file not found"
        return 1
    fi
    
    # Update dependency's release target to match or be earlier than dependent's release
    local temp_file=$(mktemp)
    if ! awk -v target_release="$intent_release" '
        BEGIN { in_release=0; release_set=0 }
        /^## Release Target/ {
            in_release=1
            # Check if inline format
            if (match($0, /R[0-9]+/)) {
                current_release = substr($0, RSTART, RLENGTH)
                current_num = substr(current_release, 2)
                target_num = substr(target_release, 2)
                if (current_num > target_num) {
                    # Replace with target release
                    sub(/R[0-9]+/, target_release)
                    release_set=1
                }
                print
                next
            }
            print
            next
        }
        in_release && /^## / {
            if (!release_set) {
                # Release target not set yet, add it
                print target_release
                release_set=1
            }
            in_release=0
            print
            next
        }
        in_release && /R[0-9]+/ {
            if (!/\|/) {  # Not a template line
                if (match($0, /R[0-9]+/)) {
                    current_release = substr($0, RSTART, RLENGTH)
                    current_num = substr(current_release, 2)
                    target_num = substr(target_release, 2)
                    if (current_num > target_num) {
                        # Replace with target release
                        sub(/R[0-9]+/, target_release)
                        release_set=1
                    }
                }
            }
            print
            next
        }
        { print }
        END {
            if (in_release && !release_set) {
                print target_release
            }
        }
    ' "$dep_file" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    mv "$temp_file" "$dep_file"
    echo "✓ Moved $dep_id to $intent_release (to satisfy $intent_id dependency)"
}

# Main fix function
main() {
    echo -e "${BLUE}Scanning for intent issues...${NC}"
    echo ""
    
    # Collect all issues
    local all_issues=()
    local intent_files=()
    
    # Find all intent files
    for file in "$INTENT_DIR"/*.md; do
        [ -f "$file" ] || continue
        [ "$(basename "$file")" = "_TEMPLATE.md" ] && continue
        intent_files+=("$file")
    done
    
    if [ ${#intent_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ No intent files found${NC}"
        return 0
    fi
    
    # Validate all intents and collect issues
    for intent_file in "${intent_files[@]}"; do
        while IFS= read -r issue; do
            [ -n "$issue" ] && all_issues+=("$issue")
        done < <(validate_intent "$intent_file" || true)
    done
    
    if [ ${#all_issues[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ No issues found${NC}"
        return 0
    fi
    
    # Display issues
    echo -e "${YELLOW}Found ${#all_issues[@]} issue(s):${NC}"
    echo ""
    
    local i=1
    for issue in "${all_issues[@]}"; do
        local issue_type=$(echo "$issue" | cut -d'|' -f1)
        local intent_id=$(echo "$issue" | cut -d'|' -f2)
        local message=$(echo "$issue" | cut -d'|' -f3)
        local fix_suggestion=$(echo "$issue" | cut -d'|' -f4)
        
        echo -e "${YELLOW}[$i]${NC} $intent_id: $message"
        echo "    Fix: $fix_suggestion"
        echo ""
        i=$((i + 1))
    done
    
    # Ask for confirmation
    echo -e "${BLUE}Apply fixes? (y/n):${NC} "
    read -r response
    
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        echo "Cancelled."
        return 0
    fi
    
    echo ""
    echo -e "${BLUE}Applying fixes...${NC}"
    echo ""
    
    # Apply fixes
    local fixed_count=0
    for issue in "${all_issues[@]}"; do
        local issue_type=$(echo "$issue" | cut -d'|' -f1)
        local intent_id=$(echo "$issue" | cut -d'|' -f2)
        local intent_file="$INTENT_DIR/$intent_id.md"
        
        case "$issue_type" in
            whitespace)
                fix_whitespace "$intent_file"
                fixed_count=$((fixed_count + 1))
                ;;
            dependency_ordering)
                # Extract dependency ID from message
                local dep_id=$(echo "$issue" | grep -o '[A-Z]-[0-9]*' | head -2 | tail -1)
                local intent_release=$(echo "$issue" | grep -o 'R[0-9]*' | head -1)
                if [ -n "$dep_id" ] && [ -n "$intent_release" ]; then
                    fix_dependency_ordering "$intent_id" "$dep_id" "$intent_release"
                    fixed_count=$((fixed_count + 1))
                fi
                ;;
            missing_dependency|circular)
                echo -e "${YELLOW}⚠ Skipping $issue_type issue (requires manual intervention)${NC}"
                ;;
        esac
    done
    
    echo ""
    if [ $fixed_count -gt 0 ]; then
        echo -e "${GREEN}✓ Fixed $fixed_count issue(s)${NC}"
    else
        echo -e "${YELLOW}No automatic fixes applied${NC}"
    fi
}

main "$@"
