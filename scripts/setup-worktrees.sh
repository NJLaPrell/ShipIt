#!/bin/bash

# Setup Parallel Worktrees Script
# Creates isolated worktrees for parallel agent work

set -euo pipefail

# Error handling
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Validate prerequisites
command -v git >/dev/null 2>&1 || error_exit "git is required but not installed"

# Validate inputs
INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: $0 <intent-id> [task-count]" 1
fi

TASK_COUNT="${2:-3}"
if ! [[ "$TASK_COUNT" =~ ^[0-9]+$ ]] || [ "$TASK_COUNT" -lt 1 ] || [ "$TASK_COUNT" -gt 10 ]; then
    error_exit "Task count must be between 1 and 10" 1
fi

BASE_DIR="$(pwd)"
WORKTREE_BASE="../worktree"

# Validate we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error_exit "Not a git repository. Run this from the repository root." 1
fi

echo "Setting up $TASK_COUNT worktrees for intent $INTENT_ID"

# Create worktrees.json
WORKTREES_FILE="worktrees.json"
if [ -f "$WORKTREES_FILE" ]; then
    echo "WARNING: $WORKTREES_FILE already exists. Backing up to ${WORKTREES_FILE}.bak"
    cp "$WORKTREES_FILE" "${WORKTREES_FILE}.bak" || error_exit "Failed to backup existing worktrees.json"
fi

cat > "$WORKTREES_FILE" << EOF || error_exit "Failed to create worktrees.json"
{
  "intent_id": "$INTENT_ID",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tasks": [
EOF

for i in $(seq 1 $TASK_COUNT); do
  WORKTREE_DIR="$WORKTREE_BASE-$i"
  BRANCH="feature/$INTENT_ID-task-$i"
  
  echo "Creating worktree $i: $WORKTREE_DIR"
  
  # Check if worktree already exists
  if [ -d "$WORKTREE_DIR" ]; then
    echo "WARNING: Worktree $i already exists at $WORKTREE_DIR. Skipping..."
    continue
  fi
  
  # Create worktree
  if ! git worktree add "$WORKTREE_DIR" -b "$BRANCH" 2>/dev/null; then
    echo "ERROR: Failed to create worktree $i. Branch $BRANCH may already exist."
    echo "Try: git branch -D $BRANCH (if safe to delete)"
    continue
  fi
  
  # Create .agent-id file with unique integer per worktree
  if ! echo "$i" > "$WORKTREE_DIR/.agent-id"; then
    error_exit "Failed to create .agent-id in worktree $i"
  fi
  
  # Register agent in coordination system
  if [ -f "scripts/agent-coordinator.sh" ]; then
    AGENT_ID="agent-$i"
    # Agent will be registered when first task is assigned
  fi
  
  # Add to worktrees.json
  if [ $i -gt 1 ]; then
    echo "," >> worktrees.json
  fi
  cat >> worktrees.json << EOF
    {
      "id": $i,
      "description": "Task $i for $INTENT_ID",
      "worktree": "$WORKTREE_DIR",
      "branch": "$BRANCH",
      "status": "pending",
      "assigned_at": null,
      "completed_at": null
    }
EOF
done

cat >> "$WORKTREES_FILE" << EOF || error_exit "Failed to complete worktrees.json"
  ]
}
EOF

echo ""
echo "✓ Successfully created worktrees.json"

echo ""
echo "Worktrees created:"
for i in $(seq 1 $TASK_COUNT); do
  echo "  - $WORKTREE_BASE-$i (branch: feature/$INTENT_ID-task-$i)"
done
echo ""
echo "Next steps:"
echo "1. Open each worktree in a separate Cursor window"
echo "2. Each agent reads .agent-id to get their task number"
echo "3. Agents coordinate via worktrees.json in main repo"
