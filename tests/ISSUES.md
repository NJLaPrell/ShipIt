# ShipIt Test Runs

This file logs **test runs only**. Issues discovered during runs are tracked on GitHub (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md`).

## Counting Conventions

- **Steps Executed**: count of steps with status **✅ PASS** or **❌ FAIL** (exclude **⏭️ SKIP**).
- **Steps Skipped**: count of steps with status **⏭️ SKIP**.
- **Steps Total:** Steps Executed + Steps Skipped.

## Test Runs

### Run: 2026-02-09T21:00:00Z (test-project)

**Steps Total:** 23  
**Steps Executed:** 23  
**Steps Skipped:** 0  
**Steps Passed:** 23  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS

#### Summary

| Step       | Name                           | Status  | Severity | Notes                                                                     |
| ---------- | ------------------------------ | ------- | -------- | ------------------------------------------------------------------------- |
| 2-2        | Validate project structure     | ✅ PASS | -        | project.json, work/intent/\_TEMPLATE.md, work/roadmap/, .cursor/commands/ |
| 3-1        | Run scope-project              | ✅ PASS | -        | Fixture scope; project-scope.md, F-001..F-003 created                     |
| 3-2        | Answer follow-ups              | ✅ PASS | -        | API-only, JSON file, Single-user, none, all, deps none                    |
| 3-3        | Verify intent files            | ✅ PASS | -        | work/intent/features/F-001..F-003.md                                      |
| 3-4        | Verify outputs                 | ✅ PASS | -        | project-scope.md, roadmap, release/plan.md                                |
| 4-1        | Create intent (due dates)      | ✅ PASS | -        | F-004 created; title corrected (fixture needs template choice)            |
| 5-1        | generate-release-plan          | ✅ PASS | -        | work/release/plan.md                                                      |
| 5-2        | Verify release plan            | ✅ PASS | -        | Summary, R1..R4, Total intents                                            |
| 6-1        | generate-roadmap               | ✅ PASS | -        |                                                                           |
| 6-2        | Verify roadmap                 | ✅ PASS | -        | Roadmap + dependencies.md                                                 |
| 7-1..7-4   | Template fields + update F-001 | ✅ PASS | -        | F-001 p0, s, R1; plan shows F-001 in R1                                   |
| 8-1..8-3   | Dependency ordering            | ✅ PASS | -        | F-002 before F-001 in R1                                                  |
| 9-1..9-3   | Missing deps (F-999)           | ✅ PASS | -        | Missing Dependencies section lists F-999                                  |
| 10-1..10-2 | New intent (Awesome Banner)    | ✅ PASS | -        | F-005 created; roadmap/release updated                                    |
| 11-1       | /ship F-001 (plan gate)        | ✅ PASS | -        | 01_analysis.md, 02_plan.md created                                        |
| 12-1       | /verify F-001                  | ✅ PASS | -        | 04_verification.md created/updated; tests + mutate + audit run            |
| 13-1       | /drift_check                   | ✅ PASS | -        | \_system/drift/metrics.md                                                 |
| 14-1       | /deploy staging                | ✅ PASS | -        | Readiness checks run (platform prompt; no deploy)                         |
| 15-1       | Create kill intent             | ✅ PASS | -        | F-006 Temporary kill intent                                               |
| 15-2       | /kill F-006                    | ✅ PASS | -        | F-006 status killed, rationale recorded                                   |
| 15-3       | Verify kill                    | ✅ PASS | -        | active.md updated                                                         |
| 16-1..16-3 | Approve plan                   | ✅ PASS | -        | Plan approved; workflow proceeded                                         |
| 17-1..17-3 | Write tests (TDD)              | ✅ PASS | -        | tests/data/todos.test.ts; tests passed after impl                         |
| 18-1..18-4 | Implement F-001                | ✅ PASS | -        | src/data/todos.ts; all tests pass                                         |
| 19-1..19-3 | Verify                         | ✅ PASS | -        | pnpm test, verification doc updated                                       |
| 20-1..20-2 | Documentation                  | ✅ PASS | -        | 05_release_notes.md                                                       |
| 21-1..21-4 | Ship F-001                     | ✅ PASS | -        | F-001 status shipped; active.md; release/roadmap regen                    |
| 22-1..22-2 | Deploy readiness               | ✅ PASS | -        | Readiness checks passed (lint fix applied)                                |
| 23-1..23-4 | Final project state            | ✅ PASS | -        | ≥1 shipped (F-001), ≥1 killed (F-006); artifacts; pnpm test/typecheck     |
| 24-1..24-3 | Final test report              | ✅ PASS | -        | Summary in ISSUES.md                                                      |

#### Issues Found This Run

- **validate-intents.sh:** Unbound variable `issues[@]` at line 192 (low). File in framework repo if desired.
- **new-intent non-interactive:** Fixture input stream must include template choice (1) after type choice so title is consumed correctly (doc/test fix).
