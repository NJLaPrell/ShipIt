# Testing Issues Log

## 2026-01-18

### /scope-project did not ask follow-up questions or prompt for intent selection

**Observed behavior:** The AI assistant immediately created `intent/F-001.md` and suggested running `/ship F-001`, without asking follow-up questions or letting the user select which features to generate as intents.

**Expected behavior:** Ask follow-up questions until enough data exists to generate features/dependencies, then prompt the user to select which features to generate as intents before creating any intent files.

**Notes:** This occurred during Test Plan step 3-1 (`/scope-project "Build a todo list app with CRUD, tagging, and persistence"`).

**Resolution:** Updated `/.cursor/commands/scope_project.md` to require follow-up questions and intent selection before intent creation, and clarified behavior in `README.md`.

**Evidence (assistant response):**
"Scoped the project by creating a ShipIt intent file that captures the feature scope, constraints, acceptance criteria, and assumptions so we have a clean starting point for implementation. The new intent/F-001.md records CRUD + tagging + persistence requirements, flags a persistence invariant, and explicitly documents scope assumptions like a simple HTTP JSON API without UI unless you want it.
If you want a UI instead of (or in addition to) the API, say the word and I’ll adjust the assumptions and acceptance criteria.
Next steps:
If this scope looks good, run /ship F-001 to kick off implementation.
If you want edits to the intent (UI, storage choice, or extra constraints), tell me and I’ll update it."

### /scope-project outputs missing in test project

**Observed behavior:** After running `/scope-project`, `intent/F-001.md` exists, but `project-scope.md` and `release/plan.md` are missing. Roadmap files remain empty templates.

**Expected behavior:** `project-scope.md` should be created and populated; `release/plan.md` should be generated; `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` should reflect generated intents.

**Notes:** Verified in `./projects/shipit-test` during Test Plan step 3-4.

**Resolution:** Updated `scripts/scope-project.sh` to create a `release/plan.md` stub and run `generate-release-plan.sh` when available; updated `/.cursor/commands/scope_project.md` to require these outputs.

**Status:** Pending retest (requires new project with copied scripts/commands).

### /scope-project response performed implementation work

**Observed behavior:** The assistant described implementing a full CLI todo app, modifying `src/index.ts` and `README.md`, and skipped test execution. In `./projects/shipit-test-2`, the code changes and README usage section exist, but no scope artifacts were generated.

**Expected behavior:** `/scope-project` should only ask follow-up questions, prompt for intent selection, and generate scoping outputs (`project-scope.md`, roadmap updates, `release/plan.md`). It must not implement production code or edit README.

**Notes:** In `./projects/shipit-test-2`, `project-scope.md` is missing, `release/plan.md` is missing, `roadmap/*.md` are unchanged, and only `intent/_TEMPLATE.md` exists (no generated intents).

**Evidence (assistant response):**
"Scoped the project by creating a ShipIt intent file... Implement CRUD, tagging, and persistence... index.ts +346... Updating README usage... Built a full CLI todo app... Tests not run."

**Resolution:** `init-project` now copies framework `.cursor/commands` and `.cursor/rules` into new projects, ensuring the updated `/scope-project` requirements are present; core scripts (including `scope-project.sh` and `generate-release-plan.sh`) are also copied into new projects.

**Status:** Pending retest.

### /scope-project did not prompt for intent selection or capture answers

**Observed behavior:** The assistant listed follow-up questions in `project-scope.md` but did not ask for answers and still created `intent/F-001-todo-app.md`.

**Expected behavior:** Ask follow-up questions and capture answers before generating intents. Prompt the user to select which features become intents before creating any intent files.

**Notes:** Observed in `./projects/shipit-test-3` during Test Plan step 3-1. `project-scope.md` exists with questions, but no answers and an intent was generated anyway.

**Resolution:** Updated `/.cursor/commands/scope_project.md` to require waiting for answers and recording them in `project-scope.md`; updated `scripts/scope-project.sh` template to call out Q/A capture; updated `TEST_PLAN.md` to verify answers and intent selection are recorded.

**Retest result (shipit-test-4):** Q/A were recorded but answers were assumed without user input. Intents were generated without explicit user selection prompt.

**Updated solution:** Added explicit /scope-project enforcement in `/.cursor/rules/pm.mdc` (wait for answers, no assumptions, no code changes, run roadmap/release scripts) and added "stop and wait" requirement in `/.cursor/commands/scope_project.md`.

**Final solution:** Replaced free-form scoping with a deterministic interactive flow in `scripts/scope-project.sh` that:
- asks required follow-up questions and blocks without answers,
- records Q/A into `project-scope.md`,
- collects feature candidates and explicit intent selection,
- generates intents deterministically,
- runs roadmap and release plan scripts.

### /scope-project did not update roadmap files

**Observed behavior:** `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` remain unchanged after scoping, even though an intent was generated.

**Expected behavior:** Roadmap files should reflect generated intents after `/scope-project`.

**Notes:** Observed in `./projects/shipit-test-3` during Test Plan step 3-1.

**Resolution:** Updated `/.cursor/commands/scope_project.md` to require running `pnpm generate-roadmap`; updated `scripts/scope-project.sh` to run `generate-roadmap.sh` when available.

**Retest result (shipit-test-4):** Roadmap updated, but all intents fell into `roadmap/later.md` due to status parsing error.

**Updated solution:** Fixed `scripts/generate-roadmap.sh` to read `## Status` from the next line and ignore `(none)` dependencies.

**Final solution:** `scripts/scope-project.sh` now runs `scripts/generate-roadmap.sh` after intent generation, ensuring roadmap updates every time.
