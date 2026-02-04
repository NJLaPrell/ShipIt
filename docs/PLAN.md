# ShipIt Implementation Plan

> **Goal:** Build an AI agent team that operates within Cursor, using a fundamentally different SDLC optimized for AI capabilities rather than human limitations.

---

## Executive Summary

Traditional SDLC is designed around scarce human attention, slow feedback loops, and fragile institutional memory. AI agents have the opposite constraints. This plan implements an **AI-native SDLC** that:

- Replaces documentation with **executable truth**
- Replaces meetings with **repo-anchored state**
- Replaces reviews with **adversarial verification**
- Replaces tickets with an **Intent Ledger**
- Replaces human bottlenecks with **automated gates**

**The fundamental insight:** Human SDLC optimizes _coordination_. AI SDLC must optimize _epistemology_. Most failures aren't coding errors—they're unstated assumptions, ambiguous truth sources, conflicting incentives, and forgotten constraints.

---

## Core Principles

| Human SDLC                          | AI SDLC                            |
| ----------------------------------- | ---------------------------------- |
| Humans need communication artifacts | AI needs executable truth          |
| Humans forget                       | AI must be state-anchored          |
| Humans debate                       | AI must prove                      |
| Humans review occasionally          | AI must review continuously        |
| Humans multitask poorly             | AI parallelizes by default         |
| Humans intuit cost                  | AI must have explicit cost signals |
| Humans rely on institutional memory | AI needs explicit failure memory   |
| Humans hand-wave uncertainty        | AI must label it precisely         |

### The 5 Stabilizers (Non-Negotiable)

1. **Permanent Steward Agent** — One brain owns global coherence with veto power
2. **Kill Criteria** — Every intent has explicit stop conditions
3. **Drift Detection** — Entropy monitoring to prevent slow decay
4. **Confidence Thresholds** — Agents must score uncertainty and escalate
5. **Humans as Interrupts** — Human involvement only at defined gates

### What We Remove Entirely (Human SDLC Artifacts)

- ❌ Status meetings
- ❌ Long design docs (replace with executable specs)
- ❌ Manual test plans (replace with automated checks)
- ❌ Static "definition of done" (replace with acceptance tests)
- ❌ Handwritten change logs (auto-generate from intents)
- ❌ PR-based review conversations (replace with automated gates)

---

## Truth Hierarchy (CRITICAL)

When facts conflict, agents MUST know which source wins. This prevents 30–40% of "AI confusion" bugs.

**Truth Stack (highest to lowest precedence):**

1. **Runtime behavior** — What the system actually does
2. **Tests** — Executable assertions
3. **Invariants** — Hard constraints that must never be violated
4. **Specs** — Formal requirements
5. **Architecture canon** — CANON.md boundaries
6. **Comments** — Human annotations in code
7. **Human opinion** — Always last

> **Rule:** If tests contradict comments, tests win. If runtime contradicts tests, that's a bug to fix—runtime is truth, tests are intent.

---

## Cost-Awareness (First-Class Signal)

AI does not intuit cost. Agents must reject solutions that are correct but wasteful.

**Required Cost Signals:**

| Signal                           | Enforcement                       |
| -------------------------------- | --------------------------------- |
| Token budgets per agent          | Reject prompts exceeding budget   |
| Latency budgets per feature      | Fail verification if p95 exceeded |
| Cloud cost ceilings              | Automated alerts + blocking       |
| "Cost delta" per design decision | Architect must justify increases  |

> **Rule:** Humans optimize after shipping. AI must optimize before.

---

## Negative Knowledge Repository ("Do Not Repeat" Ledger)

Human teams rely on institutional memory. AI needs explicit failure memory to prevent cyclic rediscovery and regression.

**Store in `/do-not-repeat/`:**

- Abandoned designs (and why)
- Failed experiments (with evidence)
- Known bad patterns
- Rejected libraries (and rationale)
- Architectural dead ends
- Previous bugs that recurred

> **Rule:** Before proposing a solution, agents MUST check the Do Not Repeat ledger. Rediscovering a killed approach without new evidence is a failure.

---

## Time-Scale Separation

Different work operates at different speeds. Mixing them causes tactical agents to override strategic intent.

| Loop       | Scope                     | Duration         | Agent Focus            |
| ---------- | ------------------------- | ---------------- | ---------------------- |
| **Fast**   | Refactors, tests, linting | Seconds          | Implementer, QA        |
| **Medium** | Feature work, bug fixes   | Minutes to hours | All operational agents |
| **Slow**   | Architecture evolution    | Hours to days    | Architect, Steward     |

> **Rule:** Fast loop agents cannot modify slow loop artifacts (CANON.md, ADRs) without explicit Steward approval.

---

## Memory & State Discipline

Humans forget accidentally. AI forgets deterministically unless told not to.

**State Governance Questions (answer for every system):**

1. What must persist across sessions?
2. What must be forgotten (privacy, cache invalidation)?
3. What must never be inferred (must be explicit)?

**Artifacts:**

| Artifact                 | Purpose                                   |
| ------------------------ | ----------------------------------------- |
| Memory contracts         | Define what state survives context resets |
| Context boundaries       | Define what each agent can/cannot see     |
| Cache invalidation rules | When stale data must be purged            |

> **Rule:** If an agent assumes something not in explicit state files, that's a bug in the agent's prompt.

---

## Repository Structure

```
/
├── AGENTS.md                          # Tool-agnostic "how this repo works"
├── intent/                            # The Intent Ledger (replaces tickets)
│   ├── features/
│   │   └── F-###-title.md
│   ├── bugs/
│   │   └── B-###-title.md
│   └── tech-debt/
│       └── T-###-title.md
├── workflow-state/                    # Live execution state
│   ├── active.md                      # Currently being worked on
│   ├── blocked.md                     # Waiting on dependencies/decisions
│   ├── validating.md                  # In verification phase
│   ├── shipped.md                     # Completed and merged
│   ├── disagreements.md               # Agent disagreement log (see Research Q12)
│   ├── 01_analysis.md                 # Phase 1 output for current work
│   ├── 02_plan.md                     # Phase 2 output for current work
│   ├── 03_implementation.md           # Phase 3 notes
│   ├── 04_verification.md             # Phase 4 proof
│   ├── 05_release_notes.md            # Phase 5 output
│   └── agent-<id>.md                  # Per parallel-agent notes
├── architecture/                      # Canonical architecture
│   ├── CANON.md                       # Boundaries, allowed deps, forbidden patterns
│   ├── invariants.yml                 # Machine-verifiable hard constraints
│   └── ADR-###.md                     # Architecture Decision Records
├── do-not-repeat/                     # Negative knowledge repository
│   ├── abandoned-designs.md
│   ├── failed-experiments.md
│   ├── bad-patterns.md
│   └── rejected-libraries.md
├── drift/                             # Entropy monitoring
│   ├── metrics.md                     # Weekly snapshot of indicators
│   └── baselines.md                   # Acceptable ranges/thresholds
├── roadmap/                           # Planning views (reference intent IDs)
│   ├── now.md                         # Current sprint/focus
│   ├── next.md                        # Queued work
│   └── later.md                       # Backlog
├── .cursor/
│   ├── rules/                         # Cursor project rules (MDC format)
│   │   ├── steward.mdc                # Executive brain, veto authority
│   │   ├── pm.mdc                     # Intent writer, requirements clarity
│   │   ├── architect.mdc              # Design, constraints, ADRs
│   │   ├── implementer.mdc            # Code execution only
│   │   ├── qa.mdc                     # Tests first, adversarial validation
│   │   ├── security.mdc               # Threat modeling, attack surface
│   │   ├── docs.mdc                   # Documentation, release notes
│   │   └── assumption-extractor.mdc   # Surfaces implicit assumptions
│   └── commands/                      # Cursor slash commands
│       ├── new_intent.md
│       ├── ship.md
│       ├── verify.md
│       ├── drift_check.md
│       ├── kill.md
│       ├── pr.md                      # Generate PR description + checklist
│       ├── risk.md                    # Force security/threat skim
│       └── revert-plan.md             # Write rollback strategy
├── scripts/
│   ├── drift-check.sh                 # Calculate drift metrics (see Research Q5)
│   ├── setup-worktrees.sh             # Setup parallel worktrees (see Research Q2)
│   └── generate-system-state.sh       # Auto-generate SYSTEM_STATE.md summary
├── golden-data/                       # Replay validation test data (see Research Q11)
│   └── .gitkeep
├── SYSTEM_STATE.md                    # Auto-generated summary for Steward (see Research Q7)
├── confidence-calibration.json        # Track confidence vs outcomes (see Research Q6)
└── .agent-id                          # Parallel agent coordination (per worktree)
```

---

## Agent Roles & Responsibilities

### Role Purity Rules (CRITICAL)

> Any agent that can mark its own homework will cheat—deterministically.

| Agent                    | Can Do                                      | Cannot Do                         |
| ------------------------ | ------------------------------------------- | --------------------------------- |
| **Steward**              | Veto, block, kill intents; review drift     | Write production code             |
| **PM**                   | Write intents, set acceptance criteria      | Change architecture               |
| **Architect**            | Update CANON.md, write ADRs, propose design | Implement beyond scaffolding      |
| **Implementer**          | Write production code                       | Change architecture canon         |
| **QA**                   | Write tests, adversarial validation         | Weaken acceptance to pass         |
| **Security**             | Threat analysis, find vulnerabilities       | Waive findings without mitigation |
| **Docs**                 | Update docs, release notes                  | Change code behavior              |
| **Assumption Extractor** | Surface implicit assumptions                | Make implementation decisions     |

### Agent Definitions

