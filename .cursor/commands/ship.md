# /ship

Orchestrated workflow for shipping features through ShipIt.

## Usage

```
/ship <intent-id>
```

Example: `/ship F-042`

## Prerequisites

- Project must be initialized (run `/init-project` first)
- `project.json` must exist and be valid
- Intent file must exist under `work/intent/**/<intent-id>.md` (commonly `work/intent/features/<intent-id>.md`)

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

## Operational Transparency Requirements

**CRITICAL: You must show evidence of all operations:**

1. **Script execution:** Display all prompts, responses, and errors from interactive scripts
2. **Command results:** Show output from `pnpm test`, `git commit`, `npm audit`, etc.
3. **Status updates:** Explicitly state:
   - "Starting Phase X: [description]"
   - "Phase X complete. Summary: [what was accomplished]"
   - "Proceeding to Phase Y: [next steps]"
4. **Next steps:** Always tell the user what to do next:
   - "Waiting for APPROVE to proceed"
   - "Review `work/workflow-state/02_plan.md` and confirm"
   - "No action needed - proceeding automatically"

**Never proceed silently.** The user should never have to ask "did you finish?"

## Content Display Rules (CRITICAL)

**To avoid transcript bloat, follow these rules:**

1. **Show content ONCE when created:**
   - When creating a new file: Show the full content
   - When creating a plan: Show the full plan ONCE

2. **Reference files later, don't re-display:**
   - After initial creation: Reference the file instead of showing full content
   - Use: "Updated `work/workflow-state/02_plan.md`" instead of showing entire plan again
   - Use: "Modified `src/server.ts` - added DELETE route" instead of showing entire file

3. **For updates, show diffs or summaries:**
   - When updating existing files: Show what changed, not the entire file
   - Use: "Added `deleteTodo()` function to `src/data/todoStore.ts`"
   - Or show a diff: `+ export async function deleteTodo(...) { ... }`

4. **Never duplicate:**
   - Don't show the same code block multiple times
   - Don't re-display plan documents after initial creation
   - Don't show entire test files multiple times - reference them

**Exception:** If user explicitly asks to see the content, then show it.

## Process

### Phase 1: Analysis (PM Role)

**Status:** "Starting Phase 1: Analysis (PM Role)"

**Switch to PM role** (read `.cursor/rules/pm.mdc`):

1. Read the intent file: `work/intent/**/<intent-id>.md` (commonly `work/intent/features/<intent-id>.md`)
2. Restate requirements clearly (no ambiguity)
3. Define acceptance criteria (executable, not subjective)
4. Score confidence:
   - Requirements clarity: 0.0-1.0
   - Domain assumptions: 0.0-1.0
5. Check `_system/do-not-repeat/` for similar failed approaches
6. Save output to `work/workflow-state/01_analysis.md`
7. **If confidence < 0.7, STOP and request human interrupt**

**Status:** "Phase 1 complete. Summary: [requirements clarified, X acceptance criteria defined, confidence: Y]. Proceeding to Phase 2: Planning."

### Phase 2: Planning (Architect Role)

**Status:** "Starting Phase 2: Planning (Architect Role)"

**Switch to Architect role** (read `.cursor/rules/architect.mdc`):

1. Read `work/workflow-state/01_analysis.md`
2. Propose technical approach
3. List files to create/modify (explicit file list)
4. Check against `_system/architecture/CANON.md` (must not violate)
5. Define rollback strategy
6. Save output to `work/workflow-state/02_plan.md`
7. **STOP: Present plan and ask for approval before any edits**

**Status:** "Phase 2 complete. Plan created: [X files to create, Y files to modify]. **WAITING FOR APPROVAL** - Review `work/workflow-state/02_plan.md` and type APPROVE to proceed."

**Gate:** Human approval required before proceeding.

### Phase 3: Test Writing (QA Role - BEFORE Implementation)

**Status:** "Starting Phase 3: Test Writing (QA Role)"

**Phase Boundary:** This phase is for writing tests ONLY. Do NOT add dependencies or modify infrastructure files unless:

