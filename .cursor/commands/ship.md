# /ship

Orchestrated workflow for shipping features through the AI-Centric SDLC.

## Usage

```
/ship <intent-id>
```

Example: `/ship F-042`

## Prerequisites

- Project must be initialized (run `/init-project` first)
- `project.json` must exist and be valid
- Intent file must exist in `/intent/<intent-id>.md`

## Automated State Generation

Before starting, run:
\`\`\`bash
pnpm workflow-orchestrator <intent-id>
\`\`\`

This automatically creates all workflow state files for the 6 phases.

## Important: Role Switching

Cursor doesn't have native "subagents." You will switch roles by:
1. Reading the relevant rule file (e.g., `.cursor/rules/pm.mdc`)
2. Adopting that role's constraints and output format
3. Completing that role's tasks
4. Switching to the next role

**Always explicitly state when switching roles:** "Switching to [ROLE] role."

## Process

### Phase 1: Analysis (PM Role)

**Switch to PM role** (read `.cursor/rules/pm.mdc`):

1. Read the intent file: `/intent/<intent-id>.md`
2. Restate requirements clearly (no ambiguity)
3. Define acceptance criteria (executable, not subjective)
4. Score confidence:
   - Requirements clarity: 0.0-1.0
   - Domain assumptions: 0.0-1.0
5. Check `/do-not-repeat/` for similar failed approaches
6. Save output to `workflow-state/01_analysis.md`
7. **If confidence < 0.7, STOP and request human interrupt**

### Phase 2: Planning (Architect Role)

**Switch to Architect role** (read `.cursor/rules/architect.mdc`):

1. Read `workflow-state/01_analysis.md`
2. Propose technical approach
3. List files to create/modify (explicit file list)
4. Check against `/architecture/CANON.md` (must not violate)
5. Define rollback strategy
6. Save output to `workflow-state/02_plan.md`
7. **STOP: Present plan and ask for approval before any edits**

**Gate:** Human approval required before proceeding.

### Phase 3: Test Writing (QA Role - BEFORE Implementation)

**Switch to QA role** (read `.cursor/rules/qa.mdc`):

1. Read `workflow-state/01_analysis.md` (acceptance criteria)
2. Write test cases for all acceptance criteria
3. Write edge case tests
4. Write property-based tests (using fast-check)
5. **Verify tests FAIL** (nothing to pass yet)
6. Commit tests separately: `git commit -m "test: add tests for <intent-id>"`

**Critical:** Tests must exist BEFORE implementation.

### Phase 4: Implementation (Implementer Role)

**Switch to Implementer role** (read `.cursor/rules/implementer.mdc`):

1. Read `workflow-state/02_plan.md` (approved plan)
2. Verify tests exist (check `/tests/` directory)
3. Run tests (they should fail initially)
4. Implement exactly the approved plan (no deviations)
5. Make tests pass
6. Save progress to `workflow-state/03_implementation.md`
7. **If plan deviation needed, STOP and return to Phase 2**

### Phase 5: Verification (QA + Security Roles)

**Switch to QA role** (read `.cursor/rules/qa.mdc`):

1. Run all tests: `pnpm test`
2. Run mutation testing: `pnpm test:mutate` (Stryker)
3. Try to break the implementation (adversarial mindset)
4. Document findings

**Switch to Security role** (read `.cursor/rules/security.mdc`):

1. Review for auth/input/secrets/PII issues
2. Run `npm audit` for dependency vulnerabilities
3. Check high-risk domains (require human approval)
4. Save results to `workflow-state/04_verification.md`
5. **If verification fails repeatedly, escalate to Steward for kill review**

### Phase 6: Release (Docs + Steward Roles)

**Switch to Docs role** (read `.cursor/rules/docs.mdc`):

1. Update README.md (if public APIs changed)
2. Update CHANGELOG.md
3. Write release notes
4. Save to `workflow-state/05_release_notes.md`

**Switch to Steward role** (read `.cursor/rules/steward.mdc`):

1. Final approval check:
   - All acceptance criteria met
   - No drift violations
   - Confidence scores acceptable
2. Make decision: APPROVE | BLOCK | KILL
3. If APPROVE: Mark intent as `shipped` in intent file

## Rules

- **Small diffs:** Split large changes into multiple commits
- **Tests first:** If tests are missing, create them FIRST
- **No shortcuts:** If verification fails, fix or roll back—do not "explain it away"
- **Gates are blocking:** Never proceed past a gate without approval
- **Explicit role switching:** Always state when switching roles

## Workflow State Files

All state is saved to `workflow-state/`:
- `01_analysis.md` - PM analysis
- `02_plan.md` - Architect plan (requires approval)
- `03_implementation.md` - Implementer progress
- `04_verification.md` - QA + Security results
- `05_release_notes.md` - Docs updates
- `active.md` - Current active intent (updated by Steward)

## Parallel Work (Optional)

For large intents, you can split work into parallel tasks:

1. Split work into 3–6 independent tasks
2. Create worktrees: `git worktree add ../worktree-1 -b feature/task-1`
3. Open each worktree in separate Cursor window
4. Each worktree has its own `.agent-id` file
5. Coordinate via `worktrees.json` in main repo

See `scripts/setup-worktrees.sh` for automation.
