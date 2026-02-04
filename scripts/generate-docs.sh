#!/bin/bash

# Automated Documentation Generation Script
# Generates README, architecture docs, and API docs from project structure

set -euo pipefail

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Generating project documentation...${NC}"
echo ""

# Check prerequisites
if [ ! -f "project.json" ]; then
    error_exit "project.json not found. Run /init-project first." 1
fi

PROJECT_NAME=$(jq -r '.name' project.json 2>/dev/null || echo "project")
PROJECT_DESC=$(jq -r '.description' project.json 2>/dev/null || echo "Project description")
TECH_STACK=$(jq -r '.techStack' project.json 2>/dev/null || echo "typescript-nodejs")

# Generate README.md
echo -e "${YELLOW}Generating README.md...${NC}"
cat > README.md << EOF || error_exit "Failed to generate README.md"
# $PROJECT_NAME

$PROJECT_DESC

## Quick Start

\`\`\`bash
# Install dependencies
$(case $TECH_STACK in
    "typescript-nodejs") echo "pnpm install" ;;
    "python") echo "pip install -r requirements.txt" ;;
    *) echo "# Install dependencies for your tech stack" ;;
esac)

# Run tests
$(case $TECH_STACK in
    "typescript-nodejs") echo "pnpm test" ;;
    "python") echo "pytest" ;;
    *) echo "# Run tests" ;;
esac)

# Start development
$(case $TECH_STACK in
    "typescript-nodejs") echo "pnpm dev" ;;
    "python") echo "python -m src" ;;
    *) echo "# Start development server" ;;
esac)
\`\`\`

## Project Structure

\`\`\`
.
├── intent/              # Planned work (features, bugs, tech-debt)
├── workflow-state/      # Current execution state
├── architecture/        # System boundaries and constraints
├── src/                 # Source code
├── tests/               # Test files
├── do-not-repeat/       # Failed approaches ledger
├── generated/
│   ├── artifacts/       # Generated artifacts (SYSTEM_STATE, dependencies, etc.)
│   ├── drift/           # Entropy monitoring
│   ├── release/         # Release plan
│   ├── roadmap/         # Planning views (now, next, later)
│   └── reports/         # Mutation and other reports
\`\`\`

## Development

This project uses the ShipIt framework.

### Key Commands

- \`/init-project\` - Initialize a new project
- \`/scope-project\` - AI-assisted project scoping
- \`/new_intent\` - Create a new intent
- \`/ship <intent-id>\` - Ship a feature through the SDLC
- \`/deploy\` - Deploy to production
- \`/verify <intent-id>\` - Run verification phase
- \`/kill <intent-id>\` - Kill an intent

### Workflow

1. **Create Intent:** Define what to build
2. **Scope:** Break down into features
3. **Plan:** Architect the solution
4. **Test:** Write tests first
5. **Implement:** Write code
6. **Verify:** Run all checks
7. **Deploy:** Ship to production

## Architecture

See \`architecture/CANON.md\` for system boundaries and constraints.

## Testing

\`\`\`bash
# Run tests
$(case $TECH_STACK in
    "typescript-nodejs") echo "pnpm test" ;;
    "python") echo "pytest" ;;
    *) echo "# Run tests" ;;
esac)

# Run with coverage
$(case $TECH_STACK in
    "typescript-nodejs") echo "pnpm test:coverage" ;;
    "python") echo "pytest --cov" ;;
    *) echo "# Run with coverage" ;;
esac)
\`\`\`

## Deployment

\`\`\`bash
# Check readiness
pnpm check-readiness

# Deploy
pnpm deploy [environment]
\`\`\`

## License

MIT
EOF

echo -e "${GREEN}✓ Generated README.md${NC}"

# Generate architecture docs if src exists
if [ -d "src" ]; then
    echo -e "${YELLOW}Generating architecture documentation...${NC}"
    
    ARCH_DOC="architecture/DOCUMENTATION.md"
    cat > "$ARCH_DOC" << EOF || error_exit "Failed to generate architecture docs"
# Architecture Documentation

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## System Overview

[Auto-generated from code structure]

## Components

EOF

    # List source files
    find src -type f -name "*.ts" -o -name "*.js" -o -name "*.py" 2>/dev/null | while read -r file; do
        REL_PATH=$(echo "$file" | sed "s|^src/||")
        echo "- \`$REL_PATH\`" >> "$ARCH_DOC"
    done

    cat >> "$ARCH_DOC" << EOF

## Dependencies

[Auto-generated from package.json or requirements.txt]

## API Endpoints

[Auto-generated from route files]

---

*This file is auto-generated. Update source code to change documentation.*
EOF

    echo -e "${GREEN}✓ Generated architecture documentation${NC}"
fi

# Generate API docs if routes exist
if [ -d "src/routes" ] || [ -d "src/api" ]; then
    echo -e "${YELLOW}Generating API documentation...${NC}"
    
    API_DOC="API.md"
    cat > "$API_DOC" << EOF || error_exit "Failed to generate API docs"
# API Documentation

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Endpoints

EOF

    # Find route files
    find src -type f \( -name "*route*.ts" -o -name "*route*.js" -o -name "*api*.py" \) 2>/dev/null | while read -r file; do
        REL_PATH=$(echo "$file" | sed "s|^src/||")
        echo "### \`$REL_PATH\`" >> "$API_DOC"
        echo "" >> "$API_DOC"
        echo "[Endpoint documentation]" >> "$API_DOC"
        echo "" >> "$API_DOC"
    done

    echo -e "${GREEN}✓ Generated API documentation${NC}"
fi

# Generate deployment guide
echo -e "${YELLOW}Generating deployment guide...${NC}"
DEPLOY_GUIDE="DEPLOYMENT.md"
cat > "$DEPLOY_GUIDE" << EOF || error_exit "Failed to generate deployment guide"
# Deployment Guide

**Project:** $PROJECT_NAME

## Prerequisites

- All tests passing
- Coverage thresholds met
- Security audit clean
- Documentation complete

## Deployment Steps

1. **Check Readiness:**
   \`\`\`bash
   pnpm check-readiness
   \`\`\`

2. **Deploy:**
   \`\`\`bash
   pnpm deploy [environment]
   \`\`\`

## Supported Platforms

- Vercel
- Netlify
- Docker
- AWS CDK
- Manual

## Environment Configuration

[Add environment-specific configuration here]

## Rollback

If deployment fails:
1. Run rollback script
2. Restore previous version
3. Verify system stability

## Monitoring

[Add monitoring setup instructions here]

---

*Last updated: $(date -u +"%Y-%m-%d")*
EOF

echo -e "${GREEN}✓ Generated deployment guide${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Documentation generation complete${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Generated files:${NC}"
echo "  - README.md"
[ -f "architecture/DOCUMENTATION.md" ] && echo "  - architecture/DOCUMENTATION.md"
[ -f "API.md" ] && echo "  - API.md"
echo "  - DEPLOYMENT.md"
echo ""
