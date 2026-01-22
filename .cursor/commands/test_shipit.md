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

### Where to Record Results

Root mode results and failures must be written to the framework file:
- `tests/ISSUES.md` (in the root ShipIt project)

### Guardrails

Before starting, verify the file exists:
- `tests/fixtures.json`

If missing, STOP and log a **blocking** failure.

### Execute Steps

**Step 1-1:** Run `/init-project`

**Step 1-2:** When prompted, provide these EXACT inputs:
- Tech stack: `1` (TypeScript/Node.js)
- Description: `Test project for ShipIt end-to-end validation`
- High-risk domains: `none`

**Step 1-3:** Verify `./projects/shipit-test` was created

**Step 1-4:** Verify these files exist in the new project:
- `project.json`
- `package.json`
- `tsconfig.json`
- `intent/_TEMPLATE.md`
- `architecture/CANON.md`
- `roadmap/now.md`, `next.md`, `later.md`

### STOP HERE

After step 1-4 passes, output this message:

```
✅ Root project steps complete (1-1 through 1-4).

NEXT: Open ./projects/shipit-test in a NEW Cursor window, then run /test-shipit from there to continue testing.
```

**DO NOT continue to step 2. The user must open the test project in a separate workspace.**

---

## Test Project Mode (Steps 2-2 → 10)

### Load Test Fixtures

Read `tests/fixtures.json` (or the framework's `tests/fixtures.json` if running from test project) for hardcoded inputs.

### Execute Steps

Follow `tests/TEST_PLAN.md` starting from step 2-2.

**Use these hardcoded inputs:**

| Step | Input |
|------|-------|
| 3-1 | Scope: `"Build a todo list app with CRUD, tagging, and persistence"` |
| 3-2 | Follow-ups: REST API, JSON file, single-user, no auth. Select all features. |
| 4-1 | Intent: `"Add due dates to todos"` (feature) |
| 7-2 | Update F-001: priority=p0, effort=s, release_target=R1 |
| 8-1 | F-001 deps: `- F-002`, F-002 deps: `(none)` |
| 9-1 | Add `- F-999` to F-001 dependencies |
| 10-1 | Create intent: `"Awesome Banner"` |

### After Each Step

1. Record result (PASS/FAIL) 
2. If FAIL, determine severity:
   - `blocking` — stops subsequent tests
   - `high` — core functionality broken
   - `medium` — works incorrectly
   - `low` — minor/cosmetic
3. Update `tests/ISSUES.md` (see format below)

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
**Steps Passed:** X/Y
**Blocking Issues:** N
**Result:** PASS | FAIL

[Link to tests/ISSUES.md for details]
```

---

## ISSUES.md Update Rules

After each test run, update `tests/ISSUES.md`:

1. **Append a new Run block** under `## Test Runs` (do not overwrite prior runs)
2. **Update the Run's Summary table** with all step results
3. **Add new issues** to "Active Issues" section
4. **Update existing issues** if they reoccur or are resolved
5. **Move resolved issues** to "Resolved Issues" section

See `.cursor/rules/test-runner.mdc` for detailed formatting rules.
