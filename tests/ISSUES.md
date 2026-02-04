# ShipIt Test Runs

This file logs **test runs only**. Issues discovered during runs are tracked on GitHub (see `behaviors/WORK_TEST_PLAN_ISSUES.md`).

## Counting Conventions

- **Steps Executed**: count of steps with status **✅ PASS** or **❌ FAIL** (exclude **⏭️ SKIP**).
- **Steps Skipped**: count of steps with status **⏭️ SKIP**.
- **Steps Total**: Steps Executed + Steps Skipped.

## Test Runs

### Run: 2026-02-04T01:13:00Z (test-project)

**Steps Total:** 23  
**Steps Executed:** 23  
**Steps Skipped:** 0  
**Steps Passed:** 23  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS

#### Summary

| Step | Name                                                    | Status  | Severity | Notes                                                                |
| ---- | ------------------------------------------------------- | ------- | -------- | -------------------------------------------------------------------- |
| 2-2  | Verify project (project.json, intent, roadmap, .cursor) | ✅ PASS | -        | All present                                                          |
| 3    | Scope project                                           | ✅ PASS | -        | Fixture inputs; project-scope.md, F-001–F-003, release/plan, roadmap |
| 4    | Create intent (Add due dates to todos)                  | ✅ PASS | -        | F-004 created; roadmap/release refreshed                             |
| 5    | Generate release plan                                   | ✅ PASS | -        | release/plan.md has Summary, R1–R4                                   |
| 6    | Generate roadmap                                        | ✅ PASS | -        | roadmap/\*.md updated                                                |
| 7    | Intent template fields + F-001 p0/s/R1                  | ✅ PASS | -        | F-001 in R1, order respects deps                                     |
| 8    | Dependency ordering (F-001→F-002)                       | ✅ PASS | -        | F-002 before F-001 in same release                                   |
| 9    | Missing deps (F-999)                                    | ✅ PASS | -        | Missing Dependencies section lists F-999                             |
| 10   | New intent (Awesome Banner)                             | ✅ PASS | -        | F-005 created; roadmap/release updated                               |
| 11   | /ship F-001 (plan gate)                                 | ✅ PASS | -        | 01_analysis, 02_plan created                                         |
| 12   | /verify F-001                                           | ✅ PASS | -        | 04_verification.md created/updated                                   |
| 13   | /drift_check                                            | ✅ PASS | -        | drift/metrics.md created/updated                                     |
| 14   | /deploy staging                                         | ✅ PASS | -        | Readiness checks ran; no real deploy                                 |
| 15   | /kill F-006                                             | ✅ PASS | -        | F-006 killed; rationale in intent; active.md updated                 |
| 16   | Approve plan                                            | ✅ PASS | -        | Plan filled and approved                                             |
| 17   | Write tests (TDD)                                       | ✅ PASS | -        | tests/todo.test.ts added; tests pass                                 |
| 18   | Implement                                               | ✅ PASS | -        | src/domain/todo.ts, todo-store; 03_implementation.md                 |
| 19   | Verify                                                  | ✅ PASS | -        | pnpm test green; 04_verification updated                             |
| 20   | Documentation                                           | ✅ PASS | -        | CHANGELOG, 05_release_notes                                          |
| 21   | Ship F-001                                              | ✅ PASS | -        | F-001 status shipped; active.md; release/plan refreshed              |
| 22   | Deploy readiness                                        | ✅ PASS | -        | Readiness checks passed                                              |
| 23   | Final project state                                     | ✅ PASS | -        | 1 shipped, 1 killed, rest planned; artifacts present                 |
| 24   | Final test report                                       | ✅ PASS | -        | ISSUES.md updated                                                    |

#### Issues Found This Run

- (none)
