# Release Execution Guide

**Purpose:** This document provides step-by-step instructions for executing a release after preparation is complete. Follow these steps in order, validating each step before proceeding.

**When to use:** After completing all steps in `PREPARE_RELEASE.md`.

## Scope and Safety

- This document covers execution only (commit, tag, push, release).
- Do NOT modify product/code files here. Only commit the release prep files.
- If any step requires edits beyond release prep files, stop and report.
- If you are not on the release branch, stop and switch to the correct branch.

**Prerequisites:**

- All preparation steps from `PREPARE_RELEASE.md` are complete
- Version consistency verified across all files
- All release preparation changes are ready to commit
- No uncommitted changes except release preparation files

## Release Version (required)

- Define `VERSION=X.Y.Z` before starting.
- Use this exact `VERSION` in all commands below.
- If the version changes mid-process, stop and restart from Step 1.

**Important:** This process will commit changes, create tags, push to GitHub, and create a GitHub release. Ensure you have proper permissions and are ready to publish.

---

## Step 1: Commit Release Preparation

**Objective:** Commit all release preparation changes.

**Actions:**

1. Confirm correct branch: `git branch --show-current`
   - **Verify:** You are on the intended release branch (usually `main` or `master`)
2. Confirm only release prep files are modified: `git status --porcelain`
   - **Verify:** Only `CHANGELOG.md`, `package.json`, `README.md` appear
   - **If other files:** Stop and revert or stash unrelated changes
3. Stage release prep files only:
   - `git add CHANGELOG.md package.json README.md`
4. Review staged changes: `git diff --cached`
   - **Verify:** Only the release prep files are staged
5. Commit with message: `git commit -m "chore: prepare release vX.Y.Z"`
6. Verify commit: `git log -1 --stat`

**Commit Message Format:**

```
chore: prepare release vX.Y.Z

- Update CHANGELOG.md with vX.Y.Z changes
- Bump version to X.Y.Z in package.json
- Update README.md version badge and history
```

**Validation:**

- All release prep files are committed
- Commit message follows conventional commit format
- No uncommitted changes remain
- Commit is on correct branch (main/master)

**Rule:** Release preparation commits should be separate from feature commits.

**If validation fails:** Fix issues before proceeding. Do not create tag with uncommitted changes.

**STOP GATE:** If any validation fails, stop and fix before moving to Step 2.

---

## Step 2: Create Git Tag

**Objective:** Create an annotated git tag for the release.

**Actions:**

1. Confirm `VERSION` matches `package.json` before tagging
2. Create annotated tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z: Brief description"`
3. Verify tag: `git tag -l "v*" | tail -1`
4. Show tag message: `git show vX.Y.Z`

**Tag Message Format:**

```
Release vX.Y.Z: Brief Description

Key highlights:
- Feature 1
- Feature 2
- Improvement 1

See CHANGELOG.md for full details.
```

**Tag Message Best Practices:**

- Use the version section from CHANGELOG.md as reference
- Include 2-4 key highlights
- Reference CHANGELOG.md for full details
- Keep it concise but informative

**Validation:**

- Tag name matches version (e.g., `v0.2.0`)
- Tag is annotated (not lightweight) - verify with `git show vX.Y.Z` shows tag message
- Tag message is descriptive and includes key highlights
- Tag points to the commit just created (verify with `git log --oneline --decorate`)

**Rule:** Always use annotated tags for releases (not lightweight tags). Use `-a` flag.

**If validation fails:** Delete tag with `git tag -d vX.Y.Z`, fix issues, then recreate tag.

**STOP GATE:** If tag validation fails, stop and fix before moving to Step 3.

---

## Step 3: Push to Remote

**Objective:** Push commits and tags to GitHub.

**Actions:**

1. Determine branch name: `git branch --show-current`
2. Push commits first: `git push origin <branch-name>`
   - **Example:** `git push origin main`
3. Verify commits pushed: Check GitHub repository
4. Push tag: `git push origin vX.Y.Z`
5. Verify tag pushed: Check GitHub tags page or releases page

**Validation:**

- Commits pushed successfully (no errors)
- Tag pushed successfully (no errors)
- Tag visible on GitHub releases/tags page
- Tag points to correct commit on GitHub

**Rule:** Push commits before tags to ensure tag references exist on remote.

**If validation fails:**

- If commit push fails: Fix branch/remote issues, then retry
- If tag push fails: Verify tag exists locally, check remote permissions, then retry
- Do not proceed to GitHub release until tag is visible on GitHub

**STOP GATE:** If the tag is not visible on GitHub, stop and resolve before moving to Step 4.

---

## Step 4: Create GitHub Release

**Objective:** Create a GitHub release with release notes. **This step is REQUIRED, not optional.**

**Actions:**

1. Navigate to GitHub repository releases page:
   - URL format: `https://github.com/<owner>/<repo>/releases`
   - Or: Repository → Releases → "Draft a new release"
2. Click "Draft a new release" button
3. Select tag: Choose `vX.Y.Z` from dropdown
   - **Verify:** Tag exists and is correct version
4. Set release title: `Release vX.Y.Z: Brief Description`
   - Use same description from tag message
5. Set release description:
   - Copy entire version section from CHANGELOG.md
   - Include all categories (Added, Changed, Fixed, Removed)
   - Keep markdown formatting
   - Add links to issues if applicable (e.g., `[#123](https://github.com/owner/repo/issues/123)`)
6. Mark as "Latest release" checkbox:
   - **Check this** if this is the newest release
   - **Uncheck** if releasing an older version