1. Tests absolutely cannot run without them
2. You STOP and get explicit approval
3. You document the deviation

**Switch to QA role** (read `.cursor/rules/qa.mdc`):

1. Read `work/workflow-state/01_analysis.md` (acceptance criteria)
2. Write test cases for all acceptance criteria
3. Write edge case tests
4. Write property-based tests (using fast-check)
5. **Verify tests FAIL** (nothing to pass yet)
   - **CRITICAL: Show actual test output** - display the test failure messages, error stack traces, and test summary
   - Don't just say "tests fail" - show the evidence
   - **If tests need dependencies to run:** STOP, explain why, get approval, then add them
6. Commit tests separately: `git commit -m "test: add tests for <intent-id>"`
   - **CRITICAL: Show git command and confirmation** - display the actual `git commit` command and its output

**Status:** "Phase 3 complete. Summary: [X test cases written, tests verified to fail, tests committed]. Proceeding to Phase 4: Implementation."

**Critical:** Tests must exist BEFORE implementation.

### Phase 4: Implementation (Implementer Role)

**Status:** "Starting Phase 4: Implementation (Implementer Role)"

**Phase Boundary:** This phase is for implementation ONLY. Add dependencies and modify infrastructure files as specified in the approved plan. Do NOT write new tests (they should already exist from Phase 3).

**CRITICAL: Strict Plan Compliance**

**You MUST implement ONLY what is in the approved plan (`work/workflow-state/02_plan.md`).**

- **If you need something NOT in plan:** STOP immediately, explain why it's needed, get approval
- **If approval granted:** Update plan first, then implement
- **Never implement unplanned features without approval**
- **Never add endpoints, functions, or features "because they're needed" without approval**

**Switch to Implementer role** (read `.cursor/rules/implementer.mdc`):

1. Read `work/workflow-state/02_plan.md` (approved plan)
   - **Check plan for:** Which files to modify, which dependencies to add, which infrastructure files to update
   - **Identify what's in plan:** List all features, endpoints, functions that are approved
   - **If something is missing:** STOP and get approval before implementing
2. Verify tests exist (check `/tests/` directory)
3. Run tests (they should fail initially)
   - **CRITICAL: Show test output** - display failure messages
