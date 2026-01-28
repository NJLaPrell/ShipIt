#!/bin/bash

# AI-Assisted Project Scoping Script
# Breaks down project into features and generates initial intents

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if project.json exists
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

# Get project description
PROJECT_DESC="${1:-}"
if [ -z "$PROJECT_DESC" ]; then
    read -p "Project description: " PROJECT_DESC
    if [ -z "$PROJECT_DESC" ]; then
        error_exit "Project description is required" 1
    fi
fi

echo -e "${BLUE}Scoping project: $PROJECT_DESC${NC}"
echo ""

# Read project metadata
PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")
TECH_STACK=$(jq -r '.techStack' project.json 2>/dev/null || echo "typescript-nodejs")
HIGH_RISK=$(jq -r '.highRiskDomains | join(", ")' project.json 2>/dev/null || echo "none")

echo -e "${YELLOW}Project Context:${NC}"
echo "  Name: $PROJECT_NAME"
echo "  Tech Stack: $TECH_STACK"
echo "  High-Risk Domains: $HIGH_RISK"
echo ""

# Interactive follow-up questions with defaults
declare -A FOLLOW_UP_DEFAULTS=(
    ["Is a UI required (API-only, CLI, Web)?"]="Web"
    ["What persistence should be used (JSON file, SQLite, etc.)?"]="JSON file"
    ["Single-user or multi-user?"]="Single-user"
    ["Authentication required (none, API key, full auth)?"]="none"
    ["Any non-functional requirements (performance, scaling, etc.)?"]="Fast for typical use cases"
)

FOLLOW_UP_QUESTIONS=(
    "Is a UI required (API-only, CLI, Web)?"
    "What persistence should be used (JSON file, SQLite, etc.)?"
    "Single-user or multi-user?"
    "Authentication required (none, API key, full auth)?"
    "Any non-functional requirements (performance, scaling, etc.)?"
)

FOLLOW_UP_ANSWERS=()

# Batch prompt: show all questions with defaults
echo -e "${YELLOW}Follow-Up Questions (required):${NC}"
echo ""
echo "Review and edit answers below. Press Enter to accept default, or type new answer."
echo ""

for i in "${!FOLLOW_UP_QUESTIONS[@]}"; do
    question="${FOLLOW_UP_QUESTIONS[$i]}"
    default="${FOLLOW_UP_DEFAULTS[$question]}"
    
    # Show question with default
    echo -e "${CYAN}Q$((i + 1)):${NC} $question"
    echo -e "  ${YELLOW}Default:${NC} $default"
    read -p "  Your answer [$default]: " answer
    
    # Use default if empty, otherwise use provided answer
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    
    FOLLOW_UP_ANSWERS+=("$answer")
    echo ""
done

echo -e "${YELLOW}Review your answers:${NC}"
for i in "${!FOLLOW_UP_QUESTIONS[@]}"; do
    echo "  Q$((i + 1)): ${FOLLOW_UP_QUESTIONS[$i]}"
    echo "     A: ${FOLLOW_UP_ANSWERS[$i]}"
done
echo ""
read -p "Confirm answers? (y/n) [y]: " confirm
confirm="${confirm:-y}"

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    error_exit "Scoping cancelled. Re-run /scope-project to start over." 1
fi
echo ""

# Open questions (optional)
OPEN_QUESTIONS=()
echo -e "${YELLOW}Open Questions (optional, type 'done' when finished):${NC}"
while IFS= read -r line; do
    [ "$line" = "done" ] && break
    [ -z "$line" ] && continue
    OPEN_QUESTIONS+=("$line")
done
echo ""

# Feature candidates (required)
FEATURES=()
echo -e "${YELLOW}Feature Candidates (required, one per line, type 'done' when finished):${NC}"
while IFS= read -r line; do
    [ "$line" = "done" ] && break
    [ -z "$line" ] && continue
    FEATURES+=("$line")
done

