#!/bin/bash

# Drift Metrics Check Script
# Calculates entropy indicators to detect system drift

set -euo pipefail

# Error handling
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Validate prerequisites
command -v git >/dev/null 2>&1 || error_exit "git is required but not installed"
command -v jq >/dev/null 2>&1 || error_exit "jq is required but not installed"
command -v bc >/dev/null 2>&1 || error_exit "bc is required but not installed"

DRIFT_DIR="drift"
METRICS_FILE="$DRIFT_DIR/metrics.md"

# Create drift directory if it doesn't exist
mkdir -p "$DRIFT_DIR" || error_exit "Failed to create drift directory"

# Start metrics report
cat > "$METRICS_FILE" << EOF
# Drift Metrics Report

Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

EOF

# 1. Average PR size (last 20 PRs)
echo "## PR Size Trend" >> "$METRICS_FILE" || error_exit "Failed to write to metrics file"
if git rev-parse --git-dir > /dev/null 2>&1; then
  PR_SIZE=$(git log --oneline -20 --stat 2>/dev/null | grep "files changed" | \
    awk '{sum+=$1; count++} END {if (count > 0) print "Avg files changed: " sum/count; else print "No PR data available"}' || echo "No PR data available")
  echo "$PR_SIZE" >> "$METRICS_FILE" || error_exit "Failed to write PR size data"
else
  echo "Not a git repository" >> "$METRICS_FILE" || error_exit "Failed to write git status"
fi
echo "" >> "$METRICS_FILE" || error_exit "Failed to write newline"

# 2. Test-to-code ratio
echo "## Test-to-Code Ratio" >> "$METRICS_FILE"
TEST_LINES=$(find . -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
CODE_LINES=$(find . -name "*.ts" ! -name "*.test.ts" ! -name "*.spec.ts" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
if [ "$CODE_LINES" -gt 0 ]; then
  RATIO=$(echo "scale=2; $TEST_LINES / $CODE_LINES" | bc 2>/dev/null || echo "N/A")
  echo "Test lines: $TEST_LINES" >> "$METRICS_FILE"
  echo "Code lines: $CODE_LINES" >> "$METRICS_FILE"
  echo "Ratio: $RATIO" >> "$METRICS_FILE"
else
  echo "No code found" >> "$METRICS_FILE"
fi
echo "" >> "$METRICS_FILE"

# 3. Dependency count
echo "## Dependency Growth" >> "$METRICS_FILE" || error_exit "Failed to write dependency section"
if [ -f "package.json" ]; then
  DEPS=$(jq '.dependencies | length' package.json 2>/dev/null || echo "N/A")
  DEV_DEPS=$(jq '.devDependencies | length' package.json 2>/dev/null || echo "N/A")
  echo "Dependencies: $DEPS" >> "$METRICS_FILE" || error_exit "Failed to write dependencies"
  echo "DevDependencies: $DEV_DEPS" >> "$METRICS_FILE" || error_exit "Failed to write devDependencies"
else
  echo "No package.json found" >> "$METRICS_FILE" || error_exit "Failed to write package.json status"
fi
echo "" >> "$METRICS_FILE" || error_exit "Failed to write newline"

# 4. New files without intents
echo "## Untracked New Concepts" >> "$METRICS_FILE"
if git rev-parse --git-dir > /dev/null 2>&1; then
  NEW_FILES=$(git diff --name-only HEAD~20 --diff-filter=A 2>/dev/null | grep -v "intent/" | head -10 || echo "No new files")
  echo "$NEW_FILES" >> "$METRICS_FILE"
else
  echo "Not a git repository" >> "$METRICS_FILE"
fi
echo "" >> "$METRICS_FILE"

# 5. CI Performance (placeholder)
echo "## CI Performance" >> "$METRICS_FILE"
echo "(Manually update from CI dashboard)" >> "$METRICS_FILE"
echo "" >> "$METRICS_FILE"

echo "Drift check complete. See $METRICS_FILE"
