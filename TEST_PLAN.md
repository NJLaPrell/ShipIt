# Test Plan: ShipIt End-to-End

This plan validates initialization, scoping, intent creation, roadmap/release planning, and workflow commands in a clean test project.

## Prerequisites

- Cursor IDE installed
- Node.js 20+ and `pnpm` available
- This repository open in Cursor

---

## 1) Initialize a New Test Project

1. In Cursor, open the Command Palette and run:
   - `/init-project "shipit-test"`

2. When prompted, enter the following in order:
   - **Tech stack selection [1=TS/Node, 2=Python, 3=Other]:** `1`
   - **Project description:** `Test project for ShipIt end-to-end validation`
   - **High-risk domains (comma-separated or 'none'):** `none`

3. Verify:
   - New project created at `./projects/shipit-test`
   - `./projects/.gitkeep` exists
   - `./projects/shipit-test/project.json` exists

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

2. When the AI asks follow-up questions, enter these exact responses:
   - **Primary users?** `Single user`
   - **Platforms?** `Web`
   - **Data storage?** `SQLite`
   - **Authentication?** `None`
   - **Must-have features?** `Create, read, update, delete, tagging, search`
   - **Non-functional requirements?** `p95 < 200ms, tests required`
   - **External integrations?** `None`
   - **Out of scope?** `Collaboration, realtime, multi-user`

3. When prompted to select features to generate as intents, enter:
   - `all`

4. Verify:
   - `project-scope.md` is created and filled in
   - `intent/` contains generated intent files
   - `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` updated
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
   - `pnpm generate-roadmap`

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
   - `pnpm generate-release-plan`

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
   - `pnpm generate-release-plan`

3. Verify:
   - `F-002` appears before `F-001` in the same release

---

## 9) Validate Missing Dependencies Reporting

1. In any intent file, add:
   - `- F-999` under `## Dependencies`

2. Run:
   - `pnpm generate-release-plan`

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

