# ShipIt 🚀

> **Stop optimizing for humans. Start optimizing for AI.**

An AI-native Software Development Life Cycle that replaces meetings, docs, and handoffs with executable truth and state-anchored workflows.

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

# 2. Scope it (optional but smart)
/scope-project "Build a todo app with auth"

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
| `/deploy [env]` | Deploy with readiness checks |

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

## Prerequisites

- **Cursor IDE** (designed for Cursor's AI features)
- **Node.js 20+**
- **pnpm** (or npm/yarn)
- **Git**

## Documentation

- **[AGENTS.md](./AGENTS.md)** - Role definitions and conventions
- **[PLAN.md](./PLAN.md)** - Full implementation plan (deep dive)
- **[architecture/CANON.md](./architecture/CANON.md)** - Architecture boundaries
- **[architecture/invariants.yml](./architecture/invariants.yml)** - Machine-verifiable constraints

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

## License

MIT

---

**Ready?** Start with `/init-project "My Project"` and see what happens. 🎉