7. Click "Publish release" button
8. Verify release is published:
   - Release appears on releases page
   - Release notes are complete
   - Release is marked as latest (if checked)

**Release Notes Format:**
Copy the version section from CHANGELOG.md, for example:

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

- Release is published on GitHub (not draft)
- Release notes are complete and accurate
- Release notes match CHANGELOG.md version section
- Release is marked as latest (if appropriate)
- Release tag matches the tag that was pushed
- Release is accessible via repository releases page

**Rule:** GitHub release creation is MANDATORY. Do not skip this step.

**If validation fails:**

- If release creation fails: Check GitHub permissions, verify tag exists, then retry
- If release notes are incomplete: Edit release and update notes
- If release is draft: Click "Publish release" to make it public

**STOP GATE:** If the release is not published and verified, stop and fix before final verification.

---

## Step 5: Publish to npm (optional)

**Objective:** Publish the ShipIt CLI package to npm so users can install with `npm install -g @njlaprell/shipit`. Skip if not publishing to npm for this release.

**Actions:**

1. Ensure `package.json` version matches the release (e.g. `X.Y.Z` for tag `vX.Y.Z`).
2. Run tests: `pnpm test && pnpm test:cli && pnpm test:shipit`.
3. Preview: `npm pack` then inspect tarball if desired.
4. Publish: `npm publish` (requires `npm login` and 2FA).
5. Verify at https://www.npmjs.com/package/shipit.

**If using CI:** A workflow may publish on release creation when `NODE_AUTH_TOKEN` (or `NPM_TOKEN`) is set. See `docs/PUBLISHING.md`.

**Validation:**

- Package version on npm matches GitHub release tag.
- `npm install -g @njlaprell/shipit` works and `shipit --help` runs.

---

## Final Verification

**Objective:** Verify the complete release process was successful.

**Checklist:**

- [ ] Release preparation commit created and pushed
- [ ] Git tag created and pushed to GitHub
- [ ] GitHub release created and published
- [ ] (Optional) npm package published; version matches release
- [ ] Release notes match CHANGELOG.md
- [ ] Release is marked as latest (if appropriate)
- [ ] Version badge on README.md links to correct release
- [ ] All validation steps passed

**Verification Commands:**

```bash
# Verify tag exists locally and remotely
git tag -l "v*" | tail -1
git ls-remote --tags origin | grep "vX.Y.Z"

# Verify release commit
git log --oneline -1
git show HEAD --stat

# Verify version consistency (should still match)
CURRENT_VERSION=$(grep '"version"' package.json | cut -d'"' -f4)
echo "Current version: $CURRENT_VERSION"
```

**Manual Verification:**

1. Visit GitHub releases page: `https://github.com/<owner>/<repo>/releases`
2. Verify release `vX.Y.Z` exists and is published
3. Verify release notes are complete
4. Verify README.md badge links to correct release
5. Verify tag exists and points to correct commit

**If any verification fails:** Fix issues immediately. If release was published incorrectly, you may need to:

- Delete and recreate the GitHub release
- Delete and recreate the tag (if necessary)
- Fix any documentation issues

---

## Rules and Constraints

### Mandatory Rules:

1. **GitHub release is required** - Do not skip Step 4. Every release must have a GitHub release.
2. **Tags must be annotated** - Always use `-a` flag when creating tags
3. **Push commits before tags** - Ensure commits exist on remote before pushing tags
4. **Release notes must match CHANGELOG.md** - Keep them synchronized
5. **Verify before proceeding** - Validate each step before moving to next
6. **No uncommitted changes** - All changes must be committed before tagging
7. **No file edits in this phase** - Only commit the prepared files; do not modify other files

### Best Practices:

1. **Review before committing** - Review `git diff --cached` before committing
2. **Descriptive tag messages** - Include key highlights in tag message
3. **Complete release notes** - Copy full version section from CHANGELOG.md
4. **Mark as latest** - Check "Latest release" if this is the newest version
5. **Test tag locally** - Verify tag before pushing to remote

### Error Handling:

- **If commit fails:** Fix issues, then retry commit
- **If tag creation fails:** Check for existing tag, delete if needed, then recreate
- **If push fails:** Check remote permissions and branch protection rules
- **If GitHub release fails:** Verify tag exists on GitHub, check permissions, then retry
- **If any step fails:** Stop immediately, fix the issue, then restart from the failed step

---

## Quick Reference Checklist

Use this checklist when executing a release:

```
[ ] Step 1: Commit release preparation
[ ] Step 2: Create git tag (annotated)
[ ] Step 3: Push commits and tag to GitHub
[ ] Step 4: Create GitHub release (REQUIRED)
[ ] Step 5: Publish to npm (optional)
[ ] Final verification: All steps completed successfully
```

---

## Automation Notes

**For AI Agents:**

- Execute steps sequentially
- Validate each step before proceeding
- Use provided validation commands
- Stop on any error
- Report progress clearly
- Document any deviations
- **Do not skip GitHub release creation** - it is mandatory

**For Human Review:**

- Review commit changes before committing
- Verify tag message is appropriate
- Check release notes match CHANGELOG.md
- Confirm release is marked as latest (if appropriate)
- Verify release is accessible on GitHub

---

## Post-Release Tasks

After completing the release, consider:

1. **Announce release** - Notify stakeholders if applicable
2. **Update documentation** - Ensure all docs reference new version
3. **Monitor issues** - Watch for any issues reported with new release
4. **Plan next release** - Start tracking changes for next version in CHANGELOG.md [Unreleased]

---

**Last Updated:** 2026-01-27  
**Version:** 1.0
