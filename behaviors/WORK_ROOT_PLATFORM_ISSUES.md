# Root Platform Issue Workflow

**Purpose:** Define a consistent, high-quality workflow for resolving root platform issues.

**When to use:** Any time you are working a platform issue from GitHub Issues.

## Agent Execution Rule

**You must execute the entire workflow yourself.** Do not stop early to "give the user directions" or "let them do the next step." For each step:

- **Do it:** Run the commands, create the PR, post the resolution comment, close the issue, add the review comment. Use `gh`, `git`, and your tools.
- **Only hand off** when the workflow explicitly requires a human (e.g. "Wait for merge approval" or "stop and request approval").

If you cannot complete a step (e.g. no `gh` auth, no merge permission), say so and do everything up to that point—do not hand off steps you _can_ do (push, PR create, issue close, PR comment) by telling the user to do them.

**Anti-pattern:** Ending with "Next: push the branch and open a PR" or "You can now merge" when you have not yet pushed, created the PR, or posted the resolution comment. That is drift; complete the steps instead.

## Scope and Safety

- This behavior applies to the root platform repo (not downstream project repos).
- **All issues are tracked on GitHub** (not in local files).
- Read issues from GitHub using MCP tools or GitHub API.
- After resolving an issue, add a resolution comment and close it on GitHub.
- If the issue cannot be resolved without changing scope or requirements, stop and report.
- Update `README.md` if the fix adds or changes user-facing behavior, commands, or workflows.

**Note:** As of 2026-01-28, all issues are tracked on GitHub. The previous file-based tracking in `tests/ISSUES.md` is deprecated. See `behaviors/WORK_TEST_PLAN_ISSUES.md` for issue creation rules.

---

## Workflow

### Step 1: Validate the Implementation

**Objective:** Confirm the current implementation and issue description still match reality.

**Actions:**

1. Ensure the current workspace is clean before starting work.
2. Switch to main branch and ensure it's up to date: `git checkout main && git pull origin main`
3. Create a new branch for the issue from main: `git checkout -b issue-XXX-description` (where XXX is the GitHub issue number)
4. Push the branch: `git push -u origin issue-XXX-description`
5. Read the GitHub issue using MCP tools (e.g., `mcp_github-mcp_get_issue`) or GitHub API.
6. Verify the described behavior is still reproducible or still missing.
7. If the issue description is outdated or incorrect:
   - Add a comment to the GitHub issue with corrected findings before proceeding.
   - If the issue is no longer valid, add a resolution comment explaining why and close the issue.

**Stop gate:** If the issue is invalid or not reproducible, do not implement changes.

---

### Step 2: Work the Issue

**Objective:** Implement the fix or missing functionality.

**Actions:**

1. Identify the smallest set of files required to change.
2. Implement the fix.
3. Avoid bloat: no unrelated refactors or feature additions.
4. Run the narrowest verification that proves the fix.
5. Commit any new changes made during validation.

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

**Objective:** Record resolution and close the GitHub issue.

**Actions:**

1. Add a resolution comment to the GitHub issue using `tests/ISSUE_RESOLUTION_COMMENT_TEMPLATE.md`:
   - **Resolution:** How the issue was resolved, what was changed
   - **Validation:** How the fix was validated, tests run, verification steps
   - **Date Resolved:** YYYY-MM-DD
2. Close the GitHub issue using MCP tools (e.g., `mcp_github-mcp_update_issue` with `state: "closed"`).
3. Update `README.md` if the change affects user-facing docs.
4. Commit the final changes when the work is finished.

---

### Step 5: Submit PR and Review Cycle

**Objective:** Submit PR and iterate until it's ready to merge.

**Actions (you perform these; do not hand off to the user):**

1. Summarize changes and validation performed.
2. Report the final status (resolved/blocked/invalid).
3. Reference the GitHub issue number in the PR description (e.g., "Resolves #123").
4. **Submit the PR yourself:** `git push -u origin <branch>` then `gh pr create` (or equivalent). Do not tell the user to "open a PR" or "push and create a PR."
5. **Review the PR yourself** and add comments with findings:
   - Check for bloat, rabbit holes, or unnecessary complexity
   - Verify all requirements are met
   - Check for unrelated changes
   - Verify code quality and consistency
6. **If PR is not ready to merge:**
   - Resolve all identified issues
   - Commit the fixes: `git commit -m "Fix: [description of fixes]"`
   - Push the changes: `git push`
   - Add a comment to the PR summarizing the fixes
   - **Review the PR again** and add comments with findings
   - **Repeat** the review/fix cycle until the PR is ready to merge
7. **If PR is ready to merge:**
   - Confirm in a PR comment that it's ready.
   - If you can merge (e.g. `gh pr merge` works), merge the PR. Otherwise, the only handoff is: the user merges when ready.

**Review Criteria:**

- No bloat or unnecessary complexity
- No rabbit holes (scope creep)
- All requirements met
- No unrelated changes
- Code quality and consistency verified
- Issue tracking updated correctly

---

## Validation Guidance

- Prefer targeted checks over full suites when safe.
- If there is any uncertainty, run full checks: `pnpm test`, `pnpm lint`, `pnpm typecheck`.
- Capture the commands run and their outcomes in the issue resolution notes.