#### Steward (Executive Brain)

- **Purpose:** Owns global coherence over time
- **Powers:** Veto, block, or kill any intent
- **Reads First:** Everything (/intent, /workflow-state, /architecture, /drift, /do-not-repeat)
- **Key Function:** Prevents "locally correct, globally incoherent" code
- **Outputs:** Approval/block/kill decisions with rationale

#### PM (Product Manager)

- **Purpose:** Intent clarity and confidence scoring
- **Outputs:** Intent files with acceptance criteria, confidence scores
- **Key Function:** Translates requirements into executable truth
- **Must Include:** Success metrics, invariants in dual form (human-readable + executable checks)

#### Architect

- **Purpose:** System design and constraint enforcement
- **Outputs:** CANON.md updates, ADRs, design proposals
- **Key Function:** Prevents architectural drift
- **Constraint:** Must check /do-not-repeat before proposing designs

#### Implementer

- **Purpose:** Code execution of approved plans
- **Constraint:** Can ONLY implement the approved plan—deviations return to Phase 2
- **Key Function:** Fast, parallel code production
- **Must Follow:** Spec → Tests → Code order (tests exist BEFORE production code)

#### QA (Quality Assurance)

- **Purpose:** Adversarial validation—tries to break the implementation
- **Method:** Tests first, then implementation verification
- **Key Function:** Proves correctness, doesn't assume it
- **Outputs:** Test cases, mutation testing results, edge case analysis

#### Security

- **Purpose:** Threat modeling and attack surface review
- **Focus:** Auth, input validation, secrets, PII, dependencies
- **Key Function:** Red team for every sensitive change
- **Cannot:** Waive findings—must propose mitigations

#### Docs

- **Purpose:** Documentation and release notes
- **Outputs:** README updates, ADR references, changelogs
- **Key Function:** Keeps documentation current automatically

#### Assumption Extractor (Continuous)

- **Purpose:** Surfaces implicit assumptions before they become bugs
- **Questions it asks:**
  - "What did we assume but not state?"
  - "What would break if X changed?"
  - "Is this a domain rule or an implementation detail?"
- **Outputs:** Assumptions logged, versioned, and made testable
- **Key Insight:** Assumptions are where most outages hide

### Adversarial Swarm (Parallel Verification)

During verification, run these agents simultaneously to attack the implementation:

| Agent                        | Mission                                |
| ---------------------------- | -------------------------------------- |
| 🧠 **Architect**             | "Does this violate system boundaries?" |
| 🧪 **Test Adversary**        | "What inputs break this?"              |
| 🔐 **Security Attacker**     | "How would I exploit this?"            |
| 🐢 **Performance Degrader**  | "What makes this slow?"                |
| 📉 **Failure Mode Explorer** | "What happens when X fails?"           |

> **Ship Criteria:** If no agent can break the system, then you ship. Not "looks good"—"couldn't break it."

### Reward Shaping (What to Optimize For)

AI needs explicit gradients. Define what's valued:

**Reward:**

- ✅ Smaller diffs
- ✅ Reversible decisions
- ✅ Fewer assumptions
- ✅ Better test coverage
- ✅ Lower entropy designs
- ✅ Explicit uncertainty

**Penalize:**

- ❌ Cleverness
- ❌ Over-generalization
- ❌ Unused abstractions
- ❌ Large surface area changes
- ❌ Hidden complexity

---

## Intent File Template

Every planned feature, bug fix, or tech debt item uses this template:

````markdown
# F-###: Title

## Type

feature | bug | tech-debt

## Status

planned | active | blocked | validating | shipped | killed

## Motivation

(Why it exists, 1–3 bullets)

## Confidence

Requirements: 0.0–1.0  
Domain assumptions: 0.0–1.0
(If either < threshold, document why proceeding or request human interrupt)

## Invariants (Hard Constraints)

Written in dual form: human-readable AND executable

Human-readable:

- No PII stored unencrypted
- p95 latency < 200ms
- Schema backward compatible for 3 versions

Executable (add to architecture/invariants.yml):

```yaml
invariants:
  - no_pii_unencrypted
  - p95_latency_ms: 200
  - schema_backward_compat_versions: 3
success_metrics:
  - test_pass_rate: 99.5
  - zero_data_loss_on_replay: true
```
````

## Acceptance (Executable)

These are the ONLY criteria for "done." If it can't be checked automatically, it doesn't belong here.

- [ ] Tests: `<test_name>` added; fails before fix, passes after
- [ ] CLI: `pnpm test` green
- [ ] CLI: `pnpm lint && pnpm typecheck` green
- [ ] Observability: metric X emitted (if applicable)
- [ ] Contract: API response matches schema (if applicable)
- [ ] Performance: p95 < budget (if applicable)

## Assumptions (MUST BE EXPLICIT)

Every assumption is a potential bug. List them and make them testable where possible.

- (ex: "User sessions never exceed 24h" — add test?)
- (ex: "Database connection pool size is sufficient" — add monitoring?)
- (ex: "This regex handles all Unicode correctly" — add property test?)

## Risk Level

low | medium | high

Risk triggers:

- high: auth, money, data migration, permissions, infra, PII
- medium: new dependencies, API changes, performance-sensitive
- low: docs, refactors, tests, internal tooling

## Kill Criteria (Stop Conditions)

If ANY of these trigger, the intent is KILLED (not paused, not reworked—killed):

- Cannot satisfy latency invariant without major redesign
- Requires breaking schema compatibility beyond allowed versions
- Adds >20% complexity to core execution path
- Conflicts with architecture canon
- Requires >N days without progress (define N)
- Cost exceeds budget by >X%

## Rollback Plan

REQUIRED before implementation begins.

- Feature flag: `FEATURE_X_ENABLED=false`
- Config toggle: revert to previous config
- Database: migration has corresponding down migration
- Revert commit: clean revert possible without data loss

## Dependencies

- (Other intent IDs that must ship first)
- (ADRs that must be approved)
- (External systems/APIs)

## Do Not Repeat Check

Before starting, verify this hasn't been tried before:

- [ ] Checked /do-not-repeat/abandoned-designs.md
- [ ] Checked /do-not-repeat/failed-experiments.md
- [ ] No similar rejected approaches exist

````

---

## Invariants File Format

The `/architecture/invariants.yml` file contains machine-verifiable constraints:

```yaml
# architecture/invariants.yml
version: 1

invariants:
  security:
    - no_pii_stored_unencrypted
    - all_endpoints_require_auth_except: ["/health", "/metrics"]
    - secrets_never_logged

  performance:
    - p95_latency_ms: 200
    - p99_latency_ms: 500
    - max_memory_mb: 512

  data:
    - schema_backward_compat_versions: 3
    - no_data_loss_on_replay
    - all_writes_idempotent

  architecture:
    - no_circular_dependencies
    - max_import_depth: 5
    - forbidden_patterns:
      - "any"  # No TypeScript 'any'
      - "eval("
      - "innerHTML"

success_metrics:
  test_pass_rate: 99.5
  code_coverage_minimum: 80
  max_cyclomatic_complexity: 10
````

---

## SDLC Phases

### Critical Order: Spec → Tests → Code

> **THE AI IS NOT ALLOWED TO WRITE PRODUCTION CODE UNTIL TESTS EXIST.**

This is the single biggest correctness improvement over human SDLC:

1. **Spec agent** generates testable assertions
2. **Test agent** implements tests
3. **Code agent** satisfies tests
4. **Mutation agent** tries to break them

If tests are retrofitted, they're worthless. Tests come first.

---

### Phase 0 — Intake & Intent Creation

**Output:** New `/intent/...` file in `planned` status

1. PM writes intent using the template (including all required sections)
2. PM checks `/do-not-repeat/` ledger for similar failed approaches
3. Steward reviews for:
   - Clarity of motivation
   - Measurable acceptance (executable, not narrative)
   - Explicit assumptions listed
   - Correct risk level assignment
   - Kill criteria defined
   - Rollback plan present
4. Steward decision:
   - ✅ **Approve** → status remains `planned`
   - ⏸️ **Block** → return with specific missing items
   - ❌ **Kill** → mark `killed` with rationale, add to do-not-repeat if pattern emerges

### Phase 1 — Intent Lock (Executable Requirements)

**Output:** Acceptance criteria finalized + confidence thresholds met + tests written

1. PM refines acceptance into executable checks (must be runnable commands)
2. QA writes the tests BEFORE any implementation:
   - Tests must FAIL initially (nothing to pass yet)
   - Tests define the "fail-before/pass-after" contract
3. Assumption Extractor agent surfaces any implicit assumptions
4. Steward confirms confidence thresholds:
   - Requirements confidence < 0.8 → **HUMAN INTERRUPT**
   - Domain assumptions < 0.7 → **BLOCK** (add discovery spike or explicit assumptions)

**Output saved to:** `workflow-state/01_analysis.md`

### Phase 2 — Architecture & Plan (Canonical Design)

**Output:** `workflow-state/02_plan.md` + any needed ADR updates

1. Architect proposes:
   - Technical approach
   - Files to be created/modified
   - Interfaces and contracts
   - Performance implications
   - Security considerations
   - How rollback strategy will work
2. Architect checks against:
   - `/architecture/CANON.md` (no violations)
   - `/do-not-repeat/` (no repeated mistakes)
   - Cost budgets (token, latency, cloud)
3. Architect updates CANON.md or adds new ADR **only if architecture actually changes**
4. Steward runs **Plan Gate**:
   - ✅ **Approve** → proceed to implementation
   - ⏸️ **Block** → revise plan with specific feedback
   - ❌ **Kill** → criteria met or poor tradeoff identified

**⚠️ HARD RULE: NO PRODUCTION CODE EDITS BEFORE PLAN APPROVAL**

**🛑 STOP POINT: Present plan and ask for human approval before any edits (if configured)**

### Phase 3 — Implementation (Parallel Allowed)

**Output:** Code changes + notes in `workflow-state/03_implementation.md`

**Remember: Tests already exist from Phase 1. Implementation makes them pass.**

1. Implementer executes the approved plan ONLY
2. Implementation order:
   - Make the pre-written tests pass
   - Add any additional edge case tests discovered
   - Refactor only within approved scope
3. If parallelism helps:
   - Split into 3–6 independent numbered tasks
   - Run parallel agents in isolated worktrees
   - Each agent reads `.agent-id` to get unique task number
   - Each agent writes progress to `workflow-state/agent-<id>.md`
   - Each agent works ONLY on their assigned task
   - Orchestrator merges outputs into coherent branch
4. **Any plan deviation → STOP and return to Phase 2 for re-approval**

### Phase 4 — Verification (Adversarial Proof)

**Output:** `workflow-state/04_verification.md` containing proof (not opinions)

This is a **Proof-of-Correctness Gate**, not a "QA signoff."

**Required Verification Methods:**

1. **Unit & Integration Tests** — All tests pass
2. **Property-Based Testing** — For core logic (if applicable)
3. **Fuzzing** — For input handling (if applicable)
4. **Differential Behavior Checks** — Compare with previous version
5. **Replay-Based Validation** — If data processing involved

**Adversarial Swarm runs simultaneously:**
| Agent | Question |
|-------|----------|
| QA | "What inputs break this?" |
| Security | "How would I exploit this?" |
| Performance | "What makes this slow?" |
| Failure Mode | "What happens when dependencies fail?" |

**Verification document must include:**

```markdown
## Commands Run