if [ ${#FEATURES[@]} -eq 0 ]; then
    error_exit "At least one feature candidate is required." 1
fi
echo ""

# Intent selection
echo -e "${YELLOW}Select features to generate intents:${NC}"
for i in "${!FEATURES[@]}"; do
    idx=$((i + 1))
    echo "  $idx) ${FEATURES[$i]}"
done
read -p "Enter selection (all, none, or comma-separated numbers): " selection

SELECTED_FEATURES=()
case "$selection" in
    all)
        SELECTED_FEATURES=("${FEATURES[@]}")
        ;;
    none)
        SELECTED_FEATURES=()
        ;;
    *)
        IFS=',' read -r -a selected_indices <<< "$selection"
        for raw_idx in "${selected_indices[@]}"; do
            idx="$(echo "$raw_idx" | tr -d '[:space:]')"
            if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le ${#FEATURES[@]} ]; then
                SELECTED_FEATURES+=("${FEATURES[$((idx - 1))]}")
            fi
        done
        ;;
esac

# Create project-scope.md
SCOPE_FILE="project-scope.md"
{
    echo "# Project Scope: $PROJECT_NAME"
    echo ""
    echo "**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "**Description:** $PROJECT_DESC"
    echo ""
    echo "## Follow-Up Questions (with answers)"
    echo ""
    for i in "${!FOLLOW_UP_QUESTIONS[@]}"; do
        echo "- Q: ${FOLLOW_UP_QUESTIONS[$i]}"
        echo "  A: ${FOLLOW_UP_ANSWERS[$i]}"
    done
    echo ""
    echo "## Open Questions (unanswered)"
    echo ""
    if [ ${#OPEN_QUESTIONS[@]} -eq 0 ]; then
        echo "(none)"
    else
        for q in "${OPEN_QUESTIONS[@]}"; do
            echo "- $q"
        done
    fi
    echo ""
    echo "## Feature Candidates"
    echo ""
    for feature in "${FEATURES[@]}"; do
        echo "- $feature"
    done
    echo ""
    echo "## Intent Selection"
    echo ""
    if [ ${#SELECTED_FEATURES[@]} -eq 0 ]; then
        echo "(none selected)"
    else
        for feature in "${SELECTED_FEATURES[@]}"; do
            echo "- $feature"
        done
    fi
    echo ""
    echo "## Generated Intents"
    echo ""
} > "$SCOPE_FILE" || error_exit "Failed to create project-scope.md"

echo -e "${GREEN}✓ Created $SCOPE_FILE${NC}"

# Create release plan stub if missing
RELEASE_DIR="release"
RELEASE_PLAN="$RELEASE_DIR/plan.md"
if [ ! -f "$RELEASE_PLAN" ]; then
    mkdir -p "$RELEASE_DIR" || error_exit "Failed to create release directory"
    cat > "$RELEASE_PLAN" << EOF || error_exit "Failed to create release/plan.md"
# Release Plan

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Summary

- Total intents: 0
- Planned intents: 0
- Releases: 0

EOF
    echo -e "${GREEN}✓ Created $RELEASE_PLAN${NC}"
fi

# Best-effort release plan generation if available
INTENT_BASE_DIR="intent"
INTENT_DIR="$INTENT_BASE_DIR/features"
TEMPLATE_FILE="$INTENT_BASE_DIR/_TEMPLATE.md"

if [ ${#SELECTED_FEATURES[@]} -gt 0 ]; then
    if [ ! -f "$TEMPLATE_FILE" ]; then
        error_exit "Template file not found: $TEMPLATE_FILE" 1
    fi
    mkdir -p "$INTENT_DIR" || error_exit "Failed to create intent directory: $INTENT_DIR"

    LAST_INTENT=0
    while IFS= read -r file; do
        [ -e "$file" ] || continue
        base="$(basename "$file")"
        if [[ "$base" =~ ^F-([0-9]+)\.md$ ]]; then
            num="${BASH_REMATCH[1]}"
            if ((10#$num > LAST_INTENT)); then
                LAST_INTENT=$((10#$num))
            fi
        fi
    done < <(find "$INTENT_BASE_DIR" -type f -name 'F-*.md' 2>/dev/null)
    NEXT_NUM=$((LAST_INTENT + 1))

    GENERATED_INTENTS=()
    for feature in "${SELECTED_FEATURES[@]}"; do
        INTENT_ID="F-$(printf "%03d" $NEXT_NUM)"
        NEXT_NUM=$((NEXT_NUM + 1))

        read -p "Dependencies for $INTENT_ID (comma-separated or 'none'): " deps_input
        deps_input="${deps_input:-none}"
        DEP_LINES=()
        if [ "$deps_input" != "none" ]; then
            IFS=',' read -r -a dep_items <<< "$deps_input"
            for dep in "${dep_items[@]}"; do
                dep_trim="$(echo "$dep" | tr -d '[:space:]')"
                [ -z "$dep_trim" ] && continue
                DEP_LINES+=("- ${dep_trim}")
            done
        fi
        if [ ${#DEP_LINES[@]} -eq 0 ]; then
            DEP_LINES+=("- (none)")
        fi

        INTENT_FILE="$INTENT_DIR/$INTENT_ID.md"
        TEMP_FILE="$(mktemp)"
        MOTIVATION_FILE="$(mktemp)"
        DEP_FILE="$(mktemp)"

        sed -e "s/# F-###: Title/# $INTENT_ID: $feature/" \
            -e "s/feature | bug | tech-debt/feature/" \
            -e "s/planned | active | blocked | validating | shipped | killed/planned/" \
            -e "s/p0 | p1 | p2 | p3/p2/" \
            -e "s/s | m | l/m/" \
            -e "s/R1 | R2 | R3 | R4/R2/" \
            "$TEMPLATE_FILE" > "$TEMP_FILE" || error_exit "Failed to create intent template"

        printf "%s\n" "- ${feature}" > "$MOTIVATION_FILE"
        printf "%s\n" "${DEP_LINES[@]}" > "$DEP_FILE"

        awk -v motivation_file="$MOTIVATION_FILE" -v deps_file="$DEP_FILE" '
            $0 == "(Why it exists, 1–3 bullets)" {
                while ((getline line < motivation_file) > 0) print line;
                close(motivation_file);
                next;
            }
            /^- \(Other intent IDs that must ship first\)$/ {
                # Replace placeholder dependency lines with actual deps
                # Ensure dependencies are written at column 0 (no leading whitespace)
                while ((getline line < deps_file) > 0) {
                    # Remove any leading whitespace and ensure line starts with "- "
                    sub(/^[[:space:]]+/, "", line);
                    if (line !~ /^- /) {
                        line = "- " line;
                    }
                    print line;
                }
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

        GENERATED_INTENTS+=("$INTENT_ID")
    done

    {
        echo ""
        for id in "${GENERATED_INTENTS[@]}"; do
            echo "- \`intent/features/${id}.md\`"
        done
    } >> "$SCOPE_FILE"
fi

if [ -x "./scripts/generate-release-plan.sh" ]; then
    ./scripts/generate-release-plan.sh || echo "WARNING: release plan generation failed"
fi

if [ -x "./scripts/generate-roadmap.sh" ]; then
    ./scripts/generate-roadmap.sh || echo "WARNING: roadmap generation failed"
fi
# Show next-step suggestions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/suggest-next.sh" ]; then
    source "$SCRIPT_DIR/lib/suggest-next.sh"
    display_suggestions "scoping"
fi
