<p align="center">
  <img src="shipit.png" width="240" alt="ShipIt logo">
</p>

# ShipIt 🚀

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/NJLaPrell/ShipIt/releases/tag/v0.1.0)
[![Test Status](https://img.shields.io/badge/tests-97.6%25%20passing-green.svg)](./tests/ISSUES.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> **Stop optimizing for humans. Start optimizing for AI.**

An AI-native Software Development Life Cycle that replaces meetings, docs, and handoffs with executable truth and state-anchored workflows.

**Status:** ✅ **Production Ready** - Fully validated with 97.6% test pass rate (82/84 tests passing)

## The Problem

Traditional SDLC assumes humans are the bottleneck. But AI agents don't need:
- ❌ Status meetings → They need **state files**
- ❌ Documentation → They need **executable tests**
- ❌ Handoffs → They need **explicit gates**
- ❌ Institutional memory → They need **do-not-repeat ledgers**

**The insight:** Most failures aren't coding errors—they're unstated assumptions, ambiguous truth sources, and forgotten constraints.

## The Solution

A framework that optimizes for *epistemology*, not coordination:

- 🎯 **Executable Truth** - Tests and invariants replace documentation
- 📁 **State-Anchored** - Workflow state in files, not meetings
- 🔍 **Adversarial Verification** - Multiple agents try to break things
- 📋 **Intent Ledger** - Planned work in `/intent/` (not tickets)
- 🚪 **Automated Gates** - CI/CD enforces quality
- 📊 **Drift Detection** - Entropy monitoring prevents decay

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
# → You will answer follow-up questions and select features to generate as intents

# 3. Ship a feature
/ship F-001
```

That's it. The framework handles the rest through 6 automated phases.

## How It Works

### The Workflow

```
Intent → Analysis → Planning → Tests → Code → Verify → Release
```

1. **You define what** (intent file)
2. **PM clarifies requirements** (executable acceptance criteria)
3. **Architect designs approach** (plan with approval gate)
4. **QA writes tests first** (they fail initially - that's good!)
5. **Implementer writes code** (makes tests pass)
6. **QA + Security verify** (adversarial validation)
7. **Docs + Steward approve** (documentation + final check)

### The Agents

7 specialized AI agents, each with a clear role:

| Role | Job | Can't Do |
|------|-----|----------|
| **Steward** | Executive brain, veto power | Write code |
| **PM** | Intent clarity, confidence scoring | Change architecture |
| **Architect** | System design, CANON compliance | Write production code |
| **Implementer** | Code execution | Change architecture, write tests |
| **QA** | Break things (adversarial) | Weaken acceptance criteria |
| **Security** | Threat modeling, red team | Waive findings |
| **Docs** | Keep docs current | Change code behavior |

## Commands

| Command | What It Does |
|---------|--------------|
| `/init-project [name]` | Create a new project with full structure |
| `/scope-project [desc]` | AI-assisted feature breakdown |
| `/new_intent` | Create a feature/bug/tech-debt intent |
| `/ship <id>` | Run full SDLC workflow (6 phases) |
| `/verify <id>` | Re-run verification phase |
| `/kill <id>` | Kill an intent (with rationale) |
| `/drift_check` | Check for entropy/decay |
| `/generate-release-plan` | Build release plan from intents |
| `/generate-roadmap` | Generate roadmap (now/next/later) |
| `/deploy [env]` | Deploy with readiness checks |
| `/test_shipit` | Run end-to-end test suite |

All commands are available as Cursor slash commands. See [`.cursor/commands/`](./.cursor/commands/) for full documentation.

## Example: Ship a Feature

```bash
# Create an intent
/new_intent
# → Creates F-001.md with template

# Fill it in (type, motivation, acceptance criteria, etc.)

# Ship it!
/ship F-001

# Watch the magic happen:
# ✅ PM analyzes requirements
# ✅ Architect proposes plan (needs your approval)
# ✅ QA writes tests (they fail - perfect!)
# ✅ Implementer writes code (tests pass!)
# ✅ QA + Security verify
# ✅ Docs update README/CHANGELOG
# ✅ Steward approves
# ✅ Done!
```

## Project Structure

```
.
├── intent/              # What to build (F-001.md, B-002.md, etc.)
├── workflow-state/      # Current execution state (6 phase files)
├── architecture/        # CANON.md (boundaries) + invariants.yml
├── do-not-repeat/      # Failed approaches (don't rediscover)
├── drift/              # Entropy monitoring
└── roadmap/            # now.md, next.md, later.md
```

## Key Concepts

### Intent Ledger
All work lives in `/intent/` as markdown files. Each intent has:
- Executable acceptance criteria (not "looks good")
- Confidence scores (requirements + domain assumptions)
- Invariants (hard constraints, dual form: human + executable)
- Kill criteria (explicit stop conditions)
- Rollback plan (required before implementation)

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
- **[PILOT_GUIDE.md](./PILOT_GUIDE.md)** - Step-by-step guide for your first feature
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and changes
- **[architecture/CANON.md](./architecture/CANON.md)** - Architecture boundaries
- **[architecture/invariants.yml](./architecture/invariants.yml)** - Machine-verifiable constraints
- **[tests/ISSUES.md](./tests/ISSUES.md)** - Test results and validation status

## Validation & Testing

The framework has been fully validated end-to-end:

- ✅ **97.6% test pass rate** (82/84 tests passing)
- ✅ **9/9 features validated** (100%)
- ✅ **6/6 workflow phases** validated (100%)
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
