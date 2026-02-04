#!/bin/bash

# Intent Validation Library
# Provides functions to validate intent files for common issues

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

INTENT_DIR="${INTENT_DIR:-work/intent}"

# Parse intent file and return structured data
parse_intent() {
    local intent_file="$1"
    local id=$(basename "$intent_file" .md)
    
    # Extract release target
    local release_target=$(awk '
        /^## Release Target/ {
            found=1
            # Check inline format "## Release Target: R1"
            if (match($0, /R[0-9]+/)) {
                print substr($0, RSTART, RLENGTH)
                exit
            }
            next
        }
        found && /^## / { exit }
        found && /R[0-9]+/ {
            # Skip template lines like "R1 | R2 | R3"
            if (!/\|/) {
                match($0, /R[0-9]+/)
                if (RSTART > 0) {
                    print substr($0, RSTART, RLENGTH)
                    exit
                }
            }
        }
    ' "$intent_file" | head -1)
    
    # Extract dependencies (normalize to uppercase, remove whitespace issues)
    local deps=$(awk '
        /^## Dependencies/ { found=1; next }
        found && /^## / { exit }
        found && /^- / {
            line=$0
            sub(/^[[:space:]]*-[[:space:]]*/, "", line)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            # Skip empty, "(none)", "None", or placeholder brackets
            if (line == "" || line == "(none)" || tolower(line) ~ /^none/ || line ~ /^\[.*\]$/) next
            # Extract intent ID (F-001, B-002, etc.)
            if (match(line, /^[A-Z]-[0-9]+/)) {
                print toupper(substr(line, RSTART, RLENGTH))
            }
        }
    ' "$intent_file")
    
    echo "$id|$release_target|$deps"
}

# Check dependency ordering conflicts
# Returns: issue_type|intent_id|message|fix_suggestion
check_dependency_ordering() {
    local intent_file="$1"
    local intent_data=$(parse_intent "$intent_file")
    local intent_id=$(echo "$intent_data" | cut -d'|' -f1)
    local release_target=$(echo "$intent_data" | cut -d'|' -f2)
    local deps=$(echo "$intent_data" | cut -d'|' -f3- | tr ' ' '\n' | grep -v '^$')
    
    if [ -z "$release_target" ] || [ -z "$deps" ]; then
        return 0  # No issue if no release target or dependencies
    fi
    
    # Extract numeric release number, validate format
    local release_num=$(echo "$release_target" | sed 's/R//')
    if [ -z "$release_num" ] || ! [[ "$release_num" =~ ^[0-9]+$ ]]; then
        return 0  # Invalid release format, skip check
    fi
    
    while IFS= read -r dep; do
        [ -z "$dep" ] && continue
        
        local dep_file=$(find "$INTENT_DIR" -type f -name "${dep}.md" -print -quit 2>/dev/null)
        if [ -z "$dep_file" ] || [ ! -f "$dep_file" ]; then
            continue  # Missing deps handled separately
        fi
        
        local dep_data=$(parse_intent "$dep_file")
        local dep_release=$(echo "$dep_data" | cut -d'|' -f2)
        
        if [ -z "$dep_release" ]; then
            continue  # Dependency has no release target
        fi
        
        local dep_release_num=$(echo "$dep_release" | sed 's/R//')
        if [ -z "$dep_release_num" ] || ! [[ "$dep_release_num" =~ ^[0-9]+$ ]]; then
            continue  # Invalid release format, skip
        fi
        
        # Issue: dependency is in later release than dependent
        if [ "$dep_release_num" -gt "$release_num" ]; then
            echo "dependency_ordering|$intent_id|$intent_id depends on $dep, but $dep is in $dep_release while $intent_id is in $release_target|Move $dep to $release_target or earlier, or move $intent_id to $dep_release or later"
            return 1
        fi
    done <<< "$deps"
    
    return 0
}

# Check whitespace formatting in dependencies
check_whitespace() {
    local intent_file="$1"
    local intent_data=$(parse_intent "$intent_file")
    local intent_id=$(echo "$intent_data" | cut -d'|' -f1)
    
    # Check if dependency lines have leading whitespace
    if awk '
        /^## Dependencies/ { found=1; next }
        found && /^## / { exit }
        found && /^[[:space:]]+- / {
            # Line has leading whitespace before "- "
            exit 1
        }
    ' "$intent_file"; then
        return 0  # No whitespace issues
    else
        echo "whitespace|$intent_id|Dependency lines have leading whitespace|Normalize dependency lines to start at column 0"
        return 1
    fi
}

# Check for missing dependencies
check_missing_dependencies() {
    local intent_file="$1"
    local intent_data=$(parse_intent "$intent_file")
    local intent_id=$(echo "$intent_data" | cut -d'|' -f1)
    local deps=$(echo "$intent_data" | cut -d'|' -f3- | tr ' ' '\n' | grep -v '^$')
    
    local missing=()
    while IFS= read -r dep; do
        [ -z "$dep" ] && continue
        
        local dep_file=$(find "$INTENT_DIR" -type f -name "${dep}.md" -print -quit 2>/dev/null)
        if [ -z "$dep_file" ] || [ ! -f "$dep_file" ]; then
            missing+=("$dep")
        fi
    done <<< "$deps"
    
    if [ ${#missing[@]} -gt 0 ]; then
        local missing_list=$(IFS=','; echo "${missing[*]}")
        echo "missing_dependency|$intent_id|Missing dependencies: $missing_list|Create intent files for missing dependencies or remove from dependency list"
        return 1
    fi
    
    return 0
}

# Check for circular dependencies (simple check - direct cycles only)
check_circular_dependencies() {
    local intent_file="$1"
    local intent_data=$(parse_intent "$intent_file")
    local intent_id=$(echo "$intent_data" | cut -d'|' -f1)
    local deps=$(echo "$intent_data" | cut -d'|' -f3- | tr ' ' '\n' | grep -v '^$')
    
    while IFS= read -r dep; do
        [ -z "$dep" ] && continue
        
        local dep_file=$(find "$INTENT_DIR" -type f -name "${dep}.md" -print -quit 2>/dev/null)
        if [ -z "$dep_file" ] || [ ! -f "$dep_file" ]; then
            continue
        fi
        
        local dep_data=$(parse_intent "$dep_file")
        local dep_deps=$(echo "$dep_data" | cut -d'|' -f3- | tr ' ' '\n' | grep -v '^$')
        
        # Check if dependency depends back on this intent
        if echo "$dep_deps" | grep -q "^$intent_id$"; then
            echo "circular|$intent_id|Circular dependency detected: $intent_id <-> $dep|Remove circular dependency from either $intent_id or $dep"
            return 1
        fi
    done <<< "$deps"
    
    return 0
}

# Run all validations on an intent file
# Returns: list of issues (one per line) in format: issue_type|intent_id|message|fix_suggestion
validate_intent() {
    local intent_file="$1"
    local issues=()
    
    # Run all checks
    local ordering_issue=$(check_dependency_ordering "$intent_file" || true)
    local whitespace_issue=$(check_whitespace "$intent_file" || true)
    local missing_issue=$(check_missing_dependencies "$intent_file" || true)
    local circular_issue=$(check_circular_dependencies "$intent_file" || true)
    
    # Collect all issues
    [ -n "$ordering_issue" ] && issues+=("$ordering_issue")
    [ -n "$whitespace_issue" ] && issues+=("$whitespace_issue")
    [ -n "$missing_issue" ] && issues+=("$missing_issue")
    [ -n "$circular_issue" ] && issues+=("$circular_issue")
    
    # Print all issues (one per line)
    for issue in "${issues[@]}"; do
        echo "$issue"
    done
    
    return ${#issues[@]}  # Return number of issues
}

# Validate all intents
validate_all_intents() {
    local total_issues=0
    local intent_files=()
    
    # Find all intent files recursively
    intent_files=()
    while IFS= read -r file; do
        intent_files+=("$file")
    done < <(find "$INTENT_DIR" -type f -name "*.md" ! -name "_TEMPLATE.md" 2>/dev/null)
    
    if [ ${#intent_files[@]} -eq 0 ]; then
        return 0
    fi
    
    # Validate each intent
    for intent_file in "${intent_files[@]}"; do
        validate_intent "$intent_file" || {
            local count=$?
            total_issues=$((total_issues + count))
        }
    done
    
    return $total_issues
}
