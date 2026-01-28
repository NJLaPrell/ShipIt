# Root Platform Issue Workflow

**Purpose:** Define a consistent, high-quality workflow for resolving root platform issues.

**When to use:** Any time you are working a platform issue from `./tests/ISSUES.md`.

## Scope and Safety

- This behavior applies to the root platform repo (not downstream project repos).
- Read issues from `./tests/ISSUES.md` only.
- After resolving an issue, update it in `./tests/ISSUES.md` and then move it to `./tests/ISSUES_HISTORIC.md`.
- If the issue cannot be resolved without changing scope or requirements, stop and report.
- If `./tests/ISSUES.md` or `./tests/ISSUES_HISTORIC.md` is missing, stop and report.

---

## Workflow

### Step 1: Validate the Implementation

**Objective:** Confirm the current implementation and issue description still match reality.

**Actions:**
1. Read the issue entry in `./tests/ISSUES.md`.
2. Verify the described behavior is still reproducible or still missing.
3. If the issue description is outdated or incorrect:
   - Update the issue with corrected findings before proceeding.
   - If the issue is no longer valid, mark it resolved and move it to `./tests/ISSUES_HISTORIC.md`.

**Stop gate:** If the issue is invalid or not reproducible, do not implement changes.

---

### Step 2: Work the Issue

**Objective:** Implement the fix or missing functionality.

**Actions:**
1. Identify the smallest set of files required to change.
2. Implement the fix.
3. Avoid bloat: no unrelated refactors or feature additions.
4. Run the narrowest verification that proves the fix.

**Stop gate:** If the fix requires new scope, stop and request approval.

---

### Step 3: Quality Review

**Objective:** Ensure the solution is correct, minimal, and safe.

**Actions:**
1. Re-read the changed files for logic errors or regressions.
2. Check for unnecessary complexity or duplication.
3. Confirm the fix aligns with existing patterns and scripts.
4. Verify no unrelated files were modified.

---

### Step 4: Update Issue Records

**Objective:** Record resolution and archive the issue.

**Actions:**
1. Update the issue in `./tests/ISSUES.md` with:
   - Resolution summary
   - Validation performed
   - Date resolved
2. Move the issue entry to `./tests/ISSUES_HISTORIC.md`.
3. Ensure the active issues list remains accurate.

---

### Step 5: Report Outcome

**Objective:** Provide a concise summary of work and status.

**Actions:**
1. Summarize changes and validation performed.
2. Report the final status (resolved/blocked/invalid).
3. Point to the updated issue history entry.

---

## Validation Guidance

- Prefer targeted checks over full suites when safe.
- If there is any uncertainty, run full checks: `pnpm test`, `pnpm lint`, `pnpm typecheck`.
- Capture the commands run and their outcomes in the issue resolution notes.