- `pnpm test` → PASS (152 tests, 0 failures)
- `pnpm lint` → PASS
- `pnpm typecheck` → PASS

## Acceptance Checklist

- [x] Test: user_auth_test.ts fails before, passes after
- [x] p95 latency: 145ms (budget: 200ms)
- [x] No new security findings

## Adversarial Results

- QA: Could not break with fuzz inputs (1000 iterations)
- Security: No auth bypass found
- Performance: No degradation under load test

## Confidence

Verification confidence: 0.92
```

> **Rule:** If the system cannot explain WHY it is correct, it isn't correct.

**If repeated failures → Steward triggers kill criteria review**

### Phase 5 — Release Packaging

**Output:** PR ready, minimal and auditable

1. Docs agent updates:
   - Release notes in `workflow-state/05_release_notes.md`
   - ADR references if architecture changed
   - README/usage docs if API changed
2. Steward performs final check:
   - All acceptance criteria met
   - Drift impact acceptable
   - Rollback plan tested/valid
   - No kill criteria triggered
3. Create PR that includes:
   - Reference to intent ID(s)
   - Link to verification proof
   - Rollback instructions
   - Risk level label

### Phase 6 — Merge & Post-Deploy Self-Interrogation

**Output:** Merged code + updated intent status + drift snapshot

1. Merge via GitHub branch protection (all CI checks green)
2. Update intent status → `shipped`
3. Add entry to drift snapshot in `/drift/metrics.md`
4. **Post-Deployment Self-Interrogation** (agents ask):
   - "What assumptions just broke?"
   - "What inputs were unseen during development?"
   - "Where did confidence exceed evidence?"
   - "What would we do differently?"
5. If learnings emerge → update `/do-not-repeat/` or create new tech-debt intent

---

## Confidence Threshold Policy

| Condition                                       | Action                                        |
| ----------------------------------------------- | --------------------------------------------- |
| Requirements confidence < 0.8                   | **HUMAN INTERRUPT** (clarify scope/value)     |
| Domain assumptions confidence < 0.7             | **BLOCK** (add discovery spike)               |
| Security-related confidence < 0.85              | **HUMAN INTERRUPT**                           |
| Any agent reports "uncertain" on critical point | **Steward decides:** block, escalate, or kill |

---

## Human Interrupt Policy

Humans intervene **ONLY** at these gates:

| Gate             | Trigger                                     |
| ---------------- | ------------------------------------------- |
| Plan Approval    | Before implementation starts                |
| High-Risk        | See confirmed high-risk domains below       |
| Kill/Rollback    | Kill criteria triggered or major regression |
| Product Judgment | Subjective UX/taste/value tradeoffs         |

**Confirmed High-Risk Domains (require human approval):**

- 🔐 **Authentication** — Login, logout, session management, OAuth
- 💰 **Payment processing** — Billing, subscriptions, transactions
- 🔑 **Permissions** — RBAC, access control, authorization checks
- 🏗️ **Infrastructure changes** — Deployment config, environment variables, cloud resources
- 📋 **PII handling** — User data storage, encryption, data export/deletion

**Everything else is automated.** Response time expectation: **minutes** (real-time).

---

## Drift Detection (Entropy Control)

### Required Indicators (Weekly)

| Metric                    | What It Catches                |
| ------------------------- | ------------------------------ |
| Avg PR size (files + LOC) | Scope creep, complexity growth |
| Test-to-code ratio        | Test coverage decay            |
| Dependency graph growth   | Coupling increase              |
| "New concept" drift       | Modules without intents/ADRs   |
| Time-to-green             | Verification difficulty        |

### Drift Triggers

- **2+ indicators degrade beyond baseline** → Block new features until stability work done
- **Canon violations appear repeatedly** → Architecture correction sprint

---

## Continuous Internal Code Review (Not PR-Based)

Pull requests are human-bandwidth throttles. For AI teams, every commit gets continuous automated review.

**Review Agents (run on every commit):**

| Agent                | Checks                                            |
| -------------------- | ------------------------------------------------- |
| **Style Agent**      | Formatting, naming conventions, code organization |
| **Logic Agent**      | Dead code, unreachable branches, obvious bugs     |
| **Invariant Agent**  | Violations of `invariants.yml` constraints        |
| **Regression Agent** | Test coverage, behavioral changes                 |

**Review Outcomes (no "LGTM"):**

| Result           | Meaning                              |
| ---------------- | ------------------------------------ |
| ✅ **Pass**      | All checks satisfied, proceed        |
| ❌ **Fail**      | Specific issue identified, must fix  |
| ❓ **Uncertain** | Cannot determine, escalates to human |

> **Rule:** Reviews are blocking, not advisory. A "Fail" must be fixed before the commit is accepted.

---

## GitHub Usage Policy

### GitHub Is For:

- Branch protection + CI gates (the real enforcement)
- PRs as audit log (what + why + evidence)
- Code ownership rules for critical paths
- Release/tagging and rollback points
- External issue intake only (then convert to intent)

### GitHub Is NOT For:

- Tasking/review conversations (use workflow-state)
- Micro-task assignment (use intent ledger)
- Discussion threads on PRs (decisions go in ADRs)
- "LGTM" rubber-stamp reviews (use automated gates)

### PR Strategy

**Batch PRs, not commits:**

- AI can make 30 improvements/hour
- GitHub can't handle 30 PRs/hour
- Let agents commit continuously
- Orchestrator batches into 1–3 PRs per "feature episode"

**Stacked PRs:**

- Use only if you truly need separate review surfaces
- For AI teams, prefer: parallel worktrees → merge locally → 1 PR
- Stacked PRs increase coordination complexity

### Autopass Lanes

| Lane  | What                                        | Review                    | Merge                  |
| ----- | ------------------------------------------- | ------------------------- | ---------------------- |
| **A** | Docs, tests, refactors (no behavior change) | Automated only            | Automerge on green CI  |
| **B** | Standard features, small API changes        | AI review + green CI      | Auto or human optional |
| **C** | High-risk (auth, money, data, permissions)  | Human required + green CI | Human approves         |

**Lane Assignment:**

- Default to Lane B
- Auto-detect Lane A: `docs/**`, `**/*.test.*`, `**/*.spec.*`, refactor-labeled
- Label Lane C (confirmed high-risk): `auth`, `payments`, `permissions`, `infrastructure`, `pii`

---

## Cursor Implementation

### AGENTS.md Content (Root File)

The `AGENTS.md` file is a tool-agnostic entry point for any agent system:

```markdown
# AGENTS.md

## Project: [Name]

## Quick Start

- Install: `pnpm install`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Typecheck: `pnpm typecheck`
- Build: `pnpm build`

## Definition of Done

- All tests pass (`pnpm test`)
- Lint + typecheck pass (`pnpm lint && pnpm typecheck`)
- New/changed behavior has corresponding tests
- Public APIs are documented
- Intent acceptance criteria all checked
- No unresolved security findings

## Conventions

- Never change formatting configs without approval
- Prefer small, reviewable diffs
- Tests before implementation (Spec → Tests → Code)
- All assumptions must be explicit
- Check /do-not-repeat before proposing designs

## Agent System

This repo uses an AI-native SDLC. See:

- `/intent/` for planned work
- `/workflow-state/` for current execution state
- `/architecture/CANON.md` for system boundaries
- `/do-not-repeat/` for failed approaches

## Human Interrupts Required For

- Plan approval (before implementation)
- High-risk changes (auth, money, data, security)
- Kill/rollback decisions
- Product judgment calls
```

### Agent File Format (CORRECTED)

Each agent is defined in `.cursor/rules/<name>.mdc` with MDC frontmatter:

**Note:** Cursor uses `.mdc` files (Markdown with Components), NOT the `.md` with YAML format described in the original ChatGPT conversation.

```markdown
---
description: QA Agent - Use when validating changes, writing tests, or trying to break an implementation
globs:
  - '**/*.test.ts'
  - '**/*.spec.ts'
  - 'tests/**'