4. **Add dependencies** (as specified in plan's "Modified Files" section)
   - Only add dependencies listed in the plan
   - If plan says "Add dependencies: X, Y" - add them now
   - **If tests need dependencies not in plan:** STOP, explain why, get approval
5. **Modify infrastructure files** (as specified in plan)
   - Only modify files listed in plan (e.g., `.gitignore`, `package.json`)
   - If plan says "Update `.gitignore`" - do it now
6. **Implement ONLY what's in the approved plan**
   - Check each feature/endpoint/function against the plan
   - If it's not in plan: STOP and get approval
   - Example: If plan says "POST /api/todos" but you need "GET /api/todos": STOP, explain why, get approval
7. Make tests pass
   - **CRITICAL: Show test output** - display pass/fail results
8. Save progress to `work/workflow-state/03_implementation.md`
   - **CRITICAL: Document ALL deviations from plan accurately**
   - Compare what was implemented vs what was in the approved plan (`work/workflow-state/02_plan.md`)
   - If you added anything not in plan: List it explicitly with explanation AND approval status
   - If you skipped anything in plan: List it explicitly with explanation
   - If you modified approach: List it explicitly with explanation
   - **Never claim "No deviations" or "None" if there are deviations**
   - Format: "Deviations from Plan: [list each deviation] OR None (if truly no deviations)"
   - Example: "Deviations from Plan: Added GET /api/todos endpoint (not in plan, but needed for frontend to load todos)"
9. **If plan deviation needed, STOP and return to Phase 2**

**Status:** "Phase 4 complete. Summary: [X files created, Y files modified, Z tests passing]. Deviations: [list any deviations or 'None']. Proceeding to Phase 5: Verification."

### Phase 5: Verification (QA + Security Roles)

**Status:** "Starting Phase 5: Verification (QA + Security Roles)"

**Switch to QA role** (read `.cursor/rules/qa.mdc`):

1. Run all tests: `pnpm test`
   - **CRITICAL: Show test output** - display test results, pass/fail counts, coverage summary
2. Run mutation testing: `pnpm test:mutate` (Stryker)
   - **CRITICAL: Show mutation test results** - display mutation score, killed/survived mutants
3. Try to break the implementation (adversarial mindset)
4. Document findings
5. **Provide status update:** "Phase 5 (Verification) complete. Summary: [X tests passed, Y mutations killed, Z vulnerabilities found]"

**Switch to Security role** (read `.cursor/rules/security.mdc`):

1. Review for auth/input/secrets/PII issues
2. Run `npm audit` for dependency vulnerabilities
   - **CRITICAL: Show audit output** - display vulnerability counts and details
3. Check high-risk domains (require human approval)
4. Save results to `work/workflow-state/04_verification.md`
5. **If verification fails repeatedly, escalate to Steward for kill review**
6. **Provide status update:** "Security review complete. Findings: [summary]"

### Phase 6: Release (Docs + Steward Roles)

**Status:** "Starting Phase 6: Release (Docs + Steward Roles)"

**Switch to Docs role** (read `.cursor/rules/docs.mdc`):

1. Update README.md (if public APIs changed)
2. Update CHANGELOG.md
3. Write release notes
4. Save to `work/workflow-state/05_release_notes.md`

**Status:** "Docs updates complete. Summary: [README updated, CHANGELOG updated, release notes written]"

**Switch to Steward role** (read `.cursor/rules/steward.mdc`):

1. Final approval check:
   - All acceptance criteria met
   - No drift violations
   - Confidence scores acceptable
2. Make decision: APPROVE | BLOCK | KILL
   - **CRITICAL: Show decision and rationale** - explicitly state the decision and why
3. If APPROVE: Mark intent as `shipped` in intent file

**Status:** "Phase 6 complete. Steward decision: [APPROVE/BLOCK/KILL]. Rationale: [reason]. Workflow complete."

## Phase Boundary Rules (CRITICAL)

**Each phase has strict boundaries. Do NOT perform actions assigned to other phases.**

### Phase 1 (Analysis - PM Role)

**CAN DO:**

- Read intent files
- Write analysis documents
- Define acceptance criteria
- Score confidence

**CANNOT DO:**

- Modify source code
- Add dependencies
- Write tests
- Create/modify infrastructure files

### Phase 2 (Planning - Architect Role)

**CAN DO:**

- Read analysis documents
- Write plan documents
- List files to create/modify
- Check CANON.md compliance

**CANNOT DO:**

- Modify source code
- Add dependencies
- Write tests
- Create/modify infrastructure files

### Phase 3 (Test Writing - QA Role)

**CAN DO:**

- Write test files
- Run tests to verify they fail
- Commit test files

**CANNOT DO:**

- Add dependencies (unless tests absolutely require them - then STOP and get approval)
- Modify source code
- Modify infrastructure files (`.gitignore`, `package.json`, etc.) unless explicitly in plan for this phase
- Write production code

**If tests need dependencies:** STOP, explain why, get approval, then add them. Document the deviation.

### Phase 4 (Implementation - Implementer Role)

**CAN DO:**

- Add dependencies (as specified in plan)
- Modify infrastructure files (`.gitignore`, `package.json`, etc. as specified in plan)
- Write/modify source code
- Make tests pass

**CANNOT DO:**

- Write new tests (tests should already exist from Phase 3)
- Modify plan without approval
- Add features not in approved plan

**If action needed in wrong phase:** STOP, explain why, get approval to deviate, or return to Phase 2 to update plan.

## Rules

- **Small diffs:** Split large changes into multiple commits
- **Tests first:** If tests are missing, create them FIRST
- **No shortcuts:** If verification fails, fix or roll back—do not "explain it away"
- **Gates are blocking:** Never proceed past a gate without approval
- **Explicit role switching:** Always state when switching roles
- **Phase boundaries are strict:** Only perform actions assigned to current phase

## Workflow State Files

All state is saved to `work/workflow-state/`:

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
