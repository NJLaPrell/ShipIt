#!/bin/bash

# Agent Coordinator Script
# Manages task queue, agent assignment, and coordination

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

QUEUE_FILE="agent-queue.json"
STATUS_FILE="agent-status.json"

# Initialize queue if it doesn't exist
init_queue() {
    if [ ! -f "$QUEUE_FILE" ]; then
        cat > "$QUEUE_FILE" << EOF
{
  "version": "1.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tasks": []
}
EOF
        echo -e "${GREEN}✓ Initialized $QUEUE_FILE${NC}"
    fi
}

# Initialize status if it doesn't exist
init_status() {
    if [ ! -f "$STATUS_FILE" ]; then
        cat > "$STATUS_FILE" << EOF
{
  "version": "1.0",
  "updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "agents": []
}
EOF
        echo -e "${GREEN}✓ Initialized $STATUS_FILE${NC}"
    fi
}

# Add task to queue
add_task() {
    local intent_id="$1"
    local task_type="$2"
    local priority="${3:-medium}"
    
    init_queue
    
    # Generate task ID
    local task_count=$(jq '.tasks | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
    local task_id="T-$(printf "%03d" $((task_count + 1)))"
    
    # Add task
    jq --arg id "$task_id" \
       --arg intent "$intent_id" \
       --arg type "$task_type" \
       --arg priority "$priority" \
       --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.tasks += [{
         "id": $id,
         "intentId": $intent,
         "type": $type,
         "status": "pending",
         "priority": $priority,
         "assignedAgent": null,
         "assignedAt": null,
         "startedAt": null,
         "completedAt": null,
         "dependencies": [],
         "conflicts": [],
         "estimatedDuration": null,
         "actualDuration": null,
         "outputFiles": [],
         "notes": ""
       }] | .updated = $updated' \
       "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    echo -e "${GREEN}✓ Added task $task_id for intent $intent_id${NC}"
    echo "$task_id"
}

# Assign task to agent
assign_task() {
    local task_id="$1"
    local agent_id="$2"
    
    init_queue
    init_status
    
    # Update task
    jq --arg id "$task_id" \
       --arg agent "$agent_id" \
       --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       --arg assigned "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '(.tasks[] | select(.id == $id) | .assignedAgent) = $agent |
        (.tasks[] | select(.id == $id) | .assignedAt) = $assigned |
        (.tasks[] | select(.id == $id) | .status) = "assigned" |
        .updated = $updated' \
       "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    # Update agent status
    if ! jq -e ".agents[] | select(.id == \"$agent_id\")" "$STATUS_FILE" >/dev/null 2>&1; then
        # Add agent if doesn't exist
        jq --arg id "$agent_id" \
           --arg role "unknown" \
           --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           '.agents += [{
             "id": $id,
             "role": $role,
             "status": "working",
             "currentTask": "'"$task_id"'",
             "worktree": null,
             "lastActivity": $updated,
             "tasksCompleted": 0,
             "tasksFailed": 0,
             "communication": []
           }] | .updated = $updated' \
           "$STATUS_FILE" > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
    else
        # Update existing agent
        jq --arg id "$agent_id" \
           --arg task "$task_id" \
           --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           '(.agents[] | select(.id == $id) | .status) = "working" |
            (.agents[] | select(.id == $id) | .currentTask) = $task |
            (.agents[] | select(.id == $id) | .lastActivity) = $updated |
            .updated = $updated' \
           "$STATUS_FILE" > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
    fi
    
    echo -e "${GREEN}✓ Assigned task $task_id to agent $agent_id${NC}"
}

# Check for conflicts
check_conflicts() {
    local task_id="$1"
    
    if [ ! -f "$QUEUE_FILE" ]; then
        return 0
    fi
    
    # Get task files
    local task_files=$(jq -r ".tasks[] | select(.id == \"$task_id\") | .outputFiles[]" "$QUEUE_FILE" 2>/dev/null || echo "")
    
    if [ -z "$task_files" ]; then
        return 0
    fi
    
    # Check for other tasks using same files
    local conflicts=$(jq -r --arg id "$task_id" \
        '.tasks[] | select(.id != $id and .status == "in-progress") | 
         select(.outputFiles[] as $f | $task_files | contains([$f])) | .id' \
        "$QUEUE_FILE" 2>/dev/null || echo "")
    
    if [ -n "$conflicts" ]; then
        echo -e "${RED}⚠ Conflict detected: Task $task_id conflicts with: $conflicts${NC}"
        return 1
    fi
    
    return 0
}

# List pending tasks
list_pending() {
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "No task queue found"
        return
    fi
    
    echo -e "${BLUE}Pending Tasks:${NC}"
    jq -r '.tasks[] | select(.status == "pending" or .status == "assigned") | 
           "\(.id): \(.intentId) - \(.type) [\(.priority)]"' "$QUEUE_FILE" 2>/dev/null || echo "No pending tasks"
}

# List agent status
list_agents() {
    if [ ! -f "$STATUS_FILE" ]; then
        echo "No agent status found"
        return
    fi
    
    echo -e "${BLUE}Agent Status:${NC}"
    jq -r '.agents[] | "\(.id) [\(.role)]: \(.status) - Task: \(.currentTask // "none")"' "$STATUS_FILE" 2>/dev/null || echo "No agents"
}

# Main command handler
case "${1:-}" in
    init)
        init_queue
        init_status
        ;;
    
    add)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            error_exit "Usage: $0 add <intent-id> <task-type> [priority]" 1
        fi
        add_task "$2" "$3" "${4:-medium}"
        ;;
    
    assign)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            error_exit "Usage: $0 assign <task-id> <agent-id>" 1
        fi
        assign_task "$2" "$3"
        ;;
    
    check-conflicts)
        if [ -z "${2:-}" ]; then
            error_exit "Usage: $0 check-conflicts <task-id>" 1
        fi
        check_conflicts "$2"
        ;;
    
    list-pending)
        list_pending
        ;;
    
    list-agents)
        list_agents
        ;;
    
    *)
        echo "Agent Coordinator"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  init                    Initialize queue and status files"
        echo "  add <intent> <type>     Add task to queue"
        echo "  assign <task> <agent>   Assign task to agent"
        echo "  check-conflicts <task>   Check for conflicts"
        echo "  list-pending            List pending tasks"
        echo "  list-agents             List agent status"
        ;;
esac