alwaysApply: false
---

You are the QA agent.

## Your Role

- Derive acceptance tests from requirements and edge cases
- Write tests BEFORE implementation exists (tests must fail initially)
- Prefer deterministic checks over subjective review
- Try to break implementations—your job is adversarial

## What You Cannot Do

- Weaken acceptance criteria to make tests pass
- Skip edge cases
- Approve without executable proof

## Output Format

1. Risks found
2. Missing test coverage
3. Proposed test cases (with code)
4. Verification commands to run
5. Confidence score (0.0-1.0) with rationale

## Before Acting

- Read `/workflow-state/active.md` to confirm work is approved
- Read the intent file for acceptance criteria
- Check if tests already exist for this functionality
```

**MDC Frontmatter Fields:**
| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | When to use this rule (shown in Cursor UI) |
| `globs` | No | File patterns that auto-activate this rule |
| `alwaysApply` | No | If true, always active; if false, context-triggered |

### Slash Commands to Create

| Command             | Purpose                                  | Location                          |
| ------------------- | ---------------------------------------- | --------------------------------- |
| `/new_intent`       | Creates intent file from template        | `.cursor/commands/new_intent.md`  |
| `/ship <intent-id>` | Runs Phases 1–5 with gates               | `.cursor/commands/ship.md`        |
| `/verify`           | Runs Phase 4 only (QA + security)        | `.cursor/commands/verify.md`      |
| `/drift_check`      | Updates `/drift/metrics.md`              | `.cursor/commands/drift_check.md` |
| `/kill <intent-id>` | Marks killed + rationale + rollback note | `.cursor/commands/kill.md`        |
| `/pr`               | Generates PR description + checklist     | `.cursor/commands/pr.md`          |
| `/risk`             | Forces security/threat skim              | `.cursor/commands/risk.md`        |
| `/revert-plan`      | Writes rollback strategy                 | `.cursor/commands/revert-plan.md` |

### /ship Orchestrator Command (Key Command)

**Note:** Cursor doesn't have native "subagents." The `/ship` command uses **role switching** via explicit instructions. Each "role" is defined in `.cursor/rules/*.mdc` and activated by context or explicit instruction.

```markdown
# /ship (Orchestrated Workflow)

You are the orchestrator. Maintain workflow state in `workflow-state/`.

**IMPORTANT: Role Switching**
Since Cursor doesn't have native subagents, you will switch roles by:

1. Reading the relevant rule file (e.g., `.cursor/rules/pm.mdc`)
2. Adopting that role's constraints and output format
3. Completing that role's tasks
4. Switching to the next role

## Process

### Phase 1: Analysis (PM Role)

Adopt the PM role from `.cursor/rules/pm.mdc`:

1. Restate requirements clearly
2. Define acceptance criteria (executable)
3. Score confidence (requirements, domain assumptions)
4. Check /do-not-repeat for similar failed approaches
5. Save output to `workflow-state/01_analysis.md`
6. If confidence < threshold, STOP and request human interrupt

### Phase 2: Planning (Architect Role)

Adopt the Architect role from `.cursor/rules/architect.mdc`:

1. Propose technical approach
2. List files to create/modify
3. Check against CANON.md
4. Define rollback strategy
5. Save output to `workflow-state/02_plan.md`
6. **STOP: Present plan and ask for approval before any edits**

### Phase 3: Test Writing (QA Role - BEFORE Implementation)

Adopt the QA role from `.cursor/rules/qa.mdc`:

1. Write test cases for acceptance criteria
2. Verify tests FAIL (nothing to pass yet)
3. Commit tests separately with message "test: ..."

### Phase 4: Implementation (Implementer Role)

Adopt the Implementer role from `.cursor/rules/implementer.mdc`:

1. Implement exactly the approved plan
2. Make tests pass
3. Save progress to `workflow-state/03_implementation.md`
4. If plan deviation needed, STOP and return to Phase 2

### Phase 5: Verification (QA + Security Roles)

Adopt QA role, then Security role:

1. (QA) Validate all tests pass, try to break the implementation
2. (Security) Check for auth/input/secrets/PII issues if relevant
3. Save results to `workflow-state/04_verification.md`
4. If verification fails repeatedly, escalate to Steward for kill review

### Phase 6: Release (Docs + Steward Roles)

1. (Docs) Update documentation, save to `workflow-state/05_release_notes.md`
2. (Steward) Final approval check - all acceptance met, drift acceptable

## Rules

- Small diffs. Split large changes into multiple commits.
- If tests are missing, create them FIRST.
- If verification fails, fix or roll back—do not "explain it away."
- Never proceed past a gate without approval.
- When switching roles, explicitly state: "Switching to [ROLE] role."
```

### Parallel Agent Coordination

**Setup:**

1. Split work into 3–6 independent tasks
2. Create worktrees: `git worktree add ../worktree-1 -b feature/task-1`
3. Open each worktree in separate Cursor window
4. Each worktree has its own `.agent-id` file

**Task Assignment File (`worktrees.json`):**

```json
{
  "intent_id": "F-042",
  "tasks": [
    {
      "id": 1,
      "description": "Implement user service",
      "worktree": "worktree-1",
      "status": "in_progress"
    },
    {
      "id": 2,
      "description": "Write user service tests",
      "worktree": "worktree-2",
      "status": "in_progress"
    },
    {
      "id": 3,
      "description": "Update API documentation",
      "worktree": "worktree-3",
      "status": "pending"
    }
  ]
}
```

**Agent Prompt (include in each parallel session):**

```
Read `.agent-id`. You are Agent <id>.
Only work on TASK <id> from worktrees.json.
Write your progress to `workflow-state/agent-<id>.md`.
Do NOT touch files assigned to other agents.
When complete, update your task status to "complete" in worktrees.json.
```

**Merge Process:**

1. Wait for all task statuses to be "complete"
2. Review each `workflow-state/agent-<id>.md` for conflicts
3. Merge worktrees into main branch sequentially
4. Run full verification after merge

---

## Implementation Phases

### Phase 1: Foundation (Days 1-2)

**Directory Structure:**

```bash
mkdir -p intent/features intent/bugs intent/tech-debt
mkdir -p workflow-state
mkdir -p architecture
mkdir -p do-not-repeat
mkdir -p drift
mkdir -p roadmap
mkdir -p .cursor/agents .cursor/commands
```

**Files to Create:**

- [ ] `AGENTS.md` — Root entry point for agents
- [ ] `architecture/CANON.md` — System boundaries and constraints
- [ ] `architecture/invariants.yml` — Machine-verifiable constraints
- [ ] `drift/baselines.md` — Initial metric thresholds
- [ ] `drift/metrics.md` — Empty, will be populated
- [ ] `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` — Empty planning files
- [ ] `do-not-repeat/abandoned-designs.md` — Empty ledger
- [ ] `do-not-repeat/failed-experiments.md` — Empty ledger
- [ ] `do-not-repeat/bad-patterns.md` — Empty ledger
- [ ] `do-not-repeat/rejected-libraries.md` — Empty ledger
- [ ] `workflow-state/active.md` — Empty state file
- [ ] `workflow-state/blocked.md` — Empty state file
- [ ] `workflow-state/validating.md` — Empty state file
- [ ] `workflow-state/shipped.md` — Empty state file
- [ ] `intent/_TEMPLATE.md` — Intent template for copy/paste

### Phase 2: Agent Rules (Days 2-4)

**Create each rule file with MDC frontmatter (see Agent File Format above):**

- [ ] `.cursor/rules/steward.mdc` — Executive brain, veto authority
- [ ] `.cursor/rules/pm.mdc` — Intent writer, requirements clarity
- [ ] `.cursor/rules/architect.mdc` — Design, constraints, ADRs
- [ ] `.cursor/rules/implementer.mdc` — Code execution only
- [ ] `.cursor/rules/qa.mdc` — Tests first, adversarial validation
- [ ] `.cursor/rules/security.mdc` — Threat modeling, attack surface
- [ ] `.cursor/rules/docs.mdc` — Documentation, release notes
- [ ] `.cursor/rules/assumption-extractor.mdc` — Surfaces implicit assumptions

**Verify each rule:**

- [ ] Test that Cursor recognizes the rule (check Cursor settings)
- [ ] Verify role purity is enforced in prompts
- [ ] Confirm rules read required files before acting
- [ ] Test glob patterns trigger correct rules

### Phase 3: Slash Commands (Days 4-6)

**Create each command with full workflow:**

- [ ] `.cursor/commands/new_intent.md` — Interactive intent creation
- [ ] `.cursor/commands/ship.md` — Full orchestrated workflow (Phases 1-6)
- [ ] `.cursor/commands/verify.md` — Verification phase only
- [ ] `.cursor/commands/drift_check.md` — Calculate and record drift metrics
- [ ] `.cursor/commands/kill.md` — Kill an intent with rationale
- [ ] `.cursor/commands/pr.md` — Generate PR description
- [ ] `.cursor/commands/risk.md` — Security/threat review
- [ ] `.cursor/commands/revert-plan.md` — Write rollback strategy

**Verify each command:**

- [ ] Test `/command` works in Cursor chat
- [ ] Verify gates actually block progression
- [ ] Confirm outputs are saved to correct workflow-state files

### Phase 4: GitHub Integration (Days 6-8)

**Branch Protection:**

- [ ] Require PR reviews (or automated approval for Lane A)
- [ ] Require status checks to pass
- [ ] Require linear history (optional, recommended)
- [ ] Configure CODEOWNERS if needed

**CI Pipeline (`.github/workflows/ci.yml`):**

```yaml
checks:
  - unit tests
  - integration tests (if any)
  - lint
  - typecheck
  - security scan (Dependabot, Snyk)
  - performance budget (if defined)
  - invariants check (custom)
```

**Autopass Lanes:**

- [ ] Lane A: Auto-merge label + green CI → merge
- [ ] Lane B: AI-review label + green CI → merge (or human optional)
- [ ] Lane C: Human-required label + green CI + human approval → merge

**PR Template (`.github/pull_request_template.md`):**

```markdown
## Intent

Closes: #[intent-id]

## Changes

- [ ] Description of changes

## Verification

- [ ] Tests pass
- [ ] Lint/typecheck pass
- [ ] Security review (if applicable)

## Rollback

- [ ] Rollback plan documented

## Risk Level

- [ ] Low / Medium / High
```

### Phase 5: Pilot & Iteration (Days 8-14)

**Pilot Feature:**

- [ ] Choose a small, well-defined feature (risk: low)
- [ ] Create intent file using `/new_intent`
- [ ] Run through all 6 phases using `/ship`
- [ ] Document friction points, timing, failures
- [ ] Adjust agent prompts based on learnings

**Calibration:**

- [ ] Run confidence scoring on 10 decisions, measure accuracy
- [ ] Adjust confidence thresholds if needed
- [ ] Calculate initial drift baseline from pilot
- [ ] Tune kill criteria based on what almost failed

**Iteration:**

- [ ] Fix any broken workflows discovered in pilot
- [ ] Simplify overly complex prompts
- [ ] Remove unnecessary gates if they're just friction
- [ ] Add missing gates if failures slipped through

---

## Research & Clarifications — ANSWERED

### 1. Cursor Subagent/Rules Capabilities ✅ RESEARCHED

**Question:** What is the current state of Cursor's agent/rules support?

**ANSWER:**

Cursor does NOT support `.cursor/agents/*.md` with YAML frontmatter as described in the original ChatGPT conversation. That was either speculative or outdated information.

**What Cursor ACTUALLY supports:**

1. **Project Rules** (`.cursor/rules/*.mdc` files):
   - Uses MDC format (Markdown with Component frontmatter)
   - Frontmatter fields: `description`, `globs`, `alwaysApply`
   - Rules are context-aware and can be triggered by file patterns
   - Validated with test files (removed after validation)

2. **Slash Commands** (`.cursor/commands/*.md` files):
   - Simple markdown files that define custom prompts
   - Become available as `/command-name` in chat
   - Validated with test files (removed after validation)

3. **Root Rules File** (`.cursorrules` or `.cursor/rules`):
   - Global rules that apply to all interactions
   - Plain markdown, no frontmatter needed

**Adaptation for our plan:**

```
# Instead of .cursor/agents/, use:
.cursor/rules/
  steward.mdc      # Role-specific rules with glob patterns
  pm.mdc
  architect.mdc
  implementer.mdc
  qa.mdc
  security.mdc
  docs.mdc

# Format for each .mdc file:
---
description: Steward Agent - Executive brain with veto authority
globs:
  - "workflow-state/**"
  - "intent/**"
alwaysApply: false
---

You are the Steward agent...
```

**Role switching approach:**
Since Cursor doesn't have native "subagents," use explicit role activation:

- Include role instructions in slash commands
- User invokes `/ship` which contains role-switching prompts
- Or use `@steward` style mentions if implementing a naming convention

---

### 2. Parallel Agent Worktrees ✅ RESEARCHED

**Question:** How do we spawn parallel agents in isolated worktrees?

**ANSWER:**

Cursor does NOT have a native "parallel agents" or "Background Agents" feature for coordinated multi-agent work. The ChatGPT conversation was describing an idealized pattern.

**What actually works:**

1. **Git Worktrees** (standard git feature):

   ```bash
   # Create worktrees for parallel work
   git worktree add ../worktree-1 -b feature/task-1
   git worktree add ../worktree-2 -b feature/task-2
   git worktree add ../worktree-3 -b feature/task-3
   ```

2. **Multiple Cursor Windows:**
   - Open each worktree in a separate Cursor window
   - Each window has independent context
   - No native coordination between windows

3. **Coordination via files:**
   - Use `worktrees.json` in the main repo for task assignment
   - Each worktree reads its task from the shared file
   - Agents write progress to `workflow-state/agent-<id>.md`

**Practical implementation:**

```bash
# Setup script for parallel work
#!/bin/bash
TASK_COUNT=3
for i in $(seq 1 $TASK_COUNT); do
  git worktree add "../worktree-$i" -b "task-$i"
  echo "$i" > "../worktree-$i/.agent-id"
done
echo "Open each worktree folder in a separate Cursor window"
```

**Merge process:**

```bash
# After all tasks complete
for i in $(seq 1 $TASK_COUNT); do
  git checkout main
  git merge "task-$i" --no-ff -m "Merge task $i"
done
git worktree remove "../worktree-$i"
```

**Limitation:** No automatic coordination. Human or orchestrator script must manage.

---

### 3. `.agent-id` Coordination Pattern ✅ RESEARCHED

**Question:** How do we implement task coordination for parallel agents?

**ANSWER:**

This is a design pattern, not a Cursor feature. Implementation is straightforward:

**Task Assignment (`worktrees.json`):**

```json
{
  "intent_id": "F-042",
  "created": "2026-01-12T10:00:00Z",
  "tasks": [
    {
      "id": 1,
      "description": "Implement user authentication handler",
      "worktree": "worktree-1",
      "status": "pending",
      "assigned_at": null,
      "completed_at": null
    },
    {
      "id": 2,
      "description": "Write authentication tests",
      "worktree": "worktree-2",
      "status": "pending",
      "assigned_at": null,
      "completed_at": null
    }
  ]
}
```

**Agent identification (`.agent-id`):**

```
1
```

Simple file containing just the task number.

**Prompt instruction for each agent:**

```
Before starting work:
1. Read `.agent-id` to get your task number
2. Read `worktrees.json` from the main repo to get your task description
3. Only work on YOUR assigned task
4. Write progress to `workflow-state/agent-{id}.md`
5. When done, update your task status to "complete" in worktrees.json
6. Do NOT modify files outside your task scope
```

**Race condition handling:**

- Not a real concern—each worktree has its own `.agent-id` file
- Tasks are pre-assigned, not claimed dynamically
- worktrees.json updates can use git's merge conflict resolution

---

### 4. Steward Veto Authority ✅ RESEARCHED

**Question:** How does the Steward actually enforce blocks/kills?

**ANSWER:**

There is no native enforcement. It's a **convention-based system** that relies on:

1. **State files as source of truth:**

   ```markdown
   <!-- workflow-state/active.md -->

   ## Active Work

   - F-042: User Authentication [status: BLOCKED by Steward]
     - Reason: Confidence below threshold (0.65)
     - Required: Human interrupt to clarify requirements
   ```

2. **Slash commands that check status:**

   ```markdown
   # /ship command (excerpt)

   Before proceeding with ANY phase:

   1. Read workflow-state/active.md
   2. Check if intent status is BLOCKED or KILLED
   3. If blocked: STOP and report the blocking reason
   4. If killed: STOP and report that work is terminated
   5. Only proceed if status is ACTIVE or APPROVED
   ```

3. **Agent prompts that enforce checking:**
   ```
   ## Before Acting (ALL AGENTS)
   You MUST read workflow-state/active.md before making any changes.
   If the intent you're working on is BLOCKED or KILLED, STOP immediately
   and report the status to the user. Do not proceed with any work.
   ```

**Enforcement strength:** Medium. Agents can technically ignore this, but:

- Consistent prompting reduces violations
- Human can audit workflow-state files
- CI can fail if workflow-state shows blocked items being modified

---

### 5. Drift Metrics Automation ✅ RESEARCHED

**Question:** How do we calculate drift metrics?

**ANSWER:**

Implement as a shell script that can run locally or in CI:

**`scripts/drift-check.sh`:**

```bash
#!/bin/bash

echo "## Drift Metrics Report - $(date)" > drift/metrics.md

# 1. Average PR size (last 20 PRs)
echo "### PR Size Trend" >> drift/metrics.md
git log --oneline -20 --stat | grep "files changed" | \
  awk '{sum+=$1; count++} END {print "Avg files changed: " sum/count}' >> drift/metrics.md

# 2. Test-to-code ratio
echo "### Test-to-Code Ratio" >> drift/metrics.md
TEST_LINES=$(find . -name "*.test.ts" -o -name "*.spec.ts" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
CODE_LINES=$(find . -name "*.ts" ! -name "*.test.ts" ! -name "*.spec.ts" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
RATIO=$(echo "scale=2; $TEST_LINES / $CODE_LINES" | bc)
echo "Test lines: $TEST_LINES, Code lines: $CODE_LINES, Ratio: $RATIO" >> drift/metrics.md

# 3. Dependency count
echo "### Dependency Growth" >> drift/metrics.md
DEPS=$(jq '.dependencies | length' package.json 2>/dev/null || echo "N/A")
DEV_DEPS=$(jq '.devDependencies | length' package.json 2>/dev/null || echo "N/A")
echo "Dependencies: $DEPS, DevDependencies: $DEV_DEPS" >> drift/metrics.md

# 4. New files without intents
echo "### Untracked New Concepts" >> drift/metrics.md
git diff --name-only HEAD~20 --diff-filter=A | grep -v "intent/" | head -10 >> drift/metrics.md

# 5. Time-to-green (from CI)
echo "### CI Performance" >> drift/metrics.md
echo "(Manually update from CI dashboard)" >> drift/metrics.md

echo "Drift check complete. See drift/metrics.md"
```

**GitHub Actions integration:**

```yaml
# .github/workflows/drift-check.yml
name: Weekly Drift Check
on:
  schedule:
    - cron: '0 9 * * 1' # Every Monday at 9am
  workflow_dispatch:

jobs:
  drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 100
      - run: chmod +x scripts/drift-check.sh && ./scripts/drift-check.sh
      - uses: actions/upload-artifact@v4
        with:
          name: drift-report
          path: drift/metrics.md
```

---

### 6. Confidence Scoring Implementation ✅ RESEARCHED

**Question:** How do we get calibrated confidence scores from LLMs?

**ANSWER:**

LLMs are notoriously overconfident. Use these techniques:

**1. Structured prompting with forced uncertainty:**

```
Rate your confidence for each item. You MUST use the full range:
- 0.3-0.5: Significant uncertainty, multiple valid interpretations
- 0.5-0.7: Moderate confidence, some assumptions made
- 0.7-0.85: High confidence, clear requirements
- 0.85-1.0: Very high confidence, unambiguous

Requirements clarity: [X.XX]
Reason: [specific reason for this score]
What would raise this score: [specific action]

Domain assumptions: [X.XX]
Reason: [specific reason]
What would raise this score: [specific action]
```

**2. Calibration through examples:**
Include examples in the prompt:

```
Examples of appropriate confidence scores:
- "Add a login page" → 0.4 (vague, many unknowns)
- "Add OAuth2 login with Google, redirect to /dashboard" → 0.75 (specific but some details missing)
- "Add OAuth2 login with Google using passport.js, 5s timeout, redirect to /dashboard on success, /error on failure" → 0.9 (highly specific)
```

**3. Multi-agent cross-validation:**
Have two agents independently score, then compare:

```
If |score_agent_1 - score_agent_2| > 0.2:
  Flag for human review
  Use lower score as conservative estimate
```

**4. Outcome tracking for calibration:**

```json
// confidence-calibration.json
{
  "decisions": [
    {
      "id": "D-001",
      "stated_confidence": 0.85,
      "actual_outcome": "success",
      "notes": "Shipped without issues"
    },
    {
      "id": "D-002",
      "stated_confidence": 0.9,
      "actual_outcome": "failure",
      "notes": "Major rework needed - overconfident"
    }
  ]
}
```

**Recommended thresholds (conservative):**

- < 0.6: Block, require human clarification
- 0.6-0.75: Proceed with caution, flag assumptions
- 0.75-0.85: Normal proceed
- > 0.85: High confidence, still verify

---

### 7. Context Window Limits ✅ RESEARCHED

**Question:** How do agents maintain global understanding with limited context?

**ANSWER:**

**Current context limits (approximate):**

- Claude: 200K tokens
- GPT-4: 128K tokens
- Cursor uses these models with some overhead

**Practical strategies:**

**1. Summary file (`SYSTEM_STATE.md`):**

```markdown
# System State Summary

Generated: 2026-01-12T10:30:00Z

## Active Intents (3)

- F-042: User Auth [Phase 3, Implementer]
- B-015: Cache Bug [Phase 4, QA]
- T-007: Logging [Phase 2, Architect]

## Blocked (1)

- F-043: Payment Integration [Confidence < 0.6]

## Recent Decisions (last 5)

- ADR-012: Use Passport.js for OAuth
- Killed F-040: Too complex, revisit Q2

## Architecture Alerts

- None

## Drift Status

- All metrics within baseline
```

**2. Hierarchical reading protocol:**

```
Steward reading order:
1. SYSTEM_STATE.md (always, ~500 tokens)
2. workflow-state/active.md (~200 tokens)
3. Intent file for current work (~500 tokens)
4. CANON.md if architecture decision needed (~1000 tokens)
5. Specific files only when drilling into issues
```

**3. Memory contracts per agent:**
| Agent | Must Read | May Read | Never Reads |
|-------|-----------|----------|-------------|
| Steward | SYSTEM_STATE, active.md, all intents | Everything | N/A |
| PM | Intent template, SYSTEM_STATE | Related intents | Code files |
| Implementer | Current intent, plan.md | Test files | Other intents |
| QA | Current intent, code files | Test patterns | Architecture |

**4. Context budget per phase:**

- Phase 1 (Analysis): 10K tokens max
- Phase 2 (Planning): 15K tokens max
- Phase 3 (Implementation): 30K tokens max (needs code context)
- Phase 4 (Verification): 20K tokens max

---

### 8. Tests-First Enforcement ✅ RESEARCHED

**Question:** How do we enforce "tests exist before production code"?

**ANSWER:**

**Enforcement levels:**

**Level 1: Prompt-based (soft):**

```
## Phase 3: Test Writing (BEFORE Implementation)

You MUST write tests before any production code.
1. Create test file(s) based on acceptance criteria
2. Run tests - they MUST FAIL (nothing to pass yet)
3. Commit tests with message "test: Add tests for [feature]"
4. ONLY THEN proceed to implementation

If you write production code before tests exist, STOP and correct.
```

**Level 2: Slash command checks (medium):**

```markdown
# /ship command - Phase 3 gate

Before implementation:

1. List all new test files created in this session
2. Verify each test file exists
3. Run tests and verify they FAIL
4. If no failing tests exist, STOP:
   "Cannot proceed: Tests must exist and fail before implementation"
```

**Level 3: CI enforcement (hard):**

```yaml
# .github/workflows/tests-first.yml
name: Tests-First Check
on: pull_request

jobs:
  check-order:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check test commits precede implementation
        run: |
          # Get commits in PR
          COMMITS=$(git log --oneline origin/main..HEAD)

          # Find first test commit and first impl commit
          FIRST_TEST=$(git log --oneline --all --grep="test:" | tail -1)
          FIRST_IMPL=$(git log --oneline --all --grep="feat:\|fix:" | tail -1)

          # Compare timestamps (simplified)
          echo "First test: $FIRST_TEST"
          echo "First impl: $FIRST_IMPL"
          # Add actual timestamp comparison logic
```

**When to allow exceptions:**

- Exploratory spikes (labeled `spike:` in intent)
- Proof-of-concept work (labeled `poc:`)
- Documentation-only changes
- Configuration changes

---

### 9. Property-Based Testing & Fuzzing ✅ RESEARCHED

**Question:** What tools and how much testing?

**ANSWER:**

**TypeScript/JavaScript:**

**fast-check** (property-based):

```bash
npm install --save-dev fast-check
```

```typescript
import fc from 'fast-check';

// Example: Testing a string sanitizer
describe('sanitizeInput', () => {
  it('should never contain script tags after sanitization', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        const result = sanitizeInput(input);
        return !result.includes('<script');
      })
    );
  });

  it('should be idempotent', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        const once = sanitizeInput(input);
        const twice = sanitizeInput(once);
        return once === twice;
      })
    );
  });
});
```

**Fuzzing with fast-check:**

```typescript
// Run more iterations for fuzzing-like behavior
fc.assert(
  fc.property(fc.string(), (input) => {
    // Your property
  }),
  { numRuns: 10000 } // Default is 100
);
```

**Python:**

**Hypothesis** (property-based):

```bash
pip install hypothesis
```

```python
from hypothesis import given, strategies as st

@given(st.text())
def test_sanitize_never_has_script(text):
    result = sanitize_input(text)
    assert '<script' not in result

@given(st.text())
def test_sanitize_idempotent(text):
    once = sanitize_input(text)
    twice = sanitize_input(once)
    assert once == twice
```

**How much is enough:**
| Risk Level | Iterations | Fuzzing Time |
|------------|------------|--------------|
| Low | 100 (default) | N/A |
| Medium | 1,000 | 30 seconds |
| High (auth, data) | 10,000 | 5 minutes |
| Critical (payments) | 100,000 | 30 minutes |

---

### 10. Mutation Testing ✅ RESEARCHED

**Question:** When and how to use mutation testing?

**ANSWER:**

**Stryker Mutator** (TypeScript/JavaScript):

```bash
npm install --save-dev @stryker-mutator/core @stryker-mutator/typescript-checker @stryker-mutator/jest-runner
npx stryker init
```

**`stryker.conf.json`:**

```json
{
  "mutator": {
    "excludedMutations": ["StringLiteral"]
  },
  "testRunner": "jest",
  "reporters": ["html", "clear-text", "progress"],
  "coverageAnalysis": "perTest",
  "timeoutMS": 10000
}
```

**When to run:**
| Trigger | Full Suite | Changed Files Only |
|---------|------------|-------------------|
| Every PR | ❌ Too slow | ❌ |
| High-risk PR | ✅ | - |
| Weekly CI | ✅ | - |
| Pre-release | ✅ | - |
| Local dev | - | ✅ Targeted |

**Targeted mutation testing:**

```bash
# Only mutate changed files
npx stryker run --mutate "src/auth/**/*.ts"
```

**Acceptable mutation score:**

- Target: 80%+ killed mutations
- Critical paths (auth, payments): 90%+
- Utility code: 70%+

**Python (mutmut):**

```bash
pip install mutmut
mutmut run --paths-to-mutate=src/auth/
mutmut results
```

---

### 11. Replay-Based Validation ✅ RESEARCHED

**Question:** What does replay-based validation mean in practice?

**ANSWER:**

**Definition:** Run historical/production inputs through new code and verify outputs match expected results.

**Use cases:**

1. Data transformation pipelines
2. API endpoint behavior
3. Business logic calculations
4. Report generation

**Implementation pattern:**

**1. Capture golden data:**

```typescript
// scripts/capture-golden.ts
const testCases = [
  { input: {...}, expectedOutput: {...} },
  // Captured from production or hand-crafted
];
fs.writeFileSync('golden-data/auth-cases.json', JSON.stringify(testCases));
```

**2. Replay and compare:**

```typescript
// tests/replay.test.ts
import goldenData from '../golden-data/auth-cases.json';

