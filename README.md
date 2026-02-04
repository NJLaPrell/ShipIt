<p align="center">
  <img src="shipit.png" width="240" alt="ShipIt logo">
</p>

# ShipIt 🚀

[![Version](https://img.shields.io/badge/version-0.2.1-blue.svg)](https://github.com/NJLaPrell/ShipIt/releases/tag/v0.2.1)
[![Test Status](https://img.shields.io/badge/tests-97.6%25%20passing-green.svg)](./tests/ISSUES.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> **Stop optimizing for humans. Start optimizing for AI.**

An AI-native Software Development Life Cycle that replaces meetings, docs, and handoffs with executable truth and state-anchored workflows.

**Status:** ✅ **Production Ready** - Fully validated with 97.6% test pass rate (82/84 tests passing)

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Quick Start](#quick-start-30-seconds)
- [Workflow Diagram](#workflow-diagram)
- [How It Works](#how-it-works)
  - [The Workflow](#the-workflow)
  - [The Agents](#the-agents)
- [Commands](#commands)
- [Example: Ship a Feature](#example-ship-a-feature)
- [Project Structure](#project-structure)
- [Key Concepts](#key-concepts)
  - [Intent Ledger](#intent-ledger)
  - [Truth Hierarchy](#truth-hierarchy)
  - [Tests First](#tests-first-critical)
  - [High-Risk Gates](#high-risk-gates)
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Documentation](#documentation)
- [Validation & Testing](#validation--testing)
- [FAQ](#faq)
- [Version History](#version-history)
- [License](#license)

## The Problem

Traditional SDLC assumes humans are the bottleneck. But AI agents don't need:

- ❌ Status meetings → They need **state files**
- ❌ Documentation → They need **executable tests**
- ❌ Handoffs → They need **explicit gates**
- ❌ Institutional memory → They need **do-not-repeat ledgers**

**The insight:** Most failures aren't coding errors—they're unstated assumptions, ambiguous truth sources, and forgotten constraints.

## The Solution

A framework that optimizes for _epistemology_, not coordination:

- 🎯 **Executable Truth** - Tests and invariants replace documentation
- 📁 **State-Anchored** - Workflow state in files, not meetings
- 🔍 **Adversarial Verification** - Multiple agents try to break things
- 📋 **Intent Ledger** - Planned work in `/intent/{features,bugs,tech-debt}` (not tickets)
- 🚪 **Automated Gates** - CI/CD enforces quality
- 📊 **Drift Detection** - Entropy monitoring prevents decay
- ✅ **Auto-Validation** - Proactive validation and auto-fix for common issues
- 🔄 **Smart Chaining** - Scripts automatically run dependent generators
- 📈 **Progress Tracking** - Clear indicators during long-running operations
- 💡 **Context-Aware** - Intelligent next-step suggestions based on project state

## Quick Start (30 seconds)

```bash
# 1. Initialize a project
/init-project "My Awesome App"
# → Creates ./projects/my-awesome-app
# → Includes framework commands/rules and core scripts
# Prompts:
# 1) Tech stack [1=TS/Node, 2=Python, 3=Other]
# 2) Project description (short)
# 3) High-risk domains (comma-separated or 'none')

# 2. Scope it (optional but smart)
/scope-project "Build a todo app with auth"
# → Shows all questions at once with defaults (batched prompts)
# → Review answers, confirm, and select features to generate as intents
# → Auto-runs: /generate-release-plan and /generate-roadmap
# → Shows verification summary and next-step suggestions

# 3. Ship a feature
/ship F-001
```

That's it. The framework handles the rest through 5 automated phases with progress indicators.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ShipIt Workflow                                  │
└─────────────────────────────────────────────────────────────────────────┘

SETUP PHASE
    │
    ├─ /init-project "Project Name"
    │   └─ Creates project structure, copies framework files
    │
    ├─ /scope-project "Description"
    │   └─ AI-assisted feature breakdown → generates intents
    │   └─ Auto-runs: /generate-release-plan, /generate-roadmap
    │   └─ Shows verification summary and next-step suggestions
    │
    └─ /status
        └─ Unified dashboard: intents, workflow phase, test results

PLANNING PHASE
    │
    ├─ /new_intent
    │   └─ Creates intent file in subfolders (F-001.md, B-002.md, etc.)
    │
    ├─ /generate-release-plan
    │   └─ Orders intents by dependencies, priorities, release targets
    │   └─ Validates dependencies, shows warnings
    │   └─ Suggests next steps
    │
    ├─ /generate-roadmap
    │   └─ Categorizes intents: now/next/later
    │   └─ Suggests next steps
    │
    └─ /fix
        └─ Auto-fixes: dependency ordering, whitespace issues
        └─ Shows preview before applying fixes

EXECUTION PHASE
    │
    ├─ /ship <intent-id>
    │   │
    │   ├─ [Phase 1/5] Analysis... ⏳
    │   │   └─ PM agent: Requirements clarity, confidence scoring
    │   │
    │   ├─ [Phase 2/5] Planning... ⏳
    │   │   └─ Architect: System design, CANON compliance
    │   │   └─ ⚠️ Human approval gate for high-risk domains
    │   │
    │   ├─ [Phase 3/5] Implementation... ⏳
    │   │   └─ QA: Writes tests first (they fail initially)
    │   │   └─ Implementer: Writes code (tests pass)
    │   │
    │   ├─ [Phase 4/5] Verification... ⏳
    │   │   └─ QA: Adversarial testing
    │   │   └─ Security: Threat modeling, audit
    │   │
    │   └─ [Phase 5/5] Release... ⏳
    │       └─ Docs: Updates README/CHANGELOG
    │       └─ Steward: Final approval
    │
    ├─ /verify <intent-id>
    │   └─ Re-run verification phase only
    │
    └─ /status
        └─ Check current phase, test results, recent changes

MAINTENANCE PHASE
    │
    ├─ /drift_check
    │   └─ Calculates: PR size, test-to-code ratio, dependency growth
    │
    ├─ /deploy [environment]
    │   └─ Runs readiness checks (tests, lint, typecheck, audit, docs)
    │   └─ Deploys to platform (Vercel, Netlify, Docker, AWS CDK, Manual)
    │
    └─ /kill <intent-id>
        └─ Permanently stops work with rationale

UTILITY COMMANDS
    │
    ├─ /help
    │   └─ Lists all commands with descriptions
    │
    ├─ /suggest
    │   └─ Suggests next intent to work on
    │
    └─ /test_shipit
        └─ Runs end-to-end test suite
```

## How It Works

### The Workflow

```
Intent → Analysis → Planning → Tests → Code → Verify → Release
```

### Security Audit Allowlist

Security checks use `scripts/audit-check.sh` with a default threshold of moderate.
If you need to temporarily accept a known advisory, add it to `security/audit-allowlist.json`
with a reason and an expiry date.

### Confidence Calibration

The `artifacts/confidence-calibration.json` file tracks confidence scores vs actual outcomes to improve calibration over time.

**Schema:**

```json
{
  "decisions": [
    {
      "id": "D-001",
      "stated_confidence": 0.85,
      "actual_outcome": "success",
      "notes": "Shipped without issues"
    }
  ]
}
```

**Fields:**

- `id`: Unique decision identifier (e.g., "D-001")
- `stated_confidence`: Confidence score (0.0-1.0) stated during analysis
- `actual_outcome`: "success" or "failure"
- `notes`: Optional notes about the outcome

Entries are automatically appended during `/verify` when outcomes are determined.

1. **You define what** (intent file)
2. **PM clarifies requirements** (executable acceptance criteria)
3. **Architect designs approach** (plan with approval gate)
4. **QA writes tests first** (they fail initially - that's good!)
5. **Implementer writes code** (makes tests pass)
6. **QA + Security verify** (adversarial validation)
7. **Docs + Steward approve** (documentation + final check)

**Progress Tracking:** Each phase shows `[Phase X/5] PhaseName... ⏳` while running and `✓` when complete, so you always know what's happening.

### The Agents

7 specialized AI agents, each with a clear role:

| Role            | Job                                | Can't Do                         |
| --------------- | ---------------------------------- | -------------------------------- |
| **Steward**     | Executive brain, veto power        | Write code                       |
| **PM**          | Intent clarity, confidence scoring | Change architecture              |
| **Architect**   | System design, CANON compliance    | Write production code            |
| **Implementer** | Code execution                     | Change architecture, write tests |
| **QA**          | Break things (adversarial)         | Weaken acceptance criteria       |
| **Security**    | Threat modeling, red team          | Waive findings                   |
| **Docs**        | Keep docs current                  | Change code behavior             |

## Commands

### Setup & Planning

| Command                  | What It Does                                                | When to Use                        |
| ------------------------ | ----------------------------------------------------------- | ---------------------------------- |
| `/init-project [name]`   | Create a new project with full structure                    | Start of new project               |
| `/scope-project [desc]`  | AI-assisted feature breakdown with batched prompts          | After init, to break down features |
| `/new_intent`            | Create a feature/bug/tech-debt intent                       | When planning new work             |
| `/generate-release-plan` | Build release plan from intents (auto-validates)            | After creating/updating intents    |
| `/generate-roadmap`      | Generate roadmap (now/next/later)                           | After creating/updating intents    |
| `/fix`                   | Auto-fix intent issues (dependency ordering, whitespace)    | When validation shows issues       |
| `/status`                | Unified dashboard: intents, workflow, tests, recent changes | Anytime to check project state     |
| `/pr <id>`               | Generate PR summary/checklist                               | Before opening a PR                |
| `/risk <id>`             | Force security/threat skim                                  | Before release or high-risk change |
| `/revert-plan <id>`      | Write rollback plan                                         | Before implementation or release   |

### Execution

| Command        | What It Does                                               | When to Use                       |
| -------------- | ---------------------------------------------------------- | --------------------------------- |
| `/ship <id>`   | Run full SDLC workflow (5 phases with progress indicators) | To implement an intent            |
| `/verify <id>` | Re-run verification phase only                             | After code changes                |
| `/kill <id>`   | Kill an intent (with rationale)                            | When work should stop permanently |

### Maintenance

| Command         | What It Does                                        | When to Use                    |
| --------------- | --------------------------------------------------- | ------------------------------ |
| `/drift_check`  | Check for entropy/decay (PR size, test ratio, deps) | Periodically to monitor health |
| `/deploy [env]` | Deploy with readiness checks                        | When ready to release          |
| `/test_shipit`  | Run end-to-end test suite                           | To validate framework itself   |

### Utilities

| Command    | What It Does                         | When to Use                 |
| ---------- | ------------------------------------ | --------------------------- |
| `/help`    | Lists all commands with descriptions | When you need a reminder    |
| `/suggest` | Suggests next intent to work on      | When unsure what to do next |

**Note:** All commands show context-aware next-step suggestions after completion. Scripts auto-verify outputs and run dependent generators (e.g., `/scope-project` automatically runs `/generate-release-plan` and `/generate-roadmap`).

All commands are available as Cursor slash commands. See [`.cursor/commands/`](./.cursor/commands/) for full documentation.

## Example: Ship a Feature

```bash
# Create an intent
/new_intent
# → Creates intent/features/F-001.md with template

# Fill it in (type, motivation, acceptance criteria, etc.)

# Ship it!
/ship F-001

# Watch the magic happen:
# [Phase 1/5] Analysis... ⏳
# ✅ PM analyzes requirements
# [Phase 2/5] Planning... ⏳
# ✅ Architect proposes plan (needs your approval)
# [Phase 3/5] Implementation... ⏳
# ✅ QA writes tests (they fail - perfect!)
# ✅ Implementer writes code (tests pass!)
# [Phase 4/5] Verification... ⏳
# ✅ QA + Security verify
# [Phase 5/5] Release... ⏳
# ✅ Docs update README/CHANGELOG
# ✅ Steward approves
# ✅ Done!
#
# 💡 Next steps: Review release notes, deploy, or start next intent
```

## Project Structure

```
.
├── intent/              # What to build (features/bugs/tech-debt)
│   ├── features/        # Feature intents (F-###.md)
│   ├── bugs/            # Bug intents (B-###.md)
│   └── tech-debt/       # Tech-debt intents (T-###.md)
├── workflow-state/      # Current execution state (active + phase files)
├── artifacts/           # Generated files
│   ├── SYSTEM_STATE.md  # Auto-generated summary for Steward
│   ├── dependencies.md  # Generated dependency graph
│   └── confidence-calibration.json
├── architecture/        # CANON.md (boundaries) + invariants.yml
├── do-not-repeat/      # Failed approaches (don't rediscover)
├── drift/              # Entropy monitoring
└── roadmap/            # now.md, next.md, later.md
```

### Planning outputs

Generated planning artifacts and how they relate:

| Output               | Location                               | Purpose                                             | Generated by               |
| -------------------- | -------------------------------------- | --------------------------------------------------- | -------------------------- |
| **Release plan**     | `release/plan.md`                      | What ships when — intents ordered by release target | `generate-release-plan.sh` |
| **Roadmap**          | `roadmap/` (now.md, next.md, later.md) | Triage view — now / next / later                    | `generate-roadmap.sh`      |
| **Dependency graph** | `artifacts/dependencies.md`            | Graph of intent dependencies                        | `generate-roadmap.sh`      |

## Key Concepts

### Intent Ledger

All work lives in `/intent/` as markdown files under `features/`, `bugs/`, or `tech-debt`. Each intent has:

- Executable acceptance criteria (not "looks good")
- Confidence scores (requirements + domain assumptions)
- Invariants (hard constraints, dual form: human + executable)
- Kill criteria (explicit stop conditions)
- Rollback plan (required before implementation)

**Validation & Auto-Fix:** The framework proactively validates intents for common issues (dependency ordering conflicts, whitespace formatting, missing dependencies, circular dependencies). Use `/fix` to auto-fix issues with a preview before applying changes.

### Truth Hierarchy

When facts conflict, this is the order of precedence:

1. **Runtime behavior** (what actually happens)
2. **Tests** (executable assertions)
3. **Invariants** (hard constraints)
4. **Specs** (requirements)
5. **Architecture canon** (boundaries)
6. **Comments** (annotations)
7. **Human opinion** (last resort)

> **Rule:** If tests contradict comments, tests win. If runtime contradicts tests, that's a bug—runtime is truth, tests are intent.

### Tests First (Critical!)

```
Spec → Tests → Code
```

Tests MUST exist BEFORE production code. The workflow enforces this:

1. QA writes tests (Phase 3)
2. Tests fail initially (nothing to pass yet)
3. Implementer writes code (Phase 4)
4. Tests pass ✅

### High-Risk Gates

These domains require human approval:

- 🔐 Authentication
- 💰 Payments
- 🔑 Permissions/RBAC
- 🏗️ Infrastructure
- 📋 PII handling

## Installation

```bash
# Clone the repository
git clone https://github.com/NJLaPrell/ShipIt.git
cd ShipIt

# Install dependencies
pnpm install

# Validate Cursor integration
pnpm validate-cursor
```

## Prerequisites

- **Cursor IDE** (designed for Cursor's AI features)
- **Node.js 20+**
- **pnpm** (or npm/yarn)
- **Git**

## Documentation

- **[AGENTS.md](./AGENTS.md)** - Role definitions and conventions
- **[DIRECTORY_STRUCTURE.md](./DIRECTORY_STRUCTURE.md)** - Quick reference for project layout
- **[PILOT_GUIDE.md](./PILOT_GUIDE.md)** - Step-by-step guide for your first feature
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and changes
- **[architecture/CANON.md](./architecture/CANON.md)** - Architecture boundaries
- **[architecture/invariants.yml](./architecture/invariants.yml)** - Machine-verifiable constraints
- **[tests/ISSUES.md](./tests/ISSUES.md)** - Test results and validation status
- **[tests/README.md](./tests/README.md)** - Test structure (code, fixtures, logs, process docs)
- **[projects/README.md](./projects/README.md)** - Purpose of `projects/` (initialized projects)

## Validation & Testing

The framework has been fully validated end-to-end:

- ✅ **97.6% test pass rate** (82/84 tests passing)
- ✅ **9/9 features validated** (100%)
- ✅ **5/5 workflow phases** validated (100%)
- ✅ **Comprehensive test suite** covering all core functionality
- ✅ **End-to-end validation** complete

See [tests/ISSUES.md](./tests/ISSUES.md) for detailed test results and [tests/TEST_PLAN.md](./tests/TEST_PLAN.md) for the full test plan.

## FAQ

**Q: Do I need to understand all 7 agents?**  
A: Nope. Just use the commands. The agents handle their roles automatically during `/ship`.

**Q: What if I want to skip a phase?**  
A: Don't. The gates exist for a reason. If something feels wrong, use `/kill` instead.

**Q: Can I use this for existing projects?**  
A: Yes! Run `/init-project` in a subdirectory or adapt the structure.

**Q: What about deployment?**  
A: Use `/deploy` when ready. It runs readiness checks first.

**Q: How do I contribute to the framework itself?**  
A: Create an intent and `/ship` it! The framework eats its own dog food.

**Q: Is this production-ready?**  
A: Yes! Version 0.1.0 is released and fully validated. See [tests/ISSUES.md](./tests/ISSUES.md) for validation results.

**Q: How do I test the framework?**  
A: Run `/test_shipit` to execute the full end-to-end test suite.

## Version History

- **v0.2.1** (2026-02-04) - Patch release (version consistency)
- **v0.2.0** (2026-01-27) - UX Enhancements Release
  - **New Features:**
    - Intent validation and auto-fix (`/fix` command)
    - Output verification system with automatic generator chaining
    - Unified status dashboard (`/status` command)
    - Progress indicators for long-running operations
    - Batched interactive prompts (faster scoping workflow)
    - Context-aware next-step suggestions
  - **Improvements:**
    - Enhanced `/scope-project` with batched prompts
    - Enhanced `/generate-release-plan` with validation warnings
    - Enhanced `/generate-roadmap` with verification summaries
    - Enhanced `/ship` workflow with progress indicators
    - Improved error handling and edge case coverage
  - **Fixes:**
    - Fixed numeric validation in dependency ordering checks
    - Fixed temp file cleanup in fix-intents.sh
    - Fixed false positive grep matches in suggest-next.sh
    - Fixed fragile test parsing in status.sh
    - Removed extraneous documentation files
    - Updated outdated references

- **v0.1.0** (2026-01-23) - Initial release
  - Complete AI-native SDLC framework
  - Project initialization and scoping
  - Intent management and workflow orchestration
  - Release planning and roadmap generation
  - Comprehensive test suite with 97.6% pass rate

See [CHANGELOG.md](./CHANGELOG.md) for detailed version history.

## License

MIT

---

**Ready?** Start with `/init-project "My Project"` and see what happens. 🎉

**New to ShipIt?** Check out [PILOT_GUIDE.md](./PILOT_GUIDE.md) for a step-by-step walkthrough.
