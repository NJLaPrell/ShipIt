# ShipIt Test Runs

This file logs **test runs only**. Issues discovered during runs are tracked on GitHub (see `behaviors/WORK_TEST_PLAN_ISSUES.md`).

## Counting Conventions

- **Steps Executed**: count of steps with status **✅ PASS** or **❌ FAIL** (exclude **⏭️ SKIP**).
- **Steps Skipped**: count of steps with status **⏭️ SKIP**.
- **Steps Total**: Steps Executed + Steps Skipped.

## Test Runs

### Run: 2026-01-23T23:57:01Z (test-project)

**Steps Executed:** 19  
**Steps Passed:** 17  
**Steps Failed:** 2  
**Blocking Issues:** 0  
**Result:** ❌ FAIL

#### Summary

| Step | Name                        | Status  | Severity | Notes                                             |
| ---- | --------------------------- | ------- | -------- | ------------------------------------------------- |
| 2-2  | Validate project structure  | ✅ PASS | -        |                                                   |
| 3-1  | Run scope-project           | ✅ PASS | -        |                                                   |
| 3-2  | Answer follow-ups           | ✅ PASS | -        |                                                   |
| 3-3  | Verify intent files         | ✅ PASS | -        |                                                   |
| 3-4  | Verify outputs              | ✅ PASS | -        |                                                   |
| 4-1  | Create single intent        | ✅ PASS | -        | Created F-004                                     |
| 5-1  | Run generate-release-plan   | ✅ PASS | -        |                                                   |
| 5-2  | Verify release plan         | ✅ PASS | -        |                                                   |
| 6-1  | Run generate-roadmap        | ✅ PASS | -        |                                                   |
| 6-2  | Verify roadmap              | ✅ PASS | -        |                                                   |
| 7-1  | Check template fields       | ✅ PASS | -        |                                                   |
| 7-2  | Update intent fields        | ✅ PASS | -        | F-001: p0, s, R1                                  |
| 7-3  | Regenerate release plan     | ✅ PASS | -        |                                                   |
| 7-4  | Verify ordering             | ✅ PASS | -        | F-001 in R1                                       |
| 8-1  | Edit dependencies           | ✅ PASS | -        | F-001 depends on F-002                            |
| 8-2  | Regenerate release plan     | ✅ PASS | -        |                                                   |
| 8-3  | Verify F-002 before F-001   | ❌ FAIL | high     | F-002 in R2, F-001 in R1 (should be same release) |
| 9-1  | Add fake dependency         | ✅ PASS | -        | Added F-999 to F-001                              |
| 9-2  | Regenerate release plan     | ✅ PASS | -        |                                                   |
| 9-3  | Verify missing deps section | ❌ FAIL | medium   | No Missing Dependencies section found             |
| 10-1 | Create new intent           | ✅ PASS | -        | Created F-005 "Awesome Banner"                    |

#### Issues Found This Run

- (not recorded as GitHub issues in this historic run)

### Run: 2026-01-28T04:33:07Z (root-project)

**Steps Executed:** 4  
**Steps Passed:** 4  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS

#### Summary

| Step | Name                        | Status  | Severity | Notes                                 |
| ---- | --------------------------- | ------- | -------- | ------------------------------------- |
| 1-1  | Init project                | ✅ PASS | -        | Created `./projects/shipit-test`      |
| 1-2  | Provide inputs              | ✅ PASS | -        | stack=1, desc fixture, high-risk=none |
| 1-3  | Verify project dir created  | ✅ PASS | -        | `./projects/shipit-test` exists       |
| 1-4  | Verify required files exist | ✅ PASS | -        | All required files present            |

#### Issues Found This Run

- (none)

### Run: 2026-01-28T04:50:44Z (root-project)

**Steps Executed:** 4  
**Steps Passed:** 4  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS

#### Summary

| Step | Name                        | Status  | Severity | Notes                                 |
| ---- | --------------------------- | ------- | -------- | ------------------------------------- |
| 1-1  | Init project                | ✅ PASS | -        | Created `./projects/shipit-test`      |
| 1-2  | Provide inputs              | ✅ PASS | -        | stack=1, desc fixture, high-risk=none |
| 1-3  | Verify project dir created  | ✅ PASS | -        | `./projects/shipit-test` exists       |
| 1-4  | Verify required files exist | ✅ PASS | -        | All required files present            |

