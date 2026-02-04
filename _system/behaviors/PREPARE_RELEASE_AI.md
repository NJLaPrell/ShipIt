# AI Release Preparation Guide

**Purpose:** Deterministic, agent-safe release prep flow for ShipIt. This is the AI-native alternative to `PREPARE_RELEASE.md`.

**When to use:** Before executing `DO_RELEASE.md`, when prep is performed by an AI agent.

## Scope and Safety

- Preparation only. Do NOT commit, tag, push, or create a release here.
- Only edit these files: `CHANGELOG.md`, `package.json`, `README.md`.
- If any step requires edits outside those files, stop and report.
- Execute steps sequentially. Stop on any failure.

---

## Step 0: Preflight Gate (single command)

**Objective:** Fail fast if the repo is not clean and green.

**Command:**

```bash
pnpm lint && pnpm typecheck && pnpm test && [ -z "$(git status --porcelain)" ]
```

**STOP GATE:** If any command fails, stop and report. Do not proceed.

---

## Step 1: Determine Version (machine rules)

**Objective:** Choose a semantic version consistently.

**Rules:**

- **MAJOR:** breaking changes that require user action
- **MINOR:** backward-compatible features
- **PATCH:** backward-compatible fixes only

**AI Decision Procedure:**

1. Read `[Unreleased]` in `CHANGELOG.md`.
2. If all sections are "None" or empty, stop: there is nothing to release.
3. Map categories to bump:
   - Any Breaking Changes → MAJOR
   - Any Added/Changed features → MINOR
   - Only Fixed → PATCH
4. Read current version in `package.json`.
5. Compute `VERSION=X.Y.Z` deterministically.

**STOP GATE:** If ambiguity exists, stop and request clarification.

---

## Step 2: Lock VERSION (single source of truth)

**Objective:** Define the release version once and reuse everywhere.

**Actions:**

1. Set `VERSION=X.Y.Z` (same value for Steps 3–5).
2. Export `VERSION` and `TODAY` in the shell to avoid re-reading files.
3. Do not allow alternative versions in any file.

**STOP GATE:** If multiple versions appear, stop and restart from Step 0.

---

## Step 3: Auto-Generate Changelog (if supported)

**Objective:** Use any existing automation to avoid manual drift.

**Actions:**

1. Detect a changelog generator in the repo (examples: `scripts/generate-changelog.sh`, `changeset`, or a documented release tool).
2. If found, run it and verify it updates `CHANGELOG.md` deterministically.
3. If not found, proceed to Step 4 and update manually.

**STOP GATE:** If an auto-generator exists but fails, stop and report. Do not fall back to manual edits unless explicitly allowed.

---

## Step 4: Update `CHANGELOG.md` (deterministic)

**Objective:** Move `[Unreleased]` into a versioned section.

**Actions:**

1. Create a new section: `## [X.Y.Z] - YYYY-MM-DD` (use `$TODAY` if exported).
2. Move all `[Unreleased]` items into that section.
3. Clear `[Unreleased]` (set each category to `- None`).
4. Preserve existing changelog style and ordering.

**STOP GATE:** If any `[Unreleased]` item remains in that section, stop and fix.

---

## Step 5: Update `package.json` Version

**Objective:** Set the authoritative version field.

**Actions:**

1. Update `"version"` to `X.Y.Z`.
2. No other version changes in this file.

**STOP GATE:** If `package.json` version does not equal `VERSION`, stop.

---

## Step 6: Update `README.md` Version References

**Objective:** Keep README version references accurate.

**Actions:**

1. Update the version badge to `X.Y.Z`.
2. Update the badge link to `.../releases/tag/vX.Y.Z`.
3. Add a new entry at the top of "Version History".
4. Keep reverse chronological order.

**STOP GATE:** If README references a different version, stop.

---

## Step 7: Automated Consistency Check

**Objective:** Verify version consistency across all three files.

**Command:**

```bash
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

**STOP GATE:** If this fails, stop and fix.

---

## AI Efficiency Notes (optional)

- Prefer a single shell session with `VERSION`/`TODAY` exported to reuse values.
- If a release-prep helper exists in the repo, use it to update all three files in one pass.
- Use `git diff --name-only` to validate file scope quickly before full `git status`.

---

## Step 8: Diff Guard (no unrelated changes)

**Objective:** Ensure only release prep files changed.

**Command:**

```bash
git status --porcelain
```

**Validation:**

- Only `CHANGELOG.md`, `package.json`, `README.md` appear.

**STOP GATE:** If any other file appears, stop and revert those changes.

---

## Step 9: Stop and Summarize (final step)

**Objective:** End prep cleanly and hand off to `DO_RELEASE.md`.

**Report Template (fill in):**

```
[x] Preflight gate passed (lint/typecheck/tests/clean tree)
[x] VERSION locked: X.Y.Z
[x] CHANGELOG.md updated
[x] package.json version updated
[x] README.md version badge + history updated
[x] Version consistency validated
[x] Only release prep files modified
```

**Release Status Summary (required):**

```
Release Status: READY | BLOCKED
Version: X.Y.Z
Prepared by: <agent or user>
Notes: <short status note>
```

**Human Handoff Question (required):**

```
The release is ready to execute. Do you want me to proceed with the release steps now?
```

**STOP GATE:** Do not proceed to execution steps unless the user explicitly says yes.

---

## Agent Output Guidance (recommended)

**Objective:** Make the agent's logs easy to scan for humans.

**Per-step output format:**

```
Step X: <Name>
- Status: PASS | FAIL
- Evidence: <command or file touched>
- Notes: <short reason or error>
```

**Final summary (always print):**

```
Release Prep Summary
- Version: X.Y.Z
- Files changed: CHANGELOG.md, package.json, README.md
- Gates passed: <count>/<count>
- Next: Proceed with release execution steps if approved
```
