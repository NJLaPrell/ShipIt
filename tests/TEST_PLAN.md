# Test Plan: ShipIt End-to-End

This plan validates initialization, scoping, intent creation, roadmap/release planning, and workflow commands in a clean test project.

## Prerequisites

- Cursor IDE installed
- Node.js 20+ and `pnpm` available
- This repository open in Cursor

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

> **Note:** If any step in Section 1 fails, record results in the framework
> `tests/ISSUES.md` (root project). After opening `./projects/shipit-test`
> in a new window, record subsequent failures in the test project's
> `tests/ISSUES.md`.

---

## 2) Open the Test Project as Its Own Workspace

1. In Cursor, open the folder:
   - `./projects/shipit-test`

2. Verify:
   - `project.json` exists
   - `intent/` directory exists with `_TEMPLATE.md`
   - `roadmap/` directory exists
   - `.cursor/commands/` exists

---

## 3) Scope the Project (Interactive Follow-Ups)

1. Run:
   - `/scope-project "Build a todo list app with CRUD, tagging, and persistence"`
   - If the assistant does not run the script, manually run:
     - `./scripts/scope-project.sh "Build a todo list app with CRUD, tagging, and persistence"`

2. When the scoping script prompts, enter these exact responses:
   - **Is a UI required (API-only, CLI, Web)?** `API-only`
   - **What persistence should be used (JSON file, SQLite, etc.)?** `JSON file`
   - **Single-user or multi-user?** `Single-user`
   - **Authentication required (none, API key, full auth)?** `API key`
   - **Any non-functional requirements (performance, scaling, etc.)?** `p95 < 200ms, tests required`
   - **Open Questions (optional):** `done`
   - **Feature candidates (one per line):**
     - `Todo data model + persistence layer`
     - `CRUD HTTP API for todos`
     - `Tagging + filtering`
     - `done`
   - **Select features to generate intents:** `all`

3. When prompted for dependencies per intent, enter logical dependencies:
   - Foundation layers (persistence, auth) should have `none`
   - Features that need data storage should depend on persistence
   - Higher-level features should depend on lower-level ones

4. Verify:
   - Follow-up answers are captured in `project-scope.md`
   - Intent selection is recorded in `project-scope.md`
   - `project-scope.md` is created and filled in
   - `intent/` contains generated intent files
   - `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` updated (intents with no dependencies in Now; dependent intents in Next/Later)
   - `release/plan.md` exists and contains an ordered list

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
   - **Select risk [1-3]:** `2`

3. Verify:
   - A new intent file appears in `intent/` (e.g., `F-002.md`)
   - `roadmap/*.md` refreshes
   - `release/plan.md` refreshes

---

## 5) Validate Release Plan Generation

1. Run:
   - `/generate-release-plan`

2. Verify:
   - `release/plan.md` contains:
     - Summary with counts
     - Ordered intents per release
     - Missing dependency section if any placeholders exist

---

## 6) Validate Roadmap Generation

1. Run:
   - `/generate-roadmap`

2. Verify:
   - `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` reflect intent status/dependencies

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
   - `release/plan.md` includes a **Missing Dependencies** section listing `F-999`

---

## 10) Validate Roadmap + Release from New Intents

1. Create another intent with `/new_intent`
2. Verify that both:
   - `roadmap/*.md` updates
   - `release/plan.md` updates

---

## 11) Cleanup (Optional)

If you want to remove the test project:
- Delete `./projects/shipit-test`