#### Issues Found This Run

- (none)

### Run: 2026-01-28T05:09:15Z (test-project)

**Steps Executed:** 23  
**Steps Passed:** 22  
**Steps Failed:** 1  
**Blocking Issues:** 1  
**Result:** ❌ FAIL

#### Summary

| Step | Name                          | Status  | Severity | Notes                                                                                                          |
| ---- | ----------------------------- | ------- | -------- | -------------------------------------------------------------------------------------------------------------- |
| 2-2  | Validate project structure    | ✅ PASS | -        |                                                                                                                |
| 3-1  | Run scope-project             | ✅ PASS | -        |                                                                                                                |
| 3-2  | Answer follow-ups             | ✅ PASS | -        |                                                                                                                |
| 3-3  | Verify intent files           | ✅ PASS | -        | Created `intent/features/F-001.md` .. `F-003.md`                                                               |
| 3-4  | Verify outputs                | ✅ PASS | -        | Created `project-scope.md`, updated `roadmap/*`, generated `release/plan.md`                                   |
| 4-1  | Create single intent          | ✅ PASS | -        | Created `intent/features/F-004.md`                                                                             |
| 5-1  | Run generate-release-plan     | ✅ PASS | -        |                                                                                                                |
| 5-2  | Verify release plan           | ✅ PASS | -        | Contains `## Summary`, `## R1`, and total counts                                                               |
| 6-1  | Run generate-roadmap          | ✅ PASS | -        |                                                                                                                |
| 6-2  | Verify roadmap                | ✅ PASS | -        | Roadmap reflects current intents/deps                                                                          |
| 7-1  | Check template fields         | ✅ PASS | -        | Verified fields exist; template enumerates allowed values                                                      |
| 7-2  | Update intent fields          | ✅ PASS | -        | F-001: p0, s, R1                                                                                               |
| 7-3  | Regenerate release plan       | ✅ PASS | -        |                                                                                                                |
| 7-4  | Verify ordering               | ✅ PASS | -        | F-001 scheduled in R1                                                                                          |
| 8-1  | Edit dependencies             | ✅ PASS | -        | F-001 depends on F-002                                                                                         |
| 8-2  | Regenerate release plan       | ✅ PASS | -        |                                                                                                                |
| 8-3  | Verify F-002 before F-001     | ✅ PASS | -        | F-002 ordered before F-001 in R1                                                                               |
| 9-1  | Add fake dependency           | ✅ PASS | -        | Added F-999 to F-001                                                                                           |
| 9-2  | Regenerate release plan       | ✅ PASS | -        |                                                                                                                |
| 9-3  | Verify missing deps section   | ✅ PASS | -        | `release/plan.md` lists missing `F-999`                                                                        |
| 10-1 | Create new intent             | ✅ PASS | -        | Created `intent/features/F-005.md`                                                                             |
| 10-2 | Verify roadmap + release      | ✅ PASS | -        | Roadmap and release plan refreshed                                                                             |
| 11-1 | Run /ship workflow            | ❌ FAIL | blocking | `pnpm workflow-orchestrator F-001` expects `intent/F-001.md` (not found; intents are under `intent/features/`) |
| 11-2 | Verify plan gate behavior     | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 12-1 | Run /verify                   | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 12-2 | Verify verification outputs   | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 13-1 | Run /drift_check              | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 13-2 | Verify drift outputs          | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 14-1 | Run /deploy staging           | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 14-2 | Verify readiness-only deploy  | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 15-1 | Create disposable intent      | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 15-2 | Run /kill                     | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 15-3 | Verify kill results           | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 16   | /ship approve plan            | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 17   | /ship write tests (TDD)       | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 18   | /ship implement               | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 19   | /ship verify                  | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 20   | /ship docs                    | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 21   | /ship ship                    | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 22   | Validate deployment readiness | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 23   | Validate final project state  | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |
| 24   | Generate final test report    | ⏭️ SKIP | blocking | Blocked by step 11-1                                                                                           |

#### Issues Found This Run

- #7 (blocking): workflow-orchestrator intent path mismatch (`intent/` vs `intent/features/`)
- #8 (medium): missing `behaviors/WORK_TEST_PLAN_ISSUES.md` (and missing `create-test-plan-issue` helper referenced by rules)
