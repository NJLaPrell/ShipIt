# Test Plan Issue Management

**Purpose:** Define consistent rules for creating, tracking, and archiving issues discovered during test plan execution using GitHub Issues.

**When to use:** Any time you are executing test plan steps from `tests/TEST_PLAN.md` and encounter failures, missing functionality, or unexpected behavior.

## Quick Reference: Templates

- **Issue body:** Use `tests/ISSUE_TEMPLATE.md` (GitHub issue body)
- **Research Notes:** Use `tests/ISSUE_RESEARCH_TEMPLATE.md` (GitHub issue body)
- **Resolution Comments:** Use `tests/ISSUE_RESOLUTION_COMMENT_TEMPLATE.md` (GitHub issue comment)
- **Issue Title:** Brief descriptive title (e.g., "Missing tests/golden-data directory")

Always create issues on GitHub using the templates. Issues are tracked on GitHub, not in local files.

## Scope and Safety

- This behavior applies to issues discovered during test plan execution.
- **All issues are created on GitHub** in the repository where the test is running.
- Root platform issues: Create in root platform repository (e.g., `NJLaPrell/ShipIt`).
- Test project issues: Create in test project repository (if it has its own repo) or root platform repository.
- After resolving an issue, close it on GitHub with a resolution comment.

**Note:** This workflow replaces the previous file-based issue tracking in `tests/ISSUES.md`. `tests/ISSUES.md` is for **test run logs only**; issues live on GitHub.

---

## Preflight (Must Pass Before Creating Issues)

Before creating any issues, verify `gh` is available and authenticated:

```bash
gh --version
gh auth status
```

If authentication is missing/expired, **STOP** and treat it as a **blocking** test-plan failure (you cannot correctly record issues).

## Repo Resolution (Where to File the Issue)

### Determine the current repo

From the workspace where the failure occurred:

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

If this fails (e.g., not a git repo, no remote), fall back to the **root platform repo** (usually `NJLaPrell/ShipIt`) and note the limitation in the issue body.

### Decision rule

- **Root platform issue → file in root platform repo**
  - Missing/broken framework scripts or commands
  - Incorrect framework behaviors/docs/templates
  - CI/lint/test configuration in the framework
  - Anything that would affect _any_ initialized project

- **Test project issue → file in test project repo (only if it exists as a real repo), otherwise root platform repo**
  - Failures caused by test-project-specific content or changes _after_ initialization
  - If the test project is just a folder created under `./projects/` (no separate remote), file in the root platform repo and label it as test-project surfaced

Rule of thumb: if fixing it requires changing the framework repo → file in the framework repo.

---

## When to Create an Issue

Create a GitHub issue when:

1. **Test step fails** (expected behavior doesn't match actual)
2. **Missing functionality** (expected feature/script/file doesn't exist)
3. **Unexpected behavior** (system behaves differently than documented)
4. **Tooling missing** (required scripts, configs, or dependencies are absent)
5. **Configuration errors** (invalid or missing configuration causes failures)

**Do NOT create issues for:**

- Expected failures (tests that are supposed to fail initially)
- User errors (incorrect input, wrong commands)
- Transient failures (network issues, temporary outages)

---

## Creating GitHub Issues

### Issue Creation Process

1. **Prepare the issue:**
   - Read the appropriate template (`tests/ISSUE_TEMPLATE.md` or `tests/ISSUE_RESEARCH_TEMPLATE.md`)
   - Fill in all fields with specific, actionable information
   - Remove placeholder text and brackets

2. **Create the issue on GitHub:**
   - Use the GitHub CLI (`gh`) to create the issue
   - **Title:** Brief descriptive title (e.g., "Missing tests/golden-data directory")
   - **Body:** Use the filled-out template content
   - **Labels:** Add appropriate labels (labels must exist before use):
     - Severity: `severity:low`, `severity:medium`, `severity:high`
     - Type: `test-plan-issue`, `research-note` (if applicable)
     - Step: `step:12-1`, `step:UX`, etc. (if applicable)
   - **Repository:** Create in the appropriate repository (root platform or test project)
   - **Label Creation:** Labels must be created via GitHub UI before they can be used. GitHub MCP tools and API cannot create labels—they can only add existing labels to issues. If a label doesn't exist:
     1. Go to the repository on GitHub
     2. Navigate to Issues → Labels
     3. Create the label with the exact name (e.g., `severity:low`, `test-plan-issue`)
     4. Then use the label when creating the issue

3. **Reference the issue:**
   - Use GitHub issue number (e.g., `#123`) in test run summaries
   - Link to the issue in documentation

### Issue Format

**Use the template:** `tests/ISSUE_TEMPLATE.md`

The template provides the GitHub issue body format. Fill in:

- **Severity:** low | medium | high
- **Step:** Test step number or phase name
- **First Seen:** Date when issue was discovered
- **Expected:** What should happen
- **Actual:** What actually happened
- **Error:** Error message or description
- **Implementation:** Action items

### Severity Levels

- **high:** Blocks test execution or core functionality
- **medium:** Affects functionality but workarounds exist
- **low:** Minor issues, missing nice-to-haves, UX improvements

### Issue Numbering

- GitHub automatically assigns sequential issue numbers (#1, #2, #3, etc.)
- Reference issues by their GitHub number (e.g., `#123`)
- No manual numbering required

---

## Issue Categorization

### Active Issues

Create regular GitHub issues when:

- They need to be resolved
- They block or affect test execution
- They represent missing functionality

Use `tests/ISSUE_TEMPLATE.md` for the body.

### Research Notes

Create GitHub issues with `research-note` label when:

- They require research before implementation
- They are deferred for future work
- They need architectural decisions
- They are low priority but worth documenting

Use `tests/ISSUE_RESEARCH_TEMPLATE.md` for the body and add `research-note` label.

---

## Test Run Recording

### Test Runs (run logs only)

`tests/ISSUES.md` must contain **only the latest run**. Prior runs are archived in `tests/ISSUES_HISTORIC.md`.

**When recording a new run:**

1. Append all existing run blocks from `tests/ISSUES.md` to `tests/ISSUES_HISTORIC.md` (under `## Historic Test Runs`).
2. Write `tests/ISSUES.md` with header, Counting Conventions, and only the new run block.

Format for each run block:

```markdown
## Test Runs

### Run: YYYY-MM-DDTHH:MM:SSZ (root-project | test-project)

**Steps Total:** [number]
**Steps Executed:** [number]
**Steps Skipped:** [number]
**Steps Passed:** [number]
**Steps Failed:** [number]
**Blocking Issues:** [number]
**Result:** ✅ PASS | ❌ FAIL

#### Summary

| Step | Name      | Status            | Severity | Notes |
| ---- | --------- | ----------------- | -------- | ----- |
| X-Y  | Step name | ✅ PASS / ❌ FAIL | severity | Notes |

#### Issues Found This Run

- **#123:** [Title] ([severity]) - **RESOLVED** / **ACTIVE**
- **#124:** [Title] ([severity]) - **RESOLVED** / **ACTIVE**
```

**Note:** Issues are tracked on GitHub. Only reference GitHub issue numbers here.

Definitions:

- **Steps Total**: Total steps in the test plan section being run (including those that may be skipped due to blocking failures).
- **Steps Executed**: Count of steps with status **✅ PASS** or **❌ FAIL** (exclude **⏭️ SKIP**).
- **Steps Skipped**: Count of steps with status **⏭️ SKIP**.

---

## Archiving Issues

### When to Close an Issue

Close a GitHub issue when:

- It has been resolved
- It is no longer valid (e.g., requirements changed)
- It was a false positive

### Closing Process

1. **Verify the fix:**
   - Confirm the issue is resolved
   - Run verification steps
   - Document validation results

2. **Add resolution comment:**
   - Add a comment to the GitHub issue with:
     - **Resolution:** How the issue was resolved, what was changed
     - **Validation:** How the fix was validated, tests run, verification steps
     - **Date Resolved:** YYYY-MM-DD

3. **Close the issue:**
   - Close the GitHub issue
   - Add appropriate labels if needed (e.g., `resolved`, `fixed`)

4. **Update test run summary:**
   - Mark issue as **RESOLVED** in "Issues Found This Run" section
   - Update with GitHub issue number and link

### Resolution Comment Format

**Use the template:** `tests/ISSUE_RESOLUTION_COMMENT_TEMPLATE.md`

Copy the template and fill in:

- Fill in "Resolution" with specific details about what was changed
- Fill in "Validation" with specific verification steps and test results
- Add the date resolved
- Remove any placeholder text or brackets

See `tests/ISSUE_RESOLUTION_COMMENT_TEMPLATE.md` for the complete template.

---

## Location Rules

### Root Platform vs Test Project

- **Root platform issues:** Create in root platform repository
  - Missing framework scripts
  - Framework bugs
  - Missing framework files/configs
  - CI/CD issues
  - Documentation issues

- **Test project issues:** Create in test project repository (if it has its own repo) or root platform repository
  - Project-specific test failures
  - Project configuration issues
  - Project-specific missing functionality

**Rule of thumb:** If the issue affects the framework itself → root platform repo. If it affects only the test project → test project repo (or root if no separate repo).

---

## Workflow

### During Test Execution

1. **When a step fails:**
   - Record the failure in the test run summary table (in `tests/ISSUES.md`)
   - Create a GitHub issue if it's a new issue (use `tests/ISSUE_TEMPLATE.md`)
   - Reference the GitHub issue number in "Issues Found This Run" section

2. **When discovering missing functionality:**
   - Create a GitHub issue immediately (use `tests/ISSUE_TEMPLATE.md` or `tests/ISSUE_RESEARCH_TEMPLATE.md`)
   - Add appropriate labels (severity, type, step)
   - Reference the issue number in test run summary

3. **At end of test run:**
   - Update "Latest Test Run" section in `tests/ISSUES.md` with summary
   - List all GitHub issues found in "Issues Found This Run" (with issue numbers)
   - Update overall validation status if applicable

### After Issue Resolution

1. Add resolution comment to the GitHub issue
2. Close the GitHub issue
3. Update test run summary in `tests/ISSUES.md` to mark issue as **RESOLVED**
4. Update with link to closed issue

---

## Examples

The following examples show filled-out templates. Always start from the templates:

- Active issues: Use `tests/ISSUE_TEMPLATE.md`
- Research notes: Use `tests/ISSUE_RESEARCH_TEMPLATE.md`

### Example: Active Issue (GitHub Issue #123)

**Title:** Missing tests/golden-data directory

**Body (from ISSUE_TEMPLATE.md):**

```markdown
**Severity:** low
**Step:** UX
**First Seen:** 2026-01-27

## Expected

`tests/golden-data/` directory exists per plan

## Actual

Directory does not exist

## Error

Replay validation test data cannot be stored

## Implementation

- Add `tests/golden-data/.gitkeep` to track directory
- Create `tests/golden-data/README.md` with format documentation
- Ensure `scripts/init-project.sh` and CLI copy `tests/golden-data/` when scaffolding
```

**Labels:** `severity:low`, `test-plan-issue`, `step:UX`

### Example: Research Note (GitHub Issue #124)

**Title:** Intent subfolders missing

**Body (from ISSUE_RESEARCH_TEMPLATE.md):**

```markdown
**Type:** Research Note
**Priority:** low

## Best Approach

- Create `intent/features/`, `intent/bugs/`, `intent/tech-debt/` subdirectories
- Update all scripts to read intents recursively

## Integration Points

- `scripts/new-intent.sh` - write to subfolders
- `scripts/generate-release-plan.sh` - read recursively
- `scripts/generate-roadmap.sh` - read recursively
- `scripts/init-project.sh` - create subfolders
```

**Labels:** `research-note`, `severity:low`, `test-plan-issue`

---

## Validation

- All issues must be created on GitHub (not in local files)
- All issues must have clear "Expected" vs "Actual" descriptions
- Severity must be assigned (low/medium/high) and added as label
- Issues must be referenced by GitHub issue number in test run summaries
- Closed issues must have resolution comments with validation details
