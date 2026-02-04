#!/bin/bash

# Workflow Orchestrator Script
# Automates workflow state file generation from phase spec and templates.
# Phase list: scripts/workflow-templates/phases.yml. Add a phase there and a .tpl file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/workflow-templates"
# shellcheck source=lib/intent.sh
[ -f "$SCRIPT_DIR/lib/intent.sh" ] && source "$SCRIPT_DIR/lib/intent.sh"

INTENT_ID="${1:-}"
if [ -z "$INTENT_ID" ]; then
    error_exit "Usage: $0 <intent-id>" 1
fi

INTENT_FILE="$(require_intent_file "$INTENT_ID")"

WORKFLOW_DIR="work/workflow-state"
mkdir -p "$WORKFLOW_DIR"

# Source progress library
if [ -f "$SCRIPT_DIR/lib/progress.sh" ]; then
    source "$SCRIPT_DIR/lib/progress.sh"
fi

DATE_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
PHASE_COUNT=$(node -e "
const yaml = require('yaml');
const fs = require('fs');
const spec = yaml.parse(fs.readFileSync('$TEMPLATES_DIR/phases.yml', 'utf8'));
console.log(spec.phases.length);
")

echo -e "${BLUE}Orchestrating workflow for $INTENT_ID...${NC}"
echo -e "${BLUE}Using intent file: ${INTENT_FILE}${NC}"
echo ""

phase_num=0
while IFS='|' read -r output_file template_file phase_name; do
    [ -z "$output_file" ] && continue
    phase_num=$((phase_num + 1))
    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress "$phase_num" "$PHASE_COUNT" "$phase_name" "running"
    else
        echo -e "${YELLOW}[Phase $phase_num/$PHASE_COUNT] $phase_name... ⏳${NC}"
    fi

    template_path="$TEMPLATES_DIR/$template_file"
    if [ ! -f "$template_path" ]; then
        error_exit "Template not found: $template_path" 1
    fi

    sed -e "s/{{INTENT_ID}}/$INTENT_ID/g" -e "s/{{DATE_UTC}}/$DATE_UTC/g" "$template_path" > "$WORKFLOW_DIR/$output_file" \
        || error_exit "Failed to create $WORKFLOW_DIR/$output_file" 1

    if command -v show_phase_progress >/dev/null 2>&1; then
        show_phase_progress "$phase_num" "$PHASE_COUNT" "$phase_name" "complete"
    else
        echo -e "${GREEN}✓ Created $WORKFLOW_DIR/$output_file${NC}"
    fi
done < <(node -e "
const yaml = require('yaml');
const fs = require('fs');
const spec = yaml.parse(fs.readFileSync('$TEMPLATES_DIR/phases.yml', 'utf8'));
spec.phases.forEach(p => console.log(p.output + '|' + p.template + '|' + (p.name || '')));
")

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Workflow state files created${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Fill in $WORKFLOW_DIR/01_analysis.md (PM role)"
echo "2. Fill in $WORKFLOW_DIR/02_plan.md (Architect role)"
echo "3. Fill in $WORKFLOW_DIR/03_implementation.md (Implementer role)"
echo "4. Fill in $WORKFLOW_DIR/04_verification.md (QA + Security roles)"
echo "5. Fill in $WORKFLOW_DIR/05_release_notes.md (Docs + Steward roles)"
echo ""
