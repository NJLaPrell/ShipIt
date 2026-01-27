# Release Preparation Guide

**Purpose:** This document provides step-by-step instructions for preparing the ShipIt platform for a new release. Follow these steps in order, validating each step before proceeding.

**When to use:** Before executing the release (see `DO_RELEASE.md` for execution steps).

## Scope and Safety

- This document covers preparation only.
- Do NOT commit, tag, push, or create a GitHub release here.
- Only edit these files: `CHANGELOG.md`, `package.json`, `README.md`.
- If any step requires edits outside those files, stop and report.

**Prerequisites:**
- All active issues resolved or documented
- All tests passing
- All changes committed to feature branches (if applicable)
- Main branch is stable and ready for release

## Release Version (required)

- Define `VERSION=X.Y.Z` before starting.
- Use this exact `VERSION` in every file update.
- If the version changes mid-process, stop and restart from Step 1.

**Next Steps:** After completing all preparation steps, proceed to `DO_RELEASE.md` to commit, tag, and publish the release.

---

## Step 1: Verify Code Quality

**Objective:** Ensure all code quality checks pass before release.

**Actions:**
1. Run linting: `pnpm lint`
   - **Success criteria:** No errors or warnings
   - **If fails:** Fix all linting errors before proceeding
   - **Rule:** Zero tolerance for linting errors in release

2. Run type checking: `pnpm typecheck`
   - **Success criteria:** No type errors
   - **If fails:** Fix all type errors before proceeding
   - **Rule:** TypeScript strict mode must pass completely

3. Run test suite: `pnpm test`
   - **Success criteria:** All tests pass
   - **If fails:** Fix failing tests or document known issues
   - **Rule:** Test suite must be green (100% pass rate expected)

4. Verify clean working tree BEFORE edits: `git status --porcelain`
   - **Success criteria:** No modified files before release prep edits begin
   - **If uncommitted:** Stash or commit non-release changes before proceeding
   - **Rule:** Only release prep files should change during this document

**Validation:**
```bash
pnpm lint && pnpm typecheck && pnpm test && [ -z "$(git status --porcelain)" ]
```

**If validation fails:** Stop and fix issues. Do not proceed until all checks pass.

**STOP GATE:** If any command fails or the working tree is not clean before edits, stop and report. Do not continue.

---

## Step 2: Determine Version Number

**Objective:** Select the appropriate semantic version number.

**Rules:**
- **MAJOR (X.0.0):** Breaking changes that require user action
- **MINOR (0.X.0):** New features, backward compatible
- **PATCH (0.0.X):** Bug fixes, backward compatible

**Decision Process:**
1. Review `CHANGELOG.md` [Unreleased] section
2. Categorize changes:
   - Breaking changes → MAJOR bump
   - New features → MINOR bump
   - Only bug fixes → PATCH bump
3. Check current version in `package.json`
4. Calculate next version using semantic versioning rules

**Example:**
- Current: `0.1.0`
- Changes: New features (validation, status dashboard, progress indicators)
- Next: `0.2.0` (MINOR bump)

**Validation:**
- Version number follows semantic versioning format (X.Y.Z)
- Version number is higher than current version
- Version bump matches change type (major/minor/patch)

**STOP GATE:** If the version is not valid or not agreed, stop and resolve before proceeding.

## Step 2.5: Record Chosen Version

**Objective:** Lock the chosen version for the remainder of preparation.

**Actions:**
1. Set `VERSION` to the chosen value (e.g., `0.2.0`).
2. Use this `VERSION` string consistently in Steps 3–5.

**Validation:**
- `VERSION` is defined once and reused verbatim
- No conflicting version strings appear in the release prep files

**STOP GATE:** If multiple versions are in play, stop and restart from Step 1 with a single `VERSION`.

---

## Step 3: Update CHANGELOG.md

**Objective:** Document all changes in the changelog.

**Actions:**
1. Read current `CHANGELOG.md`
2. Review `[Unreleased]` section
3. Create new version section with date: `## [X.Y.Z] - YYYY-MM-DD`
4. Move items from `[Unreleased]` to new version section
5. Categorize changes:
   - **Added:** New features, commands, scripts
   - **Changed:** Modifications to existing functionality
   - **Fixed:** Bug fixes and corrections
   - **Removed:** Deprecated or deleted features
6. Use clear, concise descriptions
7. Reference issue numbers if applicable (e.g., "Fixed ISSUE-021")
8. Clear `[Unreleased]` section (set all to "None" or remove items)

**Format Requirements:**
- Use markdown list format (`- Item description`)
- Group by category (Added, Changed, Fixed, Removed)
- Match the existing style in `CHANGELOG.md`
- Be specific and actionable

**Example:**
```markdown
## [0.2.0] - 2026-01-27

### Added
- Intent validation and auto-fix (`/fix` command)
- Output verification system with automatic generator chaining
- Unified status dashboard (`/status` command)

### Changed
- Enhanced `/scope-project` with batched prompts
- Enhanced `/generate-release-plan` with validation warnings

### Fixed
- Fixed numeric validation in dependency ordering checks
- Fixed temp file cleanup in fix-intents.sh
```

**Validation:**
- New version section exists with correct date
- All changes from `[Unreleased]` are categorized
- `[Unreleased]` section is cleared
- Format matches existing changelog style

**STOP GATE:** If the changelog does not meet all validations, stop and fix before proceeding.

---

## Step 4: Update package.json Version

**Objective:** Update the version field in package.json.

**Actions:**
1. Open `package.json`
2. Locate `"version"` field
3. Update to new version number (e.g., `"0.2.0"`)
4. Save file

**Validation:**
- Version matches the version in CHANGELOG.md
- Version follows semantic versioning format
- No other version references need updating (this is the source of truth)

