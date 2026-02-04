#!/bin/bash

# Context-aware help system for ShipIt
# Shows help for commands or general guidance

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

COMMAND="${1:-}"

show_general_help() {
    echo -e "${BLUE}ShipIt Help${NC}"
    echo ""
    echo "Available commands:"
    echo ""
    echo -e "${CYAN}Project Management:${NC}"
    echo "  /init-project [name]     - Initialize a new ShipIt project"
    echo "  /scope-project [desc]    - AI-assisted feature breakdown"
    echo ""
    echo -e "${CYAN}Intent Management:${NC}"
    echo "  /new_intent              - Create a new intent (interactive wizard)"
    echo "  /kill <id>               - Kill an intent with rationale"
    echo ""
    echo -e "${CYAN}Workflow:${NC}"
    echo "  /ship <id>               - Run full SDLC workflow (6 phases)"
    echo "  /verify <id>             - Re-run verification phase"
    echo ""
    echo -e "${CYAN}Planning:${NC}"
    echo "  /generate-release-plan   - Build release plan from intents"
    echo "  /generate-roadmap        - Generate roadmap (now/next/later)"
    echo ""
    echo -e "${CYAN}Operations:${NC}"
    echo "  /deploy [env]            - Deploy with readiness checks"
    echo "  /drift_check             - Check for entropy/decay"
    echo "  /risk <id>               - Force security/threat skim"
    echo ""
    echo -e "${CYAN}Help & Status:${NC}"
    echo "  /help [command]          - Show help for a command"
    echo "  /status                  - Show current project status"
    echo "  /suggest                 - Get suggested next actions"
    echo "  /pr <id>                 - Generate PR summary/checklist"
    echo "  /revert-plan <id>        - Write rollback plan"
    echo ""
    echo "Use /help <command> for detailed help on a specific command."
}

