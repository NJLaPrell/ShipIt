# Test Plan: ShipIt End-to-End

This plan validates the complete ShipIt workflow from project initialization through feature shipping.

> **Important:** For rules on creating, tracking, and archiving issues discovered during test execution, see [`_system/behaviors/WORK_TEST_PLAN_ISSUES.md`](../_system/behaviors/WORK_TEST_PLAN_ISSUES.md). All issue management follows the format and rules defined there.

## Test Coverage

| Phase          | Steps | Description                                                           |
| -------------- | ----- | --------------------------------------------------------------------- |
| **Setup**      | 1-6   | Project init, scoping, intent creation, roadmap/release               |
| **Planning**   | 7-10  | Template fields, dependencies, ordering                               |
| **Commands**   | 11-15 | /ship, /verify, /drift_check, /deploy, /kill                          |
| **Full Cycle** | 16-21 | Complete /ship workflow (approve → tests → implement → verify → ship) |
| **Validation** | 22-24 | Deployment readiness, final state, test report                        |

## Prerequisites

- Cursor IDE installed
- Node.js 20+ and `pnpm` available
- This repository open in Cursor
- GitHub CLI (`gh`) installed and authenticated (required for test-plan issue creation)
- A POSIX shell environment capable of running the scripts (macOS supported)

Preflight (run once before executing steps):

```bash
gh --version
gh auth status
```

---

## 1) Initialize a New Test Project

1. In Cursor, enter the following into the chat window:
   - `/init-project "shipit-test"`

2. The assistant will ask for 3 inputs. Reply with:

   ```
   1
   Test project for ShipIt end-to-end validation
   none
   ```

3. The assistant runs the init script and creates the project.

4. Verify:
   - New project created at `./projects/shipit-test`
   - `./projects/.gitkeep` exists
   - `./projects/shipit-test/project.json` exists