**Rule:** `package.json` version is the authoritative version number.

**STOP GATE:** If `package.json` does not match `CHANGELOG.md`, stop and fix before proceeding.

---

## Step 5: Update README.md Version References

**Objective:** Update version badges and history in README.

**Actions:**
1. Find version badge near top of README.md:
   ```markdown
   [![Version](https://img.shields.io/badge/version-X.Y.Z-blue.svg)](https://github.com/NJLaPrell/ShipIt/releases/tag/vX.Y.Z)
   ```
2. Update version number in badge URL
3. Update version number in badge text
4. Find "Version History" section
5. Add new version entry at top of history:
   ```markdown
   - **vX.Y.Z** (YYYY-MM-DD) - Brief description
     - Feature highlights
     - Key improvements
   ```
6. Keep previous versions in history

**Validation:**
- Badge shows correct version
- Badge link points to correct GitHub release tag
- Version history includes new version
- Version history is in reverse chronological order (newest first)

**Note:** The release tag will not exist until `DO_RELEASE.md` is completed. A temporary broken badge link is expected.

**STOP GATE:** If README does not reflect the chosen `VERSION`, stop and fix before proceeding.

---

## Step 6: Final Verification

**Objective:** Verify all release preparation steps are complete.

**Checklist:**
- [ ] All code quality checks pass (lint, typecheck, tests)
- [ ] Version number determined and documented
- [ ] CHANGELOG.md updated with new version section
- [ ] package.json version updated
- [ ] README.md version badge and history updated
- [ ] All changes are ready to commit (release prep changes only)
- [ ] Only release prep files changed (CHANGELOG.md, package.json, README.md)
- [ ] Active issues in `tests/ISSUES.md` are resolved or explicitly documented

**Validation Command:**
```bash
# Verify version consistency
CURRENT_VERSION=$(grep '"version"' package.json | cut -d'"' -f4)
CHANGELOG_VERSION=$(grep '^## \[' CHANGELOG.md | head -1 | sed 's/## \[\(.*\)\].*/\1/')
README_VERSION=$(grep 'version-' README.md | head -1 | sed 's/.*version-\([0-9.]*\).*/\1/')

if [ "$CURRENT_VERSION" = "$CHANGELOG_VERSION" ] && [ "$CURRENT_VERSION" = "$README_VERSION" ]; then
  echo "✓ Version consistency check passed: $CURRENT_VERSION"
else
  echo "✗ Version mismatch detected!"
  echo "  package.json: $CURRENT_VERSION"
  echo "  CHANGELOG.md: $CHANGELOG_VERSION"
  echo "  README.md: $README_VERSION"
  exit 1
fi
```

**If validation fails:** Fix inconsistencies before proceeding.

**Fallback (if the command fails or returns empty values):**
- Manually open `package.json`, `CHANGELOG.md`, and `README.md`.
- Confirm the version is identical in all three places.

**STOP GATE:** If any validation fails, stop here and do not proceed to `DO_RELEASE.md`.

---

## Step 7: Stop and Summarize (Final Step)

**Objective:** End preparation cleanly and report what was accomplished.

**Actions:**
1. Stop. Do not commit, tag, push, or create a release here.
2. Produce a short summary of completed preparation tasks.

**Accomplished (Preparation Complete):**
```
[ ] Code quality verified (lint, typecheck, tests)
[ ] Release VERSION selected and locked
[ ] CHANGELOG.md updated with the new version section
[ ] package.json version updated
[ ] README.md badge and version history updated
[ ] Version consistency validated across all three files
[ ] Only release prep files modified
```

**STOP GATE:** This is the final step. Do not proceed to any execution steps here. Move to `DO_RELEASE.md` only after reporting the summary above.

---

## Rules and Constraints

### Mandatory Rules:
1. **Never skip code quality checks** - All lint, typecheck, and tests must pass
2. **Version consistency is required** - package.json, CHANGELOG.md, and README.md must match
3. **Semantic versioning is mandatory** - Follow MAJOR.MINOR.PATCH rules strictly
4. **Changelog must be updated** - Every release requires changelog entry
5. **No unrelated edits** - Only release prep files may change during this document
6. **No commits in this phase** - Do not commit, tag, push, or release here

### Best Practices:
1. **Test before release** - Run full test suite before preparing release
2. **Review changes** - Review all changes in CHANGELOG.md before proceeding
3. **Clear documentation** - Ensure all changes are properly documented
4. **Update documentation** - Keep README.md and CHANGELOG.md current

### Error Handling:
- **If any step fails:** Stop immediately, fix the issue, then restart from Step 1
- **If version mismatch detected:** Fix all version references before proceeding
- **If tests fail:** Do not proceed with release until tests pass
- **If unrelated edits detected:** Revert those files before proceeding

---

## Quick Reference Checklist

Use this checklist when preparing a release:

```
[ ] Step 1: Verify code quality (lint, typecheck, tests)
[ ] Step 2: Determine version number
[ ] Step 3: Update CHANGELOG.md
[ ] Step 4: Update package.json version
[ ] Step 5: Update README.md version references
[ ] Step 6: Final verification (version consistency)
```

**After completing all steps above, proceed to `DO_RELEASE.md`.**

---

## Automation Notes

**For AI Agents:**
- Execute steps sequentially
- Validate each step before proceeding
- Use provided validation commands
- Stop on any error
- Report progress clearly
- Document any deviations
- Do not proceed to DO_RELEASE.md until all preparation steps pass validation

**For Human Review:**
- Review CHANGELOG.md before proceeding
- Verify version number makes sense
- Check that all changes are documented
- Confirm all files are ready for commit

---

**Last Updated:** 2026-01-27  
**Version:** 1.0
