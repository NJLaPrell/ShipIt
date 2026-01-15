#!/bin/bash

# Validate project.json against schema

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

PROJECT_FILE="${1:-project.json}"

if [ ! -f "$PROJECT_FILE" ]; then
    error_exit "Project file not found: $PROJECT_FILE" 1
fi

# Basic validation (check required fields)
echo "Validating $PROJECT_FILE..."

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    echo "WARNING: jq not found, performing basic validation only"
    
    # Basic checks
    if ! grep -q '"name"' "$PROJECT_FILE"; then
        error_exit "Missing required field: name" 1
    fi
    
    if ! grep -q '"version"' "$PROJECT_FILE"; then
        error_exit "Missing required field: version" 1
    fi
    
    if ! grep -q '"techStack"' "$PROJECT_FILE"; then
        error_exit "Missing required field: techStack" 1
    fi
    
    echo "✓ Basic validation passed"
    exit 0
fi

# Advanced validation with jq
REQUIRED_FIELDS=("name" "version" "techStack" "created")

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$PROJECT_FILE" >/dev/null 2>&1; then
        error_exit "Missing required field: $field" 1
    fi
done

# Validate techStack enum
TECH_STACK=$(jq -r '.techStack' "$PROJECT_FILE")
if [[ ! "$TECH_STACK" =~ ^(typescript-nodejs|python|other)$ ]]; then
    error_exit "Invalid techStack: $TECH_STACK (must be typescript-nodejs, python, or other)" 1
fi

# Validate version format
VERSION=$(jq -r '.version' "$PROJECT_FILE")
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Invalid version format: $VERSION (must be semantic version like 0.1.0)" 1
fi

# Validate settings if present
if jq -e '.settings' "$PROJECT_FILE" >/dev/null 2>&1; then
    CONFIDENCE=$(jq -r '.settings.confidenceThreshold // 0.7' "$PROJECT_FILE")
    if (( $(echo "$CONFIDENCE < 0 || $CONFIDENCE > 1" | bc -l) )); then
        error_exit "Invalid confidenceThreshold: $CONFIDENCE (must be 0.0-1.0)" 1
    fi
fi

echo "✓ Validation passed: $PROJECT_FILE"
