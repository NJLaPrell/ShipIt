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

**Status:** Resolved (verified in shipit-test 2026-01-22).

### /scope-project response performed implementation work

**Observed behavior:** The assistant described implementing a full CLI todo app, modifying `src/index.ts` and `README.md`, and skipped test execution. In `./projects/shipit-test-2`, the code changes and README usage section exist, but no scope artifacts were generated.

**Expected behavior:** `/scope-project` should only ask follow-up questions, prompt for intent selection, and generate scoping outputs (`project-scope.md`, roadmap updates, `release/plan.md`). It must not implement production code or edit README.

**Notes:** In `./projects/shipit-test-2`, `project-scope.md` is missing, `release/plan.md` is missing, `roadmap/*.md` are unchanged, and only `intent/_TEMPLATE.md` exists (no generated intents).

**Evidence (assistant response):**
"Scoped the project by creating a ShipIt intent file... Implement CRUD, tagging, and persistence... index.ts +346... Updating README usage... Built a full CLI todo app... Tests not run."

**Resolution:** `init-project` now copies framework `.cursor/commands` and `.cursor/rules` into new projects, ensuring the updated `/scope-project` requirements are present; core scripts (including `scope-project.sh` and `generate-release-plan.sh`) are also copied into new projects.

**Status:** Resolved (verified in shipit-test 2026-01-22).

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

**Retest result (shipit-test-5):** The transcript shows the AI-driven flow was still used (not the deterministic script), and `project-scope.md` contains Q/A from the AI, not the scripted prompts. This means the deterministic flow is not being used by `/scope-project` in practice.

**Next fix:** Wire `/scope-project` to execute `./scripts/scope-project.sh` by default (or update the command to instruct the user to run the script and stop otherwise). Consider adding a guard in `.cursor/commands/scope_project.md` that refuses to proceed unless the script has been run.

**Resolution (implemented):** Updated `/.cursor/commands/scope_project.md` and `/.cursor/rules/pm.mdc` to require running `./scripts/scope-project.sh` and to forbid manual scoping in chat. `TEST_PLAN.md` now includes a fallback to run the script directly if the assistant fails to.

### /scope-project did not update roadmap files

**Observed behavior:** `roadmap/now.md`, `roadmap/next.md`, `roadmap/later.md` remain unchanged after scoping, even though an intent was generated.

**Expected behavior:** Roadmap files should reflect generated intents after `/scope-project`.

**Notes:** Observed in `./projects/shipit-test-3` during Test Plan step 3-1.

**Resolution:** Updated `/.cursor/commands/scope_project.md` to require running `pnpm generate-roadmap`; updated `scripts/scope-project.sh` to run `generate-roadmap.sh` when available.

**Retest result (shipit-test-4):** Roadmap updated, but all intents fell into `roadmap/later.md` due to status parsing error.

**Updated solution:** Fixed `scripts/generate-roadmap.sh` to read `## Status` from the next line and ignore `(none)` dependencies.

**Final solution:** `scripts/scope-project.sh` now runs `scripts/generate-roadmap.sh` after intent generation, ensuring roadmap updates every time.

**Retest result (shipit-test-5):** Roadmap updated, but placement differs from the updated test plan (F-005 in Now, F-001–F-004 in Next). This indicates intent dependencies/status are not aligned with test expectations for bucket placement.

**Next fix:** Update the deterministic script to allow explicit dependency input (already present) and set status/priority defaults to match the test plan, or update the test plan to reflect the intended categorization rules.

### Test step 3-4 validation failures (shipit-test-5)

**Observed behavior:** `project-scope.md` lacks intent selection details and does not follow the deterministic Q/A format. Roadmap buckets differ from the test plan expectation.

**Expected behavior:** `project-scope.md` should include recorded intent selection and follow the scripted Q/A format. Roadmap buckets should match the test plan expectation.

**Notes:** Verified in `./projects/shipit-test-5` during Test Plan step 3-4. Roadmap shows `F-005` in Now and `F-001`–`F-004` in Next; `project-scope.md` has no intent selection section.

### /scope-project ignored deterministic script and assumed answers

**Observed behavior:** The assistant claimed to run the scoping script with defaults (Web UI, SQLite, single-user, no auth) and generated intents without asking for user inputs.

**Expected behavior:** The scoping script must ask required questions and block without answers. No assumptions or defaults should be used without explicit user input.

**Evidence:** Transcript in `cursor_todo_list_app_project_scope.md` shows assumed defaults and no user-provided Q/A.