describe('Replay validation', () => {
  goldenData.forEach((testCase, index) => {
    it(`should match golden output for case ${index}`, () => {
      const actual = processInput(testCase.input);
      expect(actual).toEqual(testCase.expectedOutput);
    });
  });
});
```

**3. Handle non-determinism:**

```typescript
// For timestamps, UUIDs, etc.
const normalize = (output) => ({
  ...output,
  timestamp: 'NORMALIZED',
  id: 'NORMALIZED',
});

expect(normalize(actual)).toEqual(normalize(expected));
```

**4. Differential testing:**

```typescript
// Compare old implementation vs new
const oldResult = oldImplementation(input);
const newResult = newImplementation(input);
expect(newResult).toEqual(oldResult);
```

**Data anonymization for production replay:**

```typescript
const anonymize = (data) => ({
  ...data,
  email: 'user@example.com',
  name: 'Test User',
  ssn: '***-**-****',
});
```

---

### 12. Agent Disagreement Resolution ✅ RESEARCHED

**Question:** What happens when agents disagree?

**ANSWER:**

**Resolution hierarchy:**

```
DISAGREEMENT RESOLUTION PROTOCOL

1. SECURITY ALWAYS WINS
   - Security agent findings cannot be waived
   - Must be addressed with mitigation
   - Only human can override with documented risk acceptance