> **Note:** For rules on creating and managing issues during test execution, see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md`.
>
> **Issue recording:** All issues are created on GitHub. Test run summaries are recorded in `tests/ISSUES.md` (root project) or test project's `tests/ISSUES.md`, but issues themselves are tracked on GitHub.

---

## 2) Open the Test Project as Its Own Workspace

1. In Cursor, open the folder:
   - `./projects/shipit-test`

2. Verify:
   - `project.json` exists
   - `work/intent/` directory exists with `_TEMPLATE.md`
   - `work/roadmap/` directory exists
   - `.cursor/commands/` exists

---

## 3) Scope the Project (Interactive Follow-Ups)

1. Run:
   - `/scope-project "Build a todo list app with CRUD, tagging, and persistence"`
   - If the assistant does not run the script, manually run:
     - `./scripts/scope-project.sh "Build a todo list app with CRUD, tagging, and persistence"`

2. When the scoping script prompts, enter these exact responses:
   (Use fixture-aligned inputs from `tests/fixtures.json`.)
   - **Is a UI required (API-only, CLI, Web)?** `API-only`
   - **What persistence should be used (JSON file, SQLite, etc.)?** `JSON file`
   - **Single-user or multi-user?** `Single-user`
   - **Authentication required (none, API key, full auth)?** `none`
   - **Any non-functional requirements (performance, scaling, etc.)?** press Enter (accept default) or enter `p95 < 200ms`
   - **Confirm answers?** `y`
   - **Open Questions (optional, type 'done'):** `done`
   - **Feature candidates (one per line, then 'done'):**
     - `Todo data model + persistence layer`
     - `CRUD HTTP API for todos`
     - `Tagging + filtering`
     - `done`
   - **Select features to generate intents:** `all`
   - **Dependencies prompts:** enter `none` for each generated intent

3. When prompted for dependencies per intent, enter logical dependencies:
   - Foundation layers (persistence, auth) should have `none`
   - Features that need data storage should depend on persistence
   - Higher-level features should depend on lower-level ones

4. Verify:
   - Follow-up answers are captured in `project-scope.md`
   - Intent selection is recorded in `project-scope.md`
   - `project-scope.md` is created and filled in
   - `work/intent/` contains generated intent files
   - `work/roadmap/now.md`, `work/roadmap/next.md`, `work/roadmap/later.md` updated (intents with no dependencies in Now; dependent intents in Next/Later)
   - `work/release/plan.md` exists and contains an ordered list

---

## 4) Create a New Intent Manually (Roadmap + Release Auto-Refresh)

1. Run:
   - `/new_intent`

2. Enter the following prompts:
   - **Select type [1-3]:** `1`
   - **Title:** `Add due dates to todos`
   - **Motivation (each line, then 'done'):**
     - `Improve prioritization for users`
     - `Support basic deadline tracking`
     - `done`
   - **Select priority [1-4]:** `2`
   - **Select effort [1-3]:** `2`
   - **Select release target [1-4]:** `2`
   - **Dependencies:** `none`
   - **Select risk [1-3]:** `2`

3. Verify:
   - A new intent file appears in `work/intent/` (e.g., `F-002.md`)
   - `work/roadmap/*.md` refreshes
   - `work/release/plan.md` refreshes

---

## 5) Validate Release Plan Generation

1. Run:
   - `/generate-release-plan`

2. Verify:
   - `work/release/plan.md` contains:
     - Summary with counts
     - Ordered intents per release
     - Missing dependency section if any placeholders exist

---

## 6) Validate Roadmap Generation

1. Run:
   - `/generate-roadmap`

2. Verify:
   - `work/roadmap/now.md`, `work/roadmap/next.md`, `work/roadmap/later.md` reflect intent status/dependencies
   - `_system/artifacts/dependencies.md` exists (generated by the roadmap script)

---

## 7) Check Intent Template Fields

1. Open any new intent file and verify it contains:
   - `## Priority` with `p0 | p1 | p2 | p3`
   - `## Effort` with `s | m | l`
   - `## Release Target` with `R1 | R2 | R3 | R4`

2. Update the intent with:
   - `Priority` = `p0`
   - `Effort` = `s`
   - `Release Target` = `R1`

3. Run:
   - `/generate-release-plan`

4. Verify:
   - Intent is scheduled in `R1`
   - Order respects dependency + priority

---

## 8) Validate Dependency Ordering

1. Edit two intents:
   - In `F-001.md` add to Dependencies:
     - `- F-002`
   - In `F-002.md` leave Dependencies empty

2. Run:
   - `/generate-release-plan`

3. Verify:
   - `F-002` appears before `F-001` in the same release

---

## 9) Validate Missing Dependencies Reporting

1. In any intent file, add:
   - `- F-999` under `## Dependencies`

2. Run:
   - `/generate-release-plan`

3. Verify:
   - `work/release/plan.md` includes a **Missing Dependencies** section listing `F-999`

---

## 10) Validate Roadmap + Release from New Intents

1. Create another intent with `/new_intent`
   - Use the same prompt sequence as step 4 (type, title, motivation, priority, effort, release target, dependencies, risk)
2. Verify that both:
   - `work/roadmap/*.md` updates
   - `work/release/plan.md` updates

---

## 11) Validate /ship Workflow (Stops at Plan Gate)

**Prerequisite:** The test project must have `scripts/lib/` (e.g. intent.sh) and `scripts/workflow-templates/` (phases.yml + .tpl). Projects created by `init-project.sh` from the framework include these; if either is missing, step 11-1 will fail (e.g. `require_intent_file` undefined or orchestrator cannot find phase templates).

1. Run:
   - `/ship F-001`
2. Verify:
   - `work/workflow-state/01_analysis.md` is created
   - `work/workflow-state/02_plan.md` is created
   - The assistant **stops and requests plan approval** before any code edits

---

## 12) Validate /verify (Verification-Only)

1. Run:
   - `/verify F-001`
2. Verify:
   - The assistant switches to QA then Security roles
   - `work/workflow-state/04_verification.md` is created or updated
   - If mutation testing or audit tooling is missing, create a GitHub issue (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` for issue format)

---

## 13) Validate /drift_check

1. Run:
   - `/drift_check`
2. Verify:
   - `_system/drift/metrics.md` is created or updated
   - If `scripts/drift-check.sh` or related tooling is missing, create a GitHub issue (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` for issue format)

---

## 14) Validate /deploy (Readiness Checks Only)

1. Run:
   - `/deploy staging`
2. Verify:
   - The assistant switches to Steward role
   - Readiness checks are listed and executed up to any blocking failure
   - No real deployment is performed for the test project
   - Any missing scripts or configuration should result in a GitHub issue (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` for issue format)

---

## 15) Validate /kill

1. Create a disposable intent with `/new_intent`:
   - **Select type [1-3]:** `1`
   - **Title:** `Temporary kill intent`
   - **Motivation (each line, then 'done'):** `done`
   - **Select priority [1-4]:** `4`
   - **Select effort [1-3]:** `1`
   - **Select release target [1-4]:** `4`
   - **Dependencies:** `none`
   - **Select risk [1-3]:** `1`
2. Run:
   - `/kill F-XXX "Test kill flow"`
3. Verify:
   - The intent status is set to `killed`
   - Kill rationale and date are recorded in the intent file
   - `work/workflow-state/active.md` is updated

---

## 16) Complete /ship Workflow - Approve Plan

Continue the /ship workflow for a foundation intent.

1. **Review the plan:**
   - Read `work/workflow-state/02_plan.md`
   - Verify technical approach is sound

2. **Approve:**
   - Respond with `APPROVE` to proceed past the plan gate

3. **Verify:**
   - Workflow proceeds to test writing phase

---

## 17) Complete /ship Workflow - Write Tests (TDD)

1. **Switch to QA role:**
   - Read acceptance criteria from `work/workflow-state/01_analysis.md`

2. **Write tests FIRST:**
   - Create test file for the feature
   - Write unit tests for all acceptance criteria
   - Write edge case tests (empty inputs, errors, boundaries)

3. **Verify tests fail:**
   - Run `pnpm test`
   - Confirm new tests fail (nothing implemented yet)

---

## 18) Complete /ship Workflow - Implement

1. **Switch to Implementer role:**
   - Read approved plan from `work/workflow-state/02_plan.md`

2. **Implement the feature:**
   - Create files listed in the plan
   - Follow the technical approach exactly
   - No deviations from approved plan

3. **Make tests pass:**
   - Run `pnpm test` iteratively
   - All tests should pass when complete

4. **Document progress:**
   - Create `work/workflow-state/03_implementation.md`

---

## 19) Complete /ship Workflow - Verify

1. **Switch to QA role:**
   - Run full test suite: `pnpm test`
   - Check coverage: `pnpm test:coverage`
   - Attempt adversarial testing

2. **Switch to Security role:**
   - Review code for vulnerabilities
   - Run `pnpm audit`
   - Check for secrets/PII issues

3. **Document results:**
   - Update `work/workflow-state/04_verification.md`

---

## 20) Complete /ship Workflow - Documentation

1. **Switch to Docs role:**
   - Update `README.md` if APIs changed
   - Create/update `CHANGELOG.md`
   - Write release notes

2. **Create release notes:**
   - Create `work/workflow-state/05_release_notes.md`

---

## 21) Complete /ship Workflow - Ship

1. **Switch to Steward role:**
   - Review all acceptance criteria are met
   - Verify no drift violations
   - Check confidence scores are acceptable

2. **Make final decision:**
   - APPROVE: Mark intent as `shipped`
   - BLOCK: Document required fixes
   - KILL: If criteria cannot be met

3. **Update status:**
   - Update intent file: `status: shipped`
   - Update `work/workflow-state/active.md`

4. **Verify:**
   - Run `/generate-release-plan` - shipped intent reflected
   - Run `/generate-roadmap` - intent moved appropriately

---

## 22) Validate Deployment Readiness

1. Run:
   - `/deploy staging`

2. Verify:
   - Readiness checks execute
   - Results are logged
   - Steward makes appropriate decision based on checks

---

## 23) Validate Final Project State

1. **Verify intent lifecycle:**
   - At least one intent: `shipped`
   - At least one intent: `killed`
   - Remaining intents: `planned`

2. **Verify all workflow artifacts:**
   - `work/workflow-state/01_analysis.md` exists
   - `work/workflow-state/02_plan.md` exists
   - `work/workflow-state/03_implementation.md` exists
   - `work/workflow-state/04_verification.md` exists
   - `work/workflow-state/05_release_notes.md` exists
   - `work/workflow-state/active.md` is current

3. **Verify project health:**
   - `pnpm test` passes
   - `pnpm typecheck` passes
   - No critical security vulnerabilities

4. **Verify documentation:**
   - `README.md` is current
   - `CHANGELOG.md` has entries
   - `work/release/plan.md` is accurate

---

## 24) Generate Final Test Report

1. **Summarize test run:**
   - Total steps executed
   - Steps passed / failed
   - Issues discovered
   - **Phase summary** (Setup, Planning, Commands, Full cycle, Validation) so the run is scannable

2. **Update `tests/ISSUES.md`:**
   - Record final run summary (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` for format)
   - Mark overall result: PASS or FAIL
   - Reference GitHub issues by number in "Issues Found This Run" section
   - Follow issue creation and archiving rules defined in `_system/behaviors/WORK_TEST_PLAN_ISSUES.md` (all issues are created on GitHub)

3. **In-chat output:** When running via `/test_shipit`, the agent should emit progress at phase boundaries (see `.cursor/rules/test-runner.mdc`) and a final block that points to **tests/ISSUES.md** for the per-step table.