**Resolution:** Stripped `/.cursor/commands/scope_project.md` down to only "run the script, nothing else." Updated `/.cursor/rules/pm.mdc` to explicitly forbid manual scoping, assumed defaults, and any action other than running the script.

**Status:** Resolved (verified in shipit-test 2026-01-22).

### /scope-project modified intents to satisfy roadmap output

**Observed behavior:** The assistant edited `intent/F-002.md` dependencies and set `intent/F-005.md` status to `validating` just to populate roadmap buckets.

**Expected behavior:** Scoping must not mutate intent files beyond the generated content. Roadmap bucket population should never be "forced" by manual intent edits.

**Evidence:** Transcript in `cursor_todo_list_app_project_scope.md` states intent tweaks were made to unblock roadmap generation.

**Resolution:** Fixed `scripts/generate-roadmap.sh` to handle empty arrays properly (macOS bash + `set -u` workaround). Updated PM rules to explicitly forbid editing intents to fix roadmap output.

**Status:** Resolved (verified in shipit-test 2026-01-22).

### generate-roadmap.sh fails with empty buckets

**Observed behavior:** The assistant reported `generate-roadmap.sh` is "borked" when roadmap buckets are empty due to `set -u` + empty arrays in bash.

**Expected behavior:** The script should handle empty arrays gracefully.

**Resolution:** Fixed `scripts/generate-roadmap.sh` to use `${ARRAY[@]+"${ARRAY[@]}"}` syntax for safe empty array expansion.

**Status:** Resolved.

---

## 2026-01-22 (Full Test Plan Run)

### TEST PLAN COMPLETED SUCCESSFULLY ✅

All 10 test sections passed after fixes applied during this session.

---

### generate-roadmap.sh treated "None" as a dependency

**Observed behavior:** Intents with `- None - this is a foundation layer` under Dependencies were placed in "Next" instead of "Now" because the script treated any non-empty line as a dependency.

**Expected behavior:** Lines starting with "None", "(none)", or placeholder brackets like `[...]` should be ignored.

**Resolution:** Updated `scripts/generate-roadmap.sh` to filter out "None", "(none)", and placeholder text when parsing dependencies.

**Status:** Resolved.

---

### Intent template header mismatches

**Observed behavior:** Generated intents used `## Size` and `## Target Release`, but scripts expected `## Effort` and `## Release Target`. The test project template was also missing Priority/Effort/Release Target fields entirely.

**Expected behavior:** All intents should use consistent header names that match what scripts expect.

**Resolution:** 
- Updated test project template to include `## Priority`, `## Effort`, `## Release Target`
- Fixed all 6 intent files in test project to use correct headers
- Added missing fields to F-006

**Status:** Resolved.

---

### generate-release-plan.sh dependency ordering broken

**Observed behavior:** F-001 (which depends on F-002) was listed BEFORE F-002 in the release plan. The topological sort wasn't working because dependency IDs weren't being extracted correctly.

**Expected behavior:** Dependencies should be scheduled before the intents that depend on them.

**Root cause:** `parseDependencies` returned full strings like `"F-002 (JSON Persistence Layer) - description"`, but `topoSort` checked `ids.has(dep)` where `ids` contained just `"F-002"`. The check always failed.

**Resolution:** Updated `parseDependencies` in `scripts/generate-release-plan.sh` to extract just the intent ID (e.g., `F-002`) from dependency strings using regex `^([A-Z]-\d+)`.

**Status:** Resolved.

---

### Missing /generate-roadmap slash command

**Observed behavior:** Test plan step 6-1 referenced `pnpm generate-roadmap` instead of a slash command.

**Expected behavior:** All framework commands should be available as slash commands for consistency.

**Resolution:** Created `.cursor/commands/generate_roadmap.md` and updated TEST_PLAN.md to use `/generate-roadmap`.

**Status:** Resolved.

---

### Summary of Test Plan Results

| Step | Description | Result |
|------|-------------|--------|
| 1 | Initialize test project | ✅ |
| 2 | Validate project structure | ✅ |
| 3 | Scope project | ✅ |
| 4 | Create single intent | ✅ |
| 5 | Validate release plan generation | ✅ |
| 6 | Validate roadmap generation | ✅ |
| 7 | Check intent template fields | ✅ |
| 8 | Validate dependency ordering | ✅ |
| 9 | Validate missing dependencies reporting | ✅ |
| 10 | Validate roadmap + release from new intents | ✅ |

All issues from previous test runs have been addressed. The ShipIt framework is now functioning as designed.
