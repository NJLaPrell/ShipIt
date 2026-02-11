#!/bin/bash

# Test Project Initialization Script
# INTERNAL USE ONLY: Creates test project for ShipIt end-to-end validation
# For user projects, use 'shipit init' or 'create-shipit-app' instead

set -euo pipefail

# Error handling
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Framework repo detection
# Check if running from ShipIt framework repo root (package name is shipit or @scope/shipit)
if [ ! -f "$ROOT_DIR/package.json" ]; then
    error_exit "This script is for internal ShipIt testing only. Use 'shipit init' or 'create-shipit-app' for user projects." 1
fi
if ! grep -qE '"name":\s*"(shipit|@[^"]+/shipit)"' "$ROOT_DIR/package.json" 2>/dev/null; then
    error_exit "This script is for internal ShipIt testing only. Use 'shipit init' or 'create-shipit-app' for user projects." 1
fi

if [ ! -f "$ROOT_DIR/_system/architecture/CANON.md" ]; then
    error_exit "This script is for internal ShipIt testing only. Use 'shipit init' or 'create-shipit-app' for user projects." 1
fi

# Read test fixtures
FIXTURES_FILE="$ROOT_DIR/tests/fixtures.json"
if [ ! -f "$FIXTURES_FILE" ]; then
    error_exit "Test fixtures file not found: $FIXTURES_FILE" 1
fi

# Extract values from fixtures.json using jq (or fallback to defaults)
if command -v jq >/dev/null 2>&1; then
    PROJECT_NAME=$(jq -r '.projectName // "shipit-test"' "$FIXTURES_FILE")
    TECH_STACK_INPUT=$(jq -r '.inputs["step_1-2"].techStack // "1"' "$FIXTURES_FILE")
    PROJECT_DESC=$(jq -r '.inputs["step_1-2"].description // "Test project for ShipIt end-to-end validation"' "$FIXTURES_FILE")
    HIGH_RISK=$(jq -r '.inputs["step_1-2"].highRiskDomains // "none"' "$FIXTURES_FILE")
else
    # Fallback if jq not available (use defaults)
    PROJECT_NAME="shipit-test"
    TECH_STACK_INPUT="1"
    PROJECT_DESC="Test project for ShipIt end-to-end validation"
    HIGH_RISK="none"
fi

# Validate project name (alphanumeric, hyphens, underscores)
if ! [[ "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    error_exit "Project name must be alphanumeric with hyphens/underscores only" 1
fi

# Always create in tests/test-project regardless of project name argument
TARGET_DIR="$ROOT_DIR/tests/test-project"

echo -e "${BLUE}Initializing test project: $PROJECT_NAME${NC}"
echo -e "${YELLOW}Note: This script is for internal ShipIt testing only.${NC}"
echo ""

# Ensure tests directory exists
mkdir -p "$ROOT_DIR/tests" || error_exit "Failed to create tests directory"

# Remove existing test project if it exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Removing existing test project...${NC}"
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR" || error_exit "Failed to create test project directory"

cd "$TARGET_DIR" || error_exit "Failed to enter test project directory"

# Tech stack selection from fixtures
case "$TECH_STACK_INPUT" in
    1) TECH_STACK="typescript-nodejs"; STACK_NAME="TypeScript/Node.js" ;;
    2) TECH_STACK="python"; STACK_NAME="Python" ;;
    3) TECH_STACK="other"; STACK_NAME="Other" ;;
    *) TECH_STACK="typescript-nodejs"; STACK_NAME="TypeScript/Node.js" ;;
esac

echo -e "${GREEN}Using test fixtures:${NC}"
echo -e "  Tech stack: $STACK_NAME"
echo -e "  Description: $PROJECT_DESC"
echo -e "  High-risk domains: $HIGH_RISK"
echo ""

# Create project structure
echo -e "${BLUE}Creating project structure...${NC}"

# Core directories (work/ = current work; _system/ = framework and generated)
mkdir -p work/intent/features work/intent/bugs work/intent/tech-debt work/workflow-state work/roadmap work/release _system/architecture _system/do-not-repeat _system/drift _system/behaviors _system/security _system/artifacts _system/golden-data _system/reports scripts src tests docs .cursor/rules .cursor/commands .github/workflows

