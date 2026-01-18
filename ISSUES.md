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
