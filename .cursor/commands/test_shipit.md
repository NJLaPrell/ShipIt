# /test-shipit

Run the ShipIt end-to-end test plan.

## Mode Detection

**Check for `project.json` in current directory:**

- **If `project.json` exists AND contains `"name": "shipit-test"`:** You are in the TEST PROJECT. Start at step 2-2.
- **If `project.json` exists BUT name is NOT `shipit-test`:** STOP and report a blocking failure (wrong workspace).
- **Otherwise:** You are in the ROOT PROJECT. Run steps 1-1 through 1-4, then STOP.

## Root Project Mode (Steps 1-1 → 1-4)

### Before Starting

If `./projects/shipit-test` already exists, DELETE IT:

```bash
rm -rf ./projects/shipit-test
```

### GitHub Issue Tracking Preflight (Required)

This test plan records issues on GitHub (not in local files). Before running steps, verify `gh` is available and authenticated:

```bash
gh --version
gh auth status
```

If this fails, **STOP** and treat it as a **blocking** failure (issues cannot be recorded correctly). Follow `behaviors/WORK_TEST_PLAN_ISSUES.md`.

If `behaviors/WORK_TEST_PLAN_ISSUES.md` is not present in your current workspace, use `./scripts/create-test-plan-issue.sh` to file issues with consistent formatting.

### Where to Record Results

Root mode results must be written to `tests/ISSUES.md` (root ShipIt project).

**Important:** `tests/ISSUES.md` is **test run logging only**. Any failures that represent real issues must be created as **GitHub issues** per `behaviors/WORK_TEST_PLAN_ISSUES.md`, and the run should reference them by GitHub issue number.

### Guardrails

Before starting, verify the file exists:

- `tests/fixtures.json`

If missing, STOP and log a **blocking** failure.

### Execute Steps

**Step 1-1:** Initialize the test project (non-interactive using fixtures)

Use these exact inputs (from `tests/fixtures.json`):

- Tech stack: `1`
- Description: `Test project for ShipIt end-to-end validation`
- High-risk domains: `none`

Run:

```bash
rm -rf ./projects/shipit-test
printf "1\nTest project for ShipIt end-to-end validation\nnone\n" | ./scripts/init-project.sh shipit-test
```

**Step 1-2:** (Covered by Step 1-1) Verify the init used the exact fixture inputs.

**Step 1-3:** Verify `./projects/shipit-test` was created

**Step 1-4:** Verify these files exist in the new project:

- `project.json`
- `package.json`
- `tsconfig.json`
- `intent/_TEMPLATE.md`
- `architecture/CANON.md`
- `generated/roadmap/now.md`, `next.md`, `later.md`

### STOP HERE

After step 1-4 passes, output this message:

```
✅ Root project steps complete (1-1 through 1-4).

NEXT: Open ./projects/shipit-test in a NEW Cursor window, then run /test-shipit from there to continue testing.
```

**DO NOT continue to step 2. The user must open the test project in a separate workspace.**

---

## Test Project Mode (Steps 2-2 → 24)

**In-scope:** All steps in `tests/TEST_PLAN.md` from 2-2 through 24. Do NOT stop at step 10. Continue through commands (11-15), full /ship cycle (16-21), and validation (22-24) until completion or a blocking failure.

### Load Test Fixtures

Read `tests/fixtures.json` (or the framework's `tests/fixtures.json` if running from test project) for hardcoded inputs.

### GitHub Issue Tracking Preflight (Required)

Before executing steps, verify `gh` is available and authenticated:

```bash
gh --version
gh auth status
```

If this fails, **STOP** and treat it as a **blocking** failure. Follow `behaviors/WORK_TEST_PLAN_ISSUES.md` (includes repo resolution rules).

If `behaviors/WORK_TEST_PLAN_ISSUES.md` is not present in your current workspace, use `./scripts/create-test-plan-issue.sh` to file issues with consistent formatting.

### Execute Steps

Follow `tests/TEST_PLAN.md` starting from step 2-2.

**Use these hardcoded inputs:**

| Step | Input                                                                                                                                         |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| 3-1  | Scope: `"Build a todo list app with CRUD, tagging, and persistence"`                                                                          |
| 3-2  | Follow-ups: API-only, JSON file, Single-user, auth none. Select all features.                                                                 |
| 4-1  | Intent: `"Add due dates to todos"` (feature), priority=2, effort=2, release=2, deps=none, risk=2                                              |
| 7-2  | Update F-001: priority=p0, effort=s, release_target=R1                                                                                        |
| 8-1  | F-001 deps: `- F-002`, F-002 deps: `(none)`                                                                                                   |
| 9-1  | Add `- F-999` to F-001 dependencies                                                                                                           |
| 10-1 | Create intent: `"Awesome Banner"` (feature), priority=4, effort=1, release=4, deps=none, risk=1                                               |
| 15-1 | Create disposable intent for kill: type=1, title=`Temporary kill intent`, motivation=done, priority=4, effort=1, release=4, deps=none, risk=1 |

**Non-interactive intent creation (recommended for test runs):**

```bash
printf "1\nAdd due dates to todos\nImprove prioritization for users\nSupport basic deadline tracking\ndone\n2\n2\n2\nnone\n2\n" | ./scripts/new-intent.sh
printf "1\nAwesome Banner\nDisplay a graphical banner at the top of the project README\ndone\n4\n1\n4\nnone\n1\n" | ./scripts/new-intent.sh
# Step 15-1: disposable intent for /kill
printf "1\nTemporary kill intent\ndone\n4\n1\n4\nnone\n1\n" | ./scripts/new-intent.sh
```

### After Each Step

1. Record result (PASS/FAIL)
2. If FAIL, determine severity:
   - `blocking` — stops subsequent tests
   - `high` — core functionality broken
   - `medium` — works incorrectly
   - `low` — minor/cosmetic
3. Append the step result to the current run block in `tests/ISSUES.md`
4. If the failure indicates a real bug/tooling gap, create a GitHub issue per `behaviors/WORK_TEST_PLAN_ISSUES.md` and reference it by issue number in the run block

### Fail-Fast Rule

If a step fails with `blocking` severity, STOP testing immediately. Do not continue to subsequent steps.

**Blocking failures include:**

- Project initialization fails (can't create project)
- Required files missing after init
- Scripts fail to execute
- Core generation commands produce no output

When stopping early, mark all remaining steps as `⏭️ SKIP` with reason: `Blocked by step X-Y`.

### On Completion

Output summary:

```
## Test Run Complete

**Date:** [ISO timestamp]
**Steps Total:** X
**Steps Executed:** Y
**Steps Skipped:** Z
**Steps Passed:** A
**Steps Failed:** B
**Blocking Issues:** N
**Result:** PASS | FAIL

[Link to tests/ISSUES.md for details]
```

---

## ISSUES.md Update Rules

After each test run:

1. **Rotate prior runs to historic:** Move all existing run blocks from `tests/ISSUES.md` to `tests/ISSUES_HISTORIC.md` (append under `## Historic Test Runs`). Keep the header and Counting Conventions in ISSUES.md.
2. **Write only the new run:** Replace `tests/ISSUES.md` content with the header, Counting Conventions, and **only the latest run block** (the one you just completed).
3. **Include "Issues Found This Run"** in the new run block, referencing GitHub issue numbers (e.g., `#123`).

**Rule:** `tests/ISSUES.md` must contain **only the latest run**. All prior runs live in `tests/ISSUES_HISTORIC.md`.

See `.cursor/rules/test-runner.mdc` for detailed formatting rules.