# Copy framework commands, rules, and core scripts into the new project
if [ -d "$ROOT_DIR/.cursor/commands" ]; then
    cp -R "$ROOT_DIR/.cursor/commands/." ".cursor/commands/"
fi

if [ -d "$ROOT_DIR/.cursor/rules" ]; then
    cp -R "$ROOT_DIR/.cursor/rules/." ".cursor/rules/"
fi

# Copy ShipIt test fixtures and documentation into the new project
# Exclude test-project directory to avoid recursion
if [ -d "$ROOT_DIR/tests" ]; then
    mkdir -p tests
    # Copy all files/directories except test-project
    for item in "$ROOT_DIR/tests"/*; do
        item_name=$(basename "$item")
        if [ "$item_name" != "test-project" ]; then
            cp -R "$item" "tests/"
        fi
    done
fi

# Copy mutation testing config if present
if [ -f "$ROOT_DIR/stryker.conf.json" ]; then
    cp "$ROOT_DIR/stryker.conf.json" "stryker.conf.json"
fi

for script in new-intent.sh scope-project.sh generate-roadmap.sh generate-release-plan.sh drift-check.sh generate-system-state.sh deploy.sh check-readiness.sh workflow-orchestrator.sh kill-intent.sh verify.sh help.sh status.sh suggest.sh fix-intents.sh dashboard-start.sh execute-rollback.sh; do
    if [ -f "$ROOT_DIR/scripts/$script" ]; then
        cp "$ROOT_DIR/scripts/$script" "scripts/$script"
        chmod +x "scripts/$script"
    fi
done

# Copy scripts/lib (common.sh, intent.sh, etc.) so workflow-orchestrator, kill-intent, and others work.
if [ -d "$ROOT_DIR/scripts/lib" ]; then
    mkdir -p scripts/lib
    cp -R "$ROOT_DIR/scripts/lib/." "scripts/lib/"
    chmod +x scripts/lib/*.sh 2>/dev/null || true
fi

# Copy workflow-templates (phases.yml + .tpl) so workflow-orchestrator can generate phase files.
if [ -d "$ROOT_DIR/scripts/workflow-templates" ]; then
    mkdir -p scripts/workflow-templates
    cp -R "$ROOT_DIR/scripts/workflow-templates/." "scripts/workflow-templates/"
fi

# Copy command-manifest.yml so help.sh can build the command list.
if [ -f "$ROOT_DIR/scripts/command-manifest.yml" ]; then
    cp "$ROOT_DIR/scripts/command-manifest.yml" "scripts/command-manifest.yml"
fi

# Copy dashboard and rollback scripts.
if [ -f "$ROOT_DIR/scripts/export-dashboard-json.js" ]; then
    cp "$ROOT_DIR/scripts/export-dashboard-json.js" "scripts/export-dashboard-json.js"
fi
if [ -d "$ROOT_DIR/dashboard-app" ]; then
    cp -R "$ROOT_DIR/dashboard-app" "dashboard-app/"
fi

# Copy scripts/gh/ (GitHub integration: create issue, link issue, create PR, on-ship update, create intent from issue).
if [ -d "$ROOT_DIR/scripts/gh" ]; then
    mkdir -p scripts/gh
    cp -R "$ROOT_DIR/scripts/gh/." "scripts/gh/"
    chmod +x scripts/gh/*.sh 2>/dev/null || true
fi

# Copy test-plan issue helper into the new project (used by test runner rules).
if [ -f "$ROOT_DIR/scripts/create-test-plan-issue.sh" ]; then
    cp "$ROOT_DIR/scripts/create-test-plan-issue.sh" "scripts/create-test-plan-issue.sh"
    chmod +x "scripts/create-test-plan-issue.sh"
fi

# Copy test-plan issue tracking runbook into the new project (referenced by tests + Cursor rules).
if [ -f "$ROOT_DIR/_system/behaviors/WORK_TEST_PLAN_ISSUES.md" ]; then
    cp "$ROOT_DIR/_system/behaviors/WORK_TEST_PLAN_ISSUES.md" "_system/behaviors/WORK_TEST_PLAN_ISSUES.md"
fi

# Create project.json
cat > project.json << EOF || error_exit "Failed to create project.json"
{
  "name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "version": "0.1.0",
  "techStack": "$TECH_STACK",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "highRiskDomains": $(echo "$HIGH_RISK" | awk -F',' '{
    if ($1 == "none") print "[]";
    else {
      printf "[";
      for (i=1; i<=NF; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", $i);
        if (i>1) printf ",";
        printf "\"%s\"", $i;
      }
      printf "]";
    }
  }'),
  "settings": {
    "humanResponseTime": "minutes",
    "confidenceThreshold": 0.7,
    "testCoverageMinimum": 80
  }
}
EOF

echo -e "${GREEN}✓ Created project.json${NC}"

# Create initial README.md
cat > README.md << EOF || error_exit "Failed to create README.md"
# $PROJECT_NAME

$PROJECT_DESC

## Quick Start

\`\`\`bash
# Install dependencies
pnpm install  # or npm install, pip install, etc.

# Run tests
pnpm test

# Start development
pnpm dev
\`\`\`

## Project Structure

- \`work/intent/\` - Planned work (features, bugs, tech-debt)
- \`work/workflow-state/\` - Current execution state
- \`_system/architecture/\` - System boundaries and constraints
- \`/src/\` - Source code
- \`/tests/\` - Test files

## Development

This project uses the ShipIt framework. See [AGENTS.md](./AGENTS.md) for workflow details.

## License

MIT
EOF

echo -e "${GREEN}✓ Created README.md${NC}"

# Create _system/architecture/CANON.md
mkdir -p _system/architecture
cat > _system/architecture/CANON.md << EOF || error_exit "Failed to create CANON.md"
# Architecture Canon

> **This document is the authoritative source for system architecture.**
> Code that violates this canon is illegal. Update this document before implementing violations.

## System Overview

[Describe your system architecture here]

## Boundaries

### Layer Responsibilities

| Layer | Responsibility | Cannot Do |
|-------|----------------|-----------|
| **Intent** | Define WHAT to build | Specify HOW to implement |
| **Architecture** | Define HOW systems connect | Write production code |
| **Implementation** | Write code that passes tests | Change architecture |
| **Verification** | Prove correctness | Weaken acceptance criteria |

## Allowed Dependencies

[Define your allowed dependencies here]

## Forbidden Patterns

[Define forbidden patterns here]

## Performance Budgets

| Metric | Budget | Measurement |
|--------|--------|-------------|
| p95 latency | < 200ms | API response time |
| p99 latency | < 500ms | API response time |
| Memory | < 512MB | Process RSS |

## Security Requirements

[Define security requirements here]

---

*Last updated: $(date -u +"%Y-%m-%d")*
EOF

echo -e "${GREEN}✓ Created _system/architecture/CANON.md${NC}"

# Create _system/architecture/invariants.yml
cat > _system/architecture/invariants.yml << EOF || error_exit "Failed to create invariants.yml"
# Invariants Configuration
version: 1

security:
  - id: all_endpoints_authenticated
    description: All endpoints require auth except health/metrics
    exceptions:
      - "/health"
      - "/metrics"
    enforcement: ci_test

code_quality:
  - id: no_explicit_any
    description: No 'any' type allowed
    enforcement: "@typescript-eslint/no-explicit-any"
    
  - id: no_eval
    description: No eval() calls
    enforcement: "no-eval"

performance:
  p95_latency_ms: 200
  p99_latency_ms: 500
  max_memory_mb: 512

success_metrics:
  test_pass_rate_minimum: 99.5
  code_coverage_minimum: 80
EOF

echo -e "${GREEN}✓ Created _system/architecture/invariants.yml${NC}"

# Create intent template
mkdir -p work/intent/features work/intent/bugs work/intent/tech-debt
cat > work/intent/_TEMPLATE.md << 'EOFTEMPLATE' || error_exit "Failed to create intent template"
# F-###: Title

## Type
feature | bug | tech-debt

## Status
planned | active | blocked | validating | shipped | killed

## Priority
p0 | p1 | p2 | p3

## Effort
s | m | l

## Release Target
R1 | R2 | R3 | R4

## Motivation
(Why it exists, 1–3 bullets)

## Confidence
Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0

## Invariants (Hard Constraints)
Human-readable:
- [Constraint 1]
- [Constraint 2]

Executable (add to _system/architecture/invariants.yml):
```yaml
invariants:
  - [invariant_id]
```

## Acceptance (Executable)
- [ ] Tests: `<test_name>` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green

## Assumptions (MUST BE EXPLICIT)
- [Assumption 1]
- [Assumption 2]

## Risk Level
low | medium | high

## Kill Criteria
- [Criterion 1]
- [Criterion 2]

## Rollback Plan
- Feature flag: `FEATURE_X_ENABLED=false`
- Revert commit: `git revert <sha>`

## Dependencies
- [Other intent IDs or external systems]

## Do Not Repeat Check
- [ ] Checked _system/do-not-repeat/abandoned-designs.md
- [ ] Checked _system/do-not-repeat/failed-experiments.md
EOFTEMPLATE

echo -e "${GREEN}✓ Created work/intent/_TEMPLATE.md${NC}"

# Copy intent templates by kind (if present in repo) so new-intent can offer API, frontend, infra, bugfix, refactor
if [ -d "$ROOT_DIR/work/intent/templates" ]; then
    mkdir -p work/intent/templates
    for f in "$ROOT_DIR/work/intent/templates/"*.md; do
        [ -f "$f" ] && cp "$f" work/intent/templates/ || true
    done
    echo -e "${GREEN}✓ Created work/intent/templates/${NC}"
fi

# Create do-not-repeat files
mkdir -p _system/do-not-repeat
cat > _system/do-not-repeat/abandoned-designs.md << EOF || error_exit "Failed to create abandoned-designs.md"
# Abandoned Designs

This ledger records design approaches that were considered but rejected.

## Entries

(No entries yet. Add entries as designs are abandoned.)
EOF

cat > _system/do-not-repeat/failed-experiments.md << EOF || error_exit "Failed to create failed-experiments.md"
# Failed Experiments

This ledger records experiments that were tried but failed.

## Entries

(No entries yet. Add entries as experiments fail.)
EOF

cat > _system/do-not-repeat/bad-patterns.md << EOF || error_exit "Failed to create bad-patterns.md"
# Bad Patterns

This ledger records code patterns, architectural approaches, or practices that have been identified as problematic. **Do not repeat these patterns.**

## Format

Each entry should include:
- **Pattern:** Brief description of the pattern
- **Why it's bad:** Problems it causes
- **Date:** When it was identified
- **Intent ID:** Related intent (if any)
- **Alternative:** Better approach (if known)

---

## Entries

(No entries yet. Add entries as bad patterns are identified.)
EOF

cat > _system/do-not-repeat/rejected-libraries.md << EOF || error_exit "Failed to create rejected-libraries.md"
# Rejected Libraries

This ledger records libraries, frameworks, or tools that were evaluated but rejected. **Do not reconsider these without new information.**

## Format

Each entry should include:
- **Library:** Name and version (if applicable)
- **Why rejected:** Reason for rejection (performance, licensing, maintenance, etc.)
- **Date:** When it was rejected
- **Intent ID:** Related intent (if any)
- **Alternatives:** Better options (if known)

---

## Entries

(No entries yet. Add entries as libraries are rejected.)
EOF

echo -e "${GREEN}✓ Created do-not-repeat ledger files${NC}"

# Create roadmap files
mkdir -p work/roadmap
for file in now.md next.md later.md; do
    cat > "work/roadmap/$file" << EOF || error_exit "Failed to create work/roadmap/$file"
# ${file%.md}

(No items yet. Add items as they're planned.)
EOF
done

echo -e "${GREEN}✓ Created roadmap files${NC}"

# Create workflow-state
mkdir -p work/workflow-state
cat > work/workflow-state/active.md << EOF || error_exit "Failed to create work/workflow-state/active.md"
# Active Intent

**Intent ID:** none
**Status:** idle
**Current Phase:** none
**Started:** -

## Progress

- [ ] Phase 1: Analysis
- [ ] Phase 2: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 4: Verification
- [ ] Phase 5: Release Notes
EOF

cat > work/workflow-state/blocked.md << EOF || error_exit "Failed to create work/workflow-state/blocked.md"
# Blocked Intents

(No blocked intents yet.)
EOF

cat > work/workflow-state/validating.md << EOF || error_exit "Failed to create work/workflow-state/validating.md"
# Validating Intents

(No validating intents yet.)
EOF

cat > work/workflow-state/shipped.md << EOF || error_exit "Failed to create work/workflow-state/shipped.md"
# Shipped Intents

(No shipped intents yet.)
EOF

cat > work/workflow-state/disagreements.md << EOF || error_exit "Failed to create work/workflow-state/disagreements.md"
# Disagreements Log

(No disagreements yet.)
EOF

cat > work/workflow-state/assumptions.md << EOF || error_exit "Failed to create work/workflow-state/assumptions.md"
# Assumptions Log

This file tracks implicit assumptions that have been identified during development. Assumptions are where most outages hide—making them explicit and testable prevents surprises.

## Format

Each entry should include:
- **Assumption:** Clear statement of what is assumed
- **Context:** Where/when this assumption applies
- **Risk:** What breaks if assumption is wrong
- **Validation:** How to test/verify the assumption
- **Date:** When assumption was identified
- **Intent ID:** Related intent (if any)
- **Category:** Domain | Technical | Security

---

## Entries

(No assumptions logged yet. Assumptions will be added as they are identified during development.)
EOF

cat > work/workflow-state/01_analysis.md << EOF || error_exit "Failed to create work/workflow-state/01_analysis.md"
# Analysis

(Waiting for PM output.)
EOF

cat > work/workflow-state/02_plan.md << EOF || error_exit "Failed to create work/workflow-state/02_plan.md"
# Plan

(Waiting for Architect output.)
EOF

cat > work/workflow-state/03_implementation.md << EOF || error_exit "Failed to create work/workflow-state/03_implementation.md"
# Implementation

(Waiting for Implementer output.)
EOF

cat > work/workflow-state/04_verification.md << EOF || error_exit "Failed to create work/workflow-state/04_verification.md"
# Verification

(Waiting for QA/Security output.)
EOF

cat > work/workflow-state/05_release_notes.md << EOF || error_exit "Failed to create work/workflow-state/05_release_notes.md"
# Release Notes

(Waiting for Docs/Steward output.)
EOF

echo -e "${GREEN}✓ Created work/workflow-state files${NC}"

# Create golden-data directory with .gitkeep (directory already created on line 89)
touch _system/golden-data/.gitkeep
cat > _system/golden-data/README.md << EOF || error_exit "Failed to create _system/golden-data/README.md"
# Golden Data

This directory stores replay validation test data for regression testing.

## Purpose

Golden data captures known-good inputs and expected outputs that can be replayed through code changes to verify behavior hasn't regressed.

## Format

Golden data files are typically JSON files containing test cases:

\`\`\`json
[
  {
    "input": { /* input data */ },
    "expectedOutput": { /* expected result */ },
    "description": "Brief description of test case"
  }
]
\`\`\`

## Usage

1. **Capture golden data** from production or hand-crafted test cases
2. **Replay through code** during testing
3. **Compare outputs** to detect regressions

## Example

See \`docs/PLAN.md\` Research Q11 for implementation patterns and examples of replay-based validation.

## Non-Deterministic Data

For outputs with timestamps, UUIDs, or other non-deterministic values, normalize them before comparison:

\`\`\`typescript
const normalize = (output) => ({
  ...output,
  timestamp: 'NORMALIZED',
  id: 'NORMALIZED',
});
\`\`\`
EOF

echo -e "${GREEN}✓ Created _system/golden-data directory${NC}"

# Generate initial SYSTEM_STATE.md (best-effort)
if [ -x "scripts/generate-system-state.sh" ]; then
    ./scripts/generate-system-state.sh >/dev/null 2>&1 || echo "WARNING: system state generation failed"
fi

# Create drift baselines
mkdir -p _system/drift
cat > _system/drift/baselines.md << EOF || error_exit "Failed to create _system/drift baselines"
# Drift Baselines

Initial thresholds for drift detection.

## Baseline Metrics

| Metric | Baseline | Threshold |
|--------|----------|-----------|
| Avg PR size | < 10 files | > 15 files |
| Test-to-code ratio | > 0.5 | < 0.3 |
| Dependency count | < 50 deps | > 100 deps |

---

*Last updated: $(date -u +"%Y-%m-%d")*
EOF

echo -e "${GREEN}✓ Created drift baselines${NC}"

# Create .gitignore
cat > .gitignore << EOF || error_exit "Failed to create .gitignore"
node_modules/
dist/
*.log
.DS_Store
.env
.env.local
coverage/
.nyc_output/
*.tsbuildinfo
worktrees.json
.agent-id
__pycache__/
*.pyc
*.pyo
.pytest_cache/
EOF

echo -e "${GREEN}✓ Created .gitignore${NC}"

# Create .npmrc to align audit behavior with test expectations
cat > .npmrc << EOF || error_exit "Failed to create .npmrc"
audit-level=high
EOF

echo -e "${GREEN}✓ Created .npmrc${NC}"

# Tech stack specific setup
if [ "$TECH_STACK" = "typescript-nodejs" ]; then
    echo -e "${BLUE}Setting up TypeScript/Node.js...${NC}"
    
    # Create package.json
    cat > package.json << EOF || error_exit "Failed to create package.json"
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "version": "0.1.0",
  "description": "$PROJECT_DESC",
  "type": "module",
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:mutate": "stryker run",
    "lint": "eslint . --ext .ts",
    "typecheck": "tsc --noEmit",
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "new-intent": "./scripts/new-intent.sh",
    "scope-project": "./scripts/scope-project.sh",
    "generate-roadmap": "./scripts/generate-roadmap.sh",
    "generate-release-plan": "./scripts/generate-release-plan.sh",
    "drift-check": "./scripts/drift-check.sh",
    "deploy": "./scripts/deploy.sh",
    "check-readiness": "./scripts/check-readiness.sh",
    "workflow-orchestrator": "./scripts/workflow-orchestrator.sh",
    "kill-intent": "./scripts/kill-intent.sh",
    "verify": "./scripts/verify.sh",
    "fix": "./scripts/fix-intents.sh",
    "gh-create-issue": "./scripts/gh/create-issue-from-intent.sh",
    "gh-link-issue": "./scripts/gh/link-issue.sh",
    "gh-create-pr": "./scripts/gh/create-pr.sh",
    "on-ship-update-issue": "./scripts/gh/on-ship-update-issue.sh",
    "create-intent-from-issue": "./scripts/gh/create-intent-from-issue.sh",
    "help": "./scripts/help.sh",
    "status": "./scripts/status.sh",
    "suggest": "./scripts/suggest.sh",
    "dashboard": "./scripts/dashboard-start.sh",
    "execute-rollback": "./scripts/execute-rollback.sh",
    "export-dashboard-json": "node scripts/export-dashboard-json.js"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "@typescript-eslint/parser": "^6.15.0",
    "@stryker-mutator/core": "^8.0.0",
    "@stryker-mutator/vitest-runner": "^8.0.0",
    "@vitest/coverage-v8": "^1.0.4",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4"
  },
  "dependencies": {}
}
EOF

    # Create tsconfig.json
    cat > tsconfig.json << EOF || error_exit "Failed to create tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
EOF

    # Create .eslintrc.json
    cat > .eslintrc.json << EOF || error_exit "Failed to create .eslintrc.json"
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": ["./tsconfig.eslint.json"],
    "tsconfigRootDir": "."
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/strict-type-checked"
  ],
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/ban-types": "error",
    "no-eval": "error",
    "no-console": ["error", { "allow": ["warn", "error"] }]
  },
  "overrides": [
    {
      "files": ["scripts/**/*.ts", "tests/**/*.ts", "**/*.config.ts"],
      "rules": {
        "no-console": "off",
        "@typescript-eslint/no-unsafe-assignment": "off",
        "@typescript-eslint/no-unsafe-call": "off",
        "@typescript-eslint/no-unsafe-member-access": "off",
        "@typescript-eslint/no-unsafe-return": "off",
        "@typescript-eslint/no-unsafe-argument": "off"
      }
    }
  ],
  "ignorePatterns": ["dist", "node_modules", "*.config.js"]
}
EOF

    # Create tsconfig.eslint.json
    cat > tsconfig.eslint.json << EOF || error_exit "Failed to create tsconfig.eslint.json"
{
  "extends": "./tsconfig.json",
  "include": [
    "src/**/*.ts",
    "tests/**/*.ts",
    "scripts/**/*.ts",
    "dashboard-app/**/*.ts",
    "*.config.ts"
  ],
  "exclude": ["node_modules", "dist"]
}
EOF

    # Create vitest.config.ts
    cat > vitest.config.ts << EOF || error_exit "Failed to create vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'dist/',
        'tests/',
        '**/*.test.ts',
        '**/*.spec.ts',
        '**/*.config.ts',
      ],
    },
  },
});
EOF

    # Create basic src structure
    mkdir -p src
    cat > src/index.ts << EOF || error_exit "Failed to create src/index.ts"
// $PROJECT_NAME
// $PROJECT_DESC

export const projectName = '$PROJECT_NAME';
export const projectDescription = '$PROJECT_DESC';
EOF

    echo -e "${GREEN}✓ Created TypeScript/Node.js configuration${NC}"
fi

# Create CI/CD
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << EOF || error_exit "Failed to create CI workflow"
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm typecheck

  test:
    name: Test Suite
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:coverage
EOF

echo -e "${GREEN}✓ Created CI/CD configuration${NC}"

# Initialize git if not exists
if [ ! -d ".git" ]; then
    echo -e "${BLUE}Initializing git repository...${NC}"
    git init || error_exit "Failed to initialize git"
    git add . || error_exit "Failed to stage files"
    git commit -m "Initial commit: $PROJECT_NAME" || error_exit "Failed to create initial commit"
    echo -e "${GREEN}✓ Initialized git repository${NC}"
else
    echo -e "${YELLOW}Git repository already exists, skipping initialization${NC}"
fi

# Create AGENTS.md reference
cat > AGENTS.md << EOF || error_exit "Failed to create AGENTS.md"
# AGENTS.md

This project uses the ShipIt framework.

For agent roles, conventions, and workflows, see the framework documentation.

## Quick Reference

- **Create Intent:** Use \`/new_intent\` or \`pnpm new-intent\`
- **Ship Feature:** Use \`/ship <intent-id>\`
- **Verify:** Use \`/verify <intent-id>\`
- **Kill Intent:** Use \`/kill <intent-id>\`

## Project-Specific Settings

- **High-Risk Domains:** $(echo "$HIGH_RISK" | sed 's/,/, /g')
- **Tech Stack:** $STACK_NAME
- **Confidence Threshold:** 0.7

See \`project.json\` for full project metadata.
EOF

echo -e "${GREEN}✓ Created AGENTS.md${NC}"

# Create confidence-calibration.json
mkdir -p _system/artifacts
cat > _system/artifacts/confidence-calibration.json << EOF || error_exit "Failed to create _system/artifacts/confidence-calibration.json"
{
  "decisions": []
}
EOF

echo -e "${GREEN}✓ Created _system/artifacts/confidence-calibration.json${NC}"

# Usage (token/cost) artifact for visibility
cat > _system/artifacts/usage.json << 'USAGE_EOF' || error_exit "Failed to create _system/artifacts/usage.json"
{"entries":[]}
USAGE_EOF
echo -e "${GREEN}✓ Created _system/artifacts/usage.json${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Test project '$PROJECT_NAME' initialized!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Test project location: $TARGET_DIR${NC}"
echo -e "${YELLOW}Note: This is for internal ShipIt testing only.${NC}"
echo ""