2. CORRECTNESS OVER PERFORMANCE
   - If QA finds a bug, fix it even if it impacts performance
   - Performance can be optimized after correctness

3. STEWARD DECIDES TRADEOFFS
   - QA vs Performance (non-critical): Steward decides
   - Architect vs Implementer scope: Steward decides
   - PM vs Architect priority: Steward decides

4. HUMAN INTERRUPT FOR:
   - Security override requests
   - Product/UX judgment calls
   - Ethical concerns
   - Persistent disagreement (3+ rounds)
```

**Structured disagreement log:**

```markdown
<!-- workflow-state/disagreements.md -->

## F-042: Auth Implementation

### Disagreement 1

- **QA**: Test coverage insufficient for edge cases
- **Implementer**: Coverage meets 80% threshold
- **Resolution**: Steward decided - add 3 specific edge case tests
- **Outcome**: QA accepted after additional tests

### Disagreement 2

- **Security**: JWT expiry too long (7 days)
- **PM**: Business requirement for long sessions
- **Resolution**: Human interrupt - reduced to 24h with refresh tokens
- **Outcome**: Compromise accepted by all parties
```

**Voting rules (if needed):**

- Simple majority for low-risk decisions
- Unanimous for high-risk decisions
- Security veto cannot be overruled by vote

---

### Follow-up Research Items (Emerged from Primary Research)

These items were identified during primary research but need additional investigation:

#### F1. Invariants Checking Tooling ✅ RESEARCHED

**Question:** How do we enforce `invariants.yml` at runtime/CI?

**ANSWER: Use ESLint + TypeScript strict mode + CI checks (config over code)**

| Invariant Type     | Enforcement Method | Tool/Config                                   |
| ------------------ | ------------------ | --------------------------------------------- |
| No `any` type      | ESLint             | `@typescript-eslint/no-explicit-any: "error"` |
| Forbidden types    | ESLint             | `@typescript-eslint/ban-types`                |
| No `eval()`        | ESLint             | `no-eval: "error"`                            |
| No `innerHTML`     | ESLint             | `no-unsanitized/property` (plugin)            |
| No circular deps   | ESLint             | `import/no-cycle` (eslint-plugin-import)      |
| Max import depth   | ESLint             | `import/no-restricted-paths`                  |
| Type safety        | TypeScript         | `tsconfig.json` with `strict: true`           |
| Schema compat      | CI                 | Custom test that loads old + new schema       |
| Performance (p95)  | CI                 | Benchmark tests with threshold assertions     |
| Secrets not logged | ESLint             | `no-console` in production, custom rule       |

**Implementation (minimal code):**

```json
// .eslintrc.json (or eslint.config.js)
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/strict-type-checked"],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/ban-types": "error",
    "no-eval": "error",
    "import/no-cycle": "error"
  }
}
```

**What remains runtime-only:**

- Performance budgets (p95 latency) → CI benchmark tests
- Memory limits → CI tests with memory monitoring
- Data loss prevention → Integration tests with replay validation

**Priority:** ✅ Resolved - use config files, not custom code

#### F2. Review Agents Implementation

- **Question:** How do the Style/Logic/Invariant/Regression review agents run on every commit?
- **Current State:** Concept defined, but implementation unclear
- **Options to Research:**
  - Git pre-commit hooks that invoke Cursor
  - CI workflow that uses Cursor CLI (if exists)
  - Separate linting tools that approximate each agent's role
  - Manual invocation via slash commands
- **Priority:** Medium (can use existing linters initially)

#### F3. SYSTEM_STATE.md Auto-Generation

- **Question:** How do we automatically generate the Steward's summary file?
- **Current State:** Format defined, but generation not automated
- **Options to Research:**
  - Shell script that parses intent/workflow-state files
  - Cursor slash command that regenerates it
  - Git hook on commit
  - CI job that updates it
- **Priority:** Medium (can manually maintain initially)

#### F4. Performance Testing Approach

- **Question:** What tools/methods for the "Performance Degrader" agent?
- **Current State:** Role defined, but no tooling specified
- **Options to Research:**
  - k6 for load testing
  - Clinic.js for Node.js profiling
  - Custom benchmarks with Vitest
  - CI performance budgets via Lighthouse CI (for web)
- **Priority:** Low (only needed for performance-sensitive work)

#### F5. Cursor CLI for Automation ✅ RESEARCHED

**Question:** Does Cursor have a CLI for programmatic agent invocation?

**ANSWER: No. Cursor is GUI-only. CI must use standard tools.**

- Cursor is built on VS Code and operates as an interactive desktop application
- No public CLI or API for invoking AI features programmatically
- "Background Agents" mentioned in community but not a documented public API
- Cursor can open from command line (`cursor .`) but cannot run AI prompts headlessly

**Impact on our architecture:**

| Context             | Solution                                                  |
| ------------------- | --------------------------------------------------------- |
| **CI/CD**           | Use standard tools: ESLint, TypeScript, Vitest, npm audit |
| **Pre-commit**      | Use Husky + lint-staged (not Cursor)                      |
| **Agent workflows** | Interactive only - user invokes `/ship` manually          |
| **Verification**    | CI runs tests; Cursor is for authoring, not automation    |

**Practical implication:**
The "Review Agents" (Style, Logic, Invariant, Regression) in CI are actually:

- **Style Agent** → Prettier + ESLint
- **Logic Agent** → TypeScript strict mode + ESLint
- **Invariant Agent** → ESLint rules + custom CI checks
- **Regression Agent** → Vitest test suite

Cursor slash commands are for interactive development, not CI automation.

**Priority:** ✅ Resolved - design confirmed: Cursor = interactive, CI = standard tools

#### F6. Token Budget Enforcement

- **Question:** How do we enforce token budgets per agent?
- **Current State:** Concept defined, but no enforcement mechanism
- **Options to Research:**
  - Cursor may have settings for this
  - Custom middleware/proxy (complex)
  - Soft enforcement via prompts ("keep responses under X tokens")
- **Priority:** Low (nice-to-have optimization)

---

### Technical Decisions — CONFIRMED ✅

| Decision                   | Choice                     | Rationale                                                    |
| -------------------------- | -------------------------- | ------------------------------------------------------------ |
| **Primary stack**          | TypeScript/Node.js         | Best AI tooling support, strong typing, fast-check available |
| **Test framework**         | Vitest                     | Faster than Jest, native ESM, great DX                       |
| **Property-based testing** | fast-check                 | Mature, well-documented, TypeScript-native                   |
| **Mutation testing**       | Stryker                    | Industry standard for JS/TS                                  |
| **CI platform**            | GitHub Actions             | Native integration, good free tier                           |
| **Feature flags**          | Environment variables      | Start simple, add service later                              |
| **Drift metrics**          | Shell script + CI          | `/scripts/drift-check.sh` (see research above)               |
| **Security scanning**      | Dependabot + npm audit     | Free, automatic                                              |
| **Linting**                | ESLint + typescript-eslint | Enforce invariants via config, not code                      |
| **Formatting**             | Prettier                   | Zero-config consistency                                      |
| **Pre-commit**             | Husky + lint-staged        | Enforce gates without custom code                            |

**Guiding Principle:** Prefer configuration over code. Use existing tools with strict settings rather than building custom enforcement.

---

### Project Owner Decisions ✅ CONFIRMED

| Question                | Answer                                                                       |
| ----------------------- | ---------------------------------------------------------------------------- |
| **Target project**      | Greenfield (new project)                                                     |
| **Tech stack**          | TypeScript/Node.js (minimal code, prefer config)                             |
| **High-risk domains**   | Authentication, payment processing, permissions, infrastructure changes, PII |
| **Human response time** | Minutes (real-time collaboration)                                            |
| **Compliance needs**    | None currently                                                               |

**Design Principle:** Minimize custom code. Prefer development environment configuration (ESLint, TypeScript strict mode, pre-commit hooks, CI workflows) to satisfy requirements wherever possible.

---

### Completed Experiments ✅

| Experiment         | Status        | Result                                                              |
| ------------------ | ------------- | ------------------------------------------------------------------- |
| Cursor Rules Test  | ✅ Done       | Validated MDC format works (test files removed after validation)    |
| Slash Command Test | ✅ Done       | Validated slash commands work (test files removed after validation) |
| Worktree Pattern   | ✅ Documented | Manual setup required, see Research Q2                              |

### Remaining Experiments (Do After Setup)

1. **Confidence Calibration:** Rate confidence on 10 decisions, track outcomes
2. **Drift Baseline:** Run `drift-check.sh` on existing codebase
3. **End-to-End Pilot:** One small feature through all 6 phases
4. **Adversarial Test:** Have QA/Security find planted bugs
5. **Context Limit Test:** Vary Steward context, measure quality

---

### Known Risks & Updated Mitigations

| Risk                             | Likelihood | Impact | Mitigation                                                                       |
| -------------------------------- | ---------- | ------ | -------------------------------------------------------------------------------- |
| **Cursor changes break setup**   | High       | Medium | Use `.cursor/rules/*.mdc` (documented format); keep prompts portable             |
| **Agent hallucination**          | High       | High   | Require executable proof; verification gates; never trust explanations           |
| **Confidence scores unreliable** | High       | Medium | Use calibrated prompts (see Q6); multi-agent validation; conservative thresholds |
| **Context drift**                | Medium     | High   | SYSTEM_STATE.md summary; hierarchical reading; memory contracts                  |
| **Agents ignore Steward**        | Medium     | High   | Slash commands check status; human audit weekly                                  |
| **Tests-first too rigid**        | Medium     | Low    | Allow `spike:` and `poc:` labeled exceptions                                     |
| **Parallel agent conflicts**     | Medium     | Medium | Pre-assigned tasks in worktrees.json; clear file ownership                       |
| **Drift undetected**             | Low        | Medium | Weekly CI job; alert on threshold breach                                         |
| **Human bottleneck returns**     | Low        | High   | Async approval; strict interrupt policy; default-allow for Lane A/B              |

---

## Success Criteria

### Speed Metrics

| Metric                            | Target    | Stretch   |
| --------------------------------- | --------- | --------- |
| Intent → Shipped (small feature)  | < 4 hours | < 2 hours |
| Intent → Shipped (medium feature) | < 2 days  | < 1 day   |
| Intent → Shipped (large feature)  | < 1 week  | < 3 days  |
| Phase transition time             | < 30 min  | < 10 min  |

### Quality Metrics

| Metric                                 | Target                  | Why                                     |
| -------------------------------------- | ----------------------- | --------------------------------------- |
| Verification pass rate (first attempt) | > 80%                   | Tests-first should reduce failures      |
| Post-ship bugs found                   | < 5% of shipped intents | Adversarial verification catches issues |
| Rollbacks needed                       | < 2% of deploys         | Good rollback plans reduce risk         |
| Security findings post-ship            | 0 critical, < 2 medium  | Security agent effectiveness            |

### Process Metrics

| Metric                                  | Target         | Why                                                       |
| --------------------------------------- | -------------- | --------------------------------------------------------- |
| Human interrupts per feature            | < 2            | Humans are for judgment, not rubber-stamping              |
| Kill rate (vs shipped)                  | 10-20%         | Too low = not trying hard things; too high = poor scoping |
| Drift metrics within baseline           | > 90% of weeks | System staying healthy                                    |
| Agent disagreements resolved by Steward | > 80%          | Steward effectiveness                                     |
| Agent disagreements escalated to human  | < 20%          | System autonomy                                           |

### What Success Looks Like

- AI team ships faster than equivalent human team
- Quality is measurably higher (fewer bugs, better test coverage)
- Humans only intervene for genuine judgment calls
- System doesn't degrade over time (drift controlled)
- Failed approaches are captured and not repeated

---

## Risk Mitigation

| Risk                                | Likelihood | Impact | Mitigation                                                                                   |
| ----------------------------------- | ---------- | ------ | -------------------------------------------------------------------------------------------- |
| **Cursor feature changes**          | High       | Medium | Document fallback patterns; keep prompts portable; use `.cursorrules` as backup              |
| **Agent hallucination**             | High       | High   | Require executable proof; verification gates; never trust explanations alone                 |
| **Confidence scores unreliable**    | High       | Medium | Cross-validate with multiple agents; calibrate with experiments; use conservative thresholds |
| **Context drift between agents**    | Medium     | High   | State anchoring via workflow-state files; agents MUST read state before acting               |
| **Agents ignore Steward decisions** | Medium     | High   | Gate commands check status; humans audit periodically; add enforcement to prompts            |
| **Tests-first too rigid**           | Medium     | Low    | Define explicit exceptions for exploratory spikes; allow "spike" intents                     |
| **Parallel agents conflict**        | Medium     | Medium | Strong task isolation; `.agent-id` coordination; clear ownership in worktrees.json           |
| **Scope creep via agents**          | Medium     | Medium | Kill criteria; Steward enforcement; penalize large diffs                                     |
| **Do-not-repeat ledger ignored**    | Medium     | Medium | Agents MUST check before proposing; add to gate checklist                                    |
| **Drift detection too slow**        | Low        | Medium | Automate to CI; alert on threshold breach                                                    |
| **Human bottleneck returns**        | Low        | High   | Strict interrupt policy; async approval option; clear escalation rules                       |
| **Over-engineering by agents**      | Medium     | Medium | Penalize cleverness; reward simplicity; review for unused abstractions                       |

---

## Appendix: Key Terminology

| Term                  | Definition                                                              |
| --------------------- | ----------------------------------------------------------------------- |
| **Intent**            | A planned feature, bug fix, or tech debt item—the unit of work          |
| **Intent Ledger**     | The `/intent/` directory containing all planned and historical work     |
| **Kill**              | Permanently stop work on an intent (not pause—full stop with rationale) |
| **Block**             | Temporarily halt work pending additional information or decisions       |
| **Gate**              | A checkpoint where work must be approved before proceeding              |
| **Drift**             | Gradual degradation of system quality or architecture coherence         |
| **Canon**             | The authoritative architecture document (CANON.md)                      |
| **Steward**           | The executive agent with veto power over all work                       |
| **Adversarial Swarm** | Multiple agents simultaneously trying to break an implementation        |
| **Truth Stack**       | The hierarchy of sources when facts conflict                            |
| **Autopass Lane**     | A risk-based category determining how much review is required           |

---

## Next Steps (Prioritized)

### Immediate (Before Implementation)

1. **Research questions answered:** ✅
   - [x] Verified Cursor uses `.cursor/rules/*.mdc` (not agents)
   - [x] Verified slash commands work via `.cursor/commands/*.md`
   - [x] Documented parallel agent/worktree workflow
2. **Define target project:**
   - [ ] Choose greenfield or existing codebase
   - [ ] Confirm tech stack (recommendation: TypeScript/Node.js)
   - [ ] Define what "high-risk" means for this domain

### Week 1

3. **Create repository structure** (Phase 1 tasks)
4. **Write agent rules** (Phase 2 tasks) — use `.cursor/rules/*.mdc` format
5. **Write core slash commands** (`/new_intent`, `/ship`, `/verify`)
6. **Create helper scripts** (`scripts/drift-check.sh`, `scripts/setup-worktrees.sh`)

### Week 2

7. **Set up GitHub integration** (Phase 4 tasks)
8. **Run pilot feature** (Phase 5)
9. **Document learnings and adjust**

### Ongoing

10. **Calibrate confidence thresholds** based on real data
11. **Build drift baseline** over first month
12. **Expand do-not-repeat ledger** as failures occur
13. **Tune agent prompts** based on friction

---

## Changelog

| Version | Date       | Changes                                                                                                                                                                                                                                                                                                                         |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.5     | 2026-01-12 | **Documentation Review:** Updated AGENTS.md Truth Hierarchy to match PLAN.md with full explanatory text. Created missing `/drift_check` slash command. Enhanced README.md with key features and agent roles. Verified all cross-references and file paths. All documentation now consistent and accurate.                       |
| 1.4     | 2026-01-12 | **Owner Decisions Confirmed:** Greenfield project, TypeScript/Node.js stack, minimal code philosophy (prefer config). High-risk domains: auth, payments, permissions, infra, PII. Human response time: minutes. Added ESLint, Prettier, Husky to tech stack.                                                                    |
| 1.3     | 2026-01-12 | **Consistency Review:** Fixed Next Steps to reflect completed research. Added Follow-up Research Items (F1-F6). Updated repo structure with missing files (SYSTEM_STATE.md, golden-data/, disagreements.md, confidence-calibration.json). Clarified /ship command role-switching mechanism since Cursor lacks native subagents. |
| 1.2     | 2026-01-12 | **Research Complete:** Answered all 12 research questions with concrete implementations. Corrected Cursor file format (`.mdc` not `.md`). Added drift-check script, confidence calibration patterns, replay validation, agent disagreement protocol. Validated with test files (removed after validation).                      |
| 1.1     | 2026-01-12 | Added Truth Hierarchy, Cost-Awareness, Negative Knowledge Repository, Time-Scale Separation, Memory & State Discipline, Adversarial Swarm, Reward Shaping, expanded Research section                                                                                                                                            |
| 1.0     | 2026-01-12 | Initial plan from ChatGPT conversation                                                                                                                                                                                                                                                                                          |

---

_Generated from ChatGPT conversation: ShipIt Design_
_Plan Version: 1.5_
_Last Updated: 2026-01-12_

## Files Created During Research

| File                                  | Purpose |
| ------------------------------------- | ------- |
| (Test files removed after validation) |         |
