# ShipIt Test Runs

This file logs **test runs only**. Issues discovered during runs are tracked on GitHub (see `behaviors/WORK_TEST_PLAN_ISSUES.md`).

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
