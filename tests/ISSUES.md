# ShipIt Test Runs

This file logs **test runs only**. Issues discovered during runs are tracked on GitHub (see `_system/behaviors/WORK_TEST_PLAN_ISSUES.md`).

## Counting Conventions

- **Steps Executed**: count of steps with status **✅ PASS** or **❌ FAIL** (exclude **⏭️ SKIP**).
- **Steps Skipped**: count of steps with status **⏭️ SKIP**.
- **Steps Total:** Steps Executed + Steps Skipped.

## Test Runs

### Run: 2026-02-09T18:24:00Z (test-project)

**Steps Total:** 42  
**Steps Executed:** 42  
**Steps Skipped:** 0  
**Steps Passed:** 42  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS

#### Summary

| Step | Name                          | Status  | Severity | Notes                                                                      |
| ---- | ----------------------------- | ------- | -------- | -------------------------------------------------------------------------- |
| 2-2  | Validate project structure    | ✅ PASS | -        | project.json, work/intent/, work/roadmap/, .cursor/commands/               |
| 3-1  | Run scope-project             | ✅ PASS | -        | Fixture scope description                                                  |
| 3-2  | Answer follow-ups             | ✅ PASS | -        | API-only, JSON file, Single-user, none, all features, deps none            |
| 3-3  | Verify intent files           | ✅ PASS | -        | intent/features/F-001.md .. F-003.md                                       |
| 3-4  | Verify outputs                | ✅ PASS | -        | project-scope.md, work/roadmap/\*, work/release/plan.md                    |
| 4-1  | Create single intent          | ✅ PASS | -        | F-004 "Add due dates to todos"                                             |
| 5-1  | Run generate-release-plan     | ✅ PASS | -        |                                                                            |
| 5-2  | Verify release plan           | ✅ PASS | -        | ## Summary, ## R1, Total intents                                           |
| 6-1  | Run generate-roadmap          | ✅ PASS | -        |                                                                            |
| 6-2  | Verify roadmap                | ✅ PASS | -        | Roadmap reflects intents/deps                                              |
| 7-1  | Check template fields         | ✅ PASS | -        | Priority, Effort, Release Target                                           |
| 7-2  | Update intent fields          | ✅ PASS | -        | F-001: p0, s, R1                                                           |
| 7-3  | Regenerate release plan       | ✅ PASS | -        |                                                                            |
| 7-4  | Verify ordering               | ✅ PASS | -        | F-001 in R1                                                                |
| 8-1  | Edit dependencies             | ✅ PASS | -        | F-001 depends on F-002                                                     |
| 8-2  | Regenerate release plan       | ✅ PASS | -        |                                                                            |
| 8-3  | Verify F-002 before F-001     | ✅ PASS | -        | F-002 then F-001 in R1                                                     |
| 9-1  | Add fake dependency           | ✅ PASS | -        | F-999 added to F-001                                                       |
| 9-2  | Regenerate release plan       | ✅ PASS | -        |                                                                            |
| 9-3  | Verify missing deps section   | ✅ PASS | -        | work/release/plan.md lists missing F-999                                   |
| 10-1 | Create new intent             | ✅ PASS | -        | F-005 "Awesome Banner"                                                     |
| 10-2 | Verify roadmap + release      | ✅ PASS | -        | Roadmap and release plan refreshed                                         |
| 11-1 | Run /ship F-001               | ✅ PASS | -        | workflow-orchestrator created state files (lib + workflow-templates added) |
| 11-2 | Verify 01_analysis.md created | ✅ PASS | -        |                                                                            |
| 11-3 | Verify 02_plan.md created     | ✅ PASS | -        |                                                                            |
| 11-4 | Verify plan gate              | ✅ PASS | -        | Plan approval checklist present                                            |
| 12-1 | Run /verify F-001             | ✅ PASS | -        | 04_verification.md updated                                                 |
| 12-2 | Verify verification outputs   | ✅ PASS | -        |                                                                            |
| 13-1 | Run /drift_check              | ✅ PASS | -        | \_system/drift/metrics.md created                                          |
| 13-2 | Verify drift outputs          | ✅ PASS | -        |                                                                            |
| 14-1 | Run /deploy staging           | ✅ PASS | -        | Readiness checks executed; Manual mode                                     |
| 14-2 | Verify readiness-only deploy  | ✅ PASS | -        | No real deployment                                                         |
| 15-1 | Create disposable intent      | ✅ PASS | -        | F-006 "Temporary kill intent"                                              |
| 15-2 | Run /kill F-006               | ✅ PASS | -        |                                                                            |
| 15-3 | Verify status = killed        | ✅ PASS | -        | F-006 status killed                                                        |
| 15-4 | Verify kill rationale         | ✅ PASS | -        | Recorded in intent file                                                    |
| 15-5 | Verify active.md updated      | ✅ PASS | -        | active.md reflects killed                                                  |
| 16   | Approve plan                  | ✅ PASS | -        | Plan approved, workflow proceeded                                          |
| 17   | Write tests (TDD)             | ✅ PASS | -        | todo-store tests written first, failed then passed                         |
| 18   | Implement                     | ✅ PASS | -        | src/store/todo-store.ts, tests pass                                        |
| 19   | Verify                        | ✅ PASS | -        | pnpm test, 04_verification updated                                         |
| 20   | Documentation                 | ✅ PASS | -        | CHANGELOG.md, 05_release_notes.md                                          |
| 21   | Ship                          | ✅ PASS | -        | F-001 shipped, active.md updated                                           |
| 22   | Deploy readiness              | ✅ PASS | -        | Readiness checks passed                                                    |
| 23   | Final project state           | ✅ PASS | -        | 1 shipped, 1 killed, rest planned; artifacts exist                         |
| 24   | Final test report             | ✅ PASS | -        | Summary recorded                                                           |

#### Issues Found This Run

- **Unblocking fixes (no GitHub issue filed):** Test project was missing `scripts/lib/intent.sh` and `scripts/workflow-templates/` (phases.yml + .tpl files). Added them so workflow-orchestrator and kill-intent could run.
- **Framework follow-up (done):** `scripts/init-project.sh` was updated to copy `scripts/lib/`, `scripts/workflow-templates/`, and `scripts/command-manifest.yml` into new projects, and to include `fix-intents.sh` plus help/status/suggest in the script list. New projects created after this change should pass step 11-1 without manual additions.