show_command_help() {
    case "$COMMAND" in
        init-project|init_project)
            echo -e "${BLUE}/init-project${NC}"
            echo ""
            echo "Initialize a new ShipIt project with full framework setup."
            echo ""
            echo "Usage: /init-project [project-name]"
            echo ""
            echo "Prompts for:"
            echo "  - Tech stack (TypeScript/Node.js, Python, Other)"
            echo "  - Project description"
            echo "  - High-risk domains"
            echo ""
            echo "Creates:"
            echo "  - Project structure with all directories"
            echo "  - Configuration files (package.json, tsconfig.json, etc.)"
            echo "  - Framework commands and rules"
            echo "  - Initial intent template"
            ;;
        scope-project|scope_project)
            echo -e "${BLUE}/scope-project${NC}"
            echo ""
            echo "AI-assisted project scoping that breaks down a project into features."
            echo ""
            echo "Usage: /scope-project \"project description\""
            echo ""
            echo "Interactive prompts:"
            echo "  - UI type (API-only, CLI, Web)"
            echo "  - Persistence (JSON file, SQLite, etc.)"
            echo "  - User model (single-user, multi-user)"
            echo "  - Authentication requirements"
            echo "  - Non-functional requirements"
            echo "  - Feature candidates"
            echo ""
            echo "Outputs:"
            echo "  - project-scope.md with answers"
            echo "  - Generated intent files"
            echo "  - Updated roadmap and release plan"
            ;;
        new_intent|new-intent)
            echo -e "${BLUE}/new_intent${NC}"
            echo ""
            echo "Interactive wizard to create a new intent file."
            echo ""
            echo "Usage: /new_intent"
            echo ""
            echo "Prompts for:"
            echo "  - Intent type (Feature, Bug, Tech Debt)"
            echo "  - Title"
            echo "  - Motivation (why it exists)"
            echo "  - Priority (p0-p3)"
            echo "  - Effort (s/m/l)"
            echo "  - Release Target (R1-R4)"
            echo "  - Dependencies (other intent IDs)"
            echo "  - Risk Level (low/medium/high)"
            echo ""
            echo "Creates: work/intent/<id>.md with all fields filled in."
            ;;
        ship)
            echo -e "${BLUE}/ship${NC}"
            echo ""
            echo "Run the full SDLC workflow for an intent (6 phases)."
            echo ""
            echo "Usage: /ship <intent-id>"
            echo ""
            echo "Phases:"
            echo "  1. Analysis (PM) - Requirements clarification"
            echo "  2. Planning (Architect) - Technical design (requires approval)"
            echo "  3. Tests (QA) - Write tests first"
            echo "  4. Implementation (Implementer) - Write code"
            echo "  5. Verification (QA + Security) - Validate everything"
            echo "  6. Release (Docs + Steward) - Documentation and approval"
            echo ""
            echo "Creates workflow-state files for each phase."
            ;;
        verify)
            echo -e "${BLUE}/verify${NC}"
            echo ""
            echo "Re-run the verification phase for an intent."
            echo ""
            echo "Usage: /verify <intent-id>"
            echo ""
            echo "Runs:"
            echo "  - Test suite"
            echo "  - Mutation testing"
            echo "  - Security audit"
            echo "  - Code review"
            echo ""
            echo "Updates work/workflow-state/04_verification.md"
            ;;
        kill)
            echo -e "${BLUE}/kill${NC}"
            echo ""
            echo "Kill an intent with rationale."
            echo ""
            echo "Usage: /kill <intent-id>"
            echo ""
            echo "Prompts for:"
            echo "  - Kill rationale (why it's being killed)"
            echo ""
            echo "Updates:"
            echo "  - Intent status → killed"
            echo "  - Adds kill rationale section"
            echo "  - Updates work/workflow-state/active.md"
            ;;
        generate-release-plan|generate_release_plan)
            echo -e "${BLUE}/generate-release-plan${NC}"
            echo ""
            echo "Generate release plan from intents with dependency ordering."
            echo ""
            echo "Usage: /generate-release-plan"
            echo ""
            echo "Outputs: work/release/plan.md with:"
            echo "  - Intents grouped by release (R1-R4)"
            echo "  - Dependency-ordered within each release"
            echo "  - Missing dependencies section"
            echo "  - Excluded intents (shipped/killed)"
            ;;
        generate-roadmap|generate_roadmap)
            echo -e "${BLUE}/generate-roadmap${NC}"
            echo ""
            echo "Generate roadmap files (now/next/later) from intents."
            echo ""
            echo "Usage: /generate-roadmap"
            echo ""
            echo "Outputs:"
            echo "  - work/roadmap/now.md (intents with no dependencies)"
            echo "  - work/roadmap/next.md (intents with dependencies)"
            echo "  - work/roadmap/later.md (blocked/backlog)"
            ;;
        deploy)
            echo -e "${BLUE}/deploy${NC}"
            echo ""
            echo "Deploy with readiness checks."
            echo ""
            echo "Usage: /deploy [environment]"
            echo ""
            echo "Runs readiness checks:"
            echo "  - Tests pass"
            echo "  - Typecheck passes"
            echo "  - Lint passes"
            echo "  - Security audit"
            echo ""
            echo "Requires Steward approval for high-risk domains."
            ;;
        drift_check|drift-check)
            echo -e "${BLUE}/drift_check${NC}"
            echo ""
            echo "Check for entropy/decay in the project."
            echo ""
            echo "Usage: /drift_check"
            echo ""
            echo "Calculates metrics and updates _system/drift/metrics.md"
            ;;
        status)
            echo -e "${BLUE}/status${NC}"
            echo ""
            echo "Show current project status."
            echo ""
            echo "Usage: /status"
            echo ""
            echo "Shows:"
            echo "  - Active intent (if any)"
            echo "  - Current workflow phase"
            echo "  - Intent counts by status"
            echo "  - Recent activity"
            ;;
        suggest)
            echo -e "${BLUE}/suggest${NC}"
            echo ""
            echo "Get suggested next actions based on current state."
            echo ""
            echo "Usage: /suggest"
            echo ""
            echo "Suggests actions like:"
            echo "  - Create new intent"
            echo "  - Continue workflow for active intent"
            echo "  - Review pending approvals"
            echo "  - Update release plan"
            ;;
        pr)
            echo -e "${BLUE}/pr${NC}"
            echo ""
            echo "Generate PR summary and checklist for an intent."
            echo ""
            echo "Usage: /pr <intent-id>"
            echo ""
            echo "Writes work/workflow-state/pr.md"
            ;;
        risk)
            echo -e "${BLUE}/risk${NC}"
            echo ""
            echo "Force a focused security/threat skim for an intent."
            echo ""
            echo "Usage: /risk <intent-id>"
            echo ""
            echo "Writes work/workflow-state/04_verification.md (Security section)"
            ;;
        revert-plan|revert_plan)
            echo -e "${BLUE}/revert-plan${NC}"
            echo ""
            echo "Write a rollback plan for an intent."
            echo ""
            echo "Usage: /revert-plan <intent-id>"
            echo ""
            echo "Writes work/workflow-state/rollback.md"
            ;;
        *)
            echo -e "${YELLOW}Unknown command: $COMMAND${NC}"
            echo ""
            show_general_help
            exit 1
            ;;
    esac
}

if [ -z "$COMMAND" ]; then
    show_general_help
else
    show_command_help
fi
