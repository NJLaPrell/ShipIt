# AI Release Execution Guide

**Purpose:** Deterministic, agent-safe execution flow for publishing a release. This is the AI-native alternative to `DO_RELEASE.md`.

**When to use:** After completing all steps in `PREPARE_RELEASE_AI.md` (or `PREPARE_RELEASE.md`).

## Scope and Safety

- Execution only (commit, tag, push, release).
- Do NOT modify product/code files here.
- Only commit the release prep files: `CHANGELOG.md`, `package.json`, `README.md`.
- Execute steps sequentially. Stop on any failure.
- Require explicit user approval to proceed (from the prep summary handoff).

---

## Confirmation (required)

**Objective:** Ensure the user explicitly approves execution.

**Check:**

- The user responded "yes" (or equivalent) to the prep handoff question.

**STOP GATE:** If approval is missing or ambiguous, stop and ask for confirmation.

---

## Step 0.5: Carry-Forward Summary (required)

**Objective:** Anchor execution to the prep summary for auditability.

**Record (copy from prep summary):**

```
Release Status: READY | BLOCKED
Version: X.Y.Z
Prepared by: <agent or user>
Notes: <short status note>
Approval: <yes/no + who approved>
```

**STOP GATE:** If any field is missing, stop and request the missing detail.

---

## Step 0: Preflight Gate (single command)

**Objective:** Fail fast if prereqs are not met.

**Command:**

```bash
BRANCH=$(git branch --show-current)
STATUS=$(git status --porcelain)
echo "$BRANCH"
echo "$STATUS"

# Fail if not on intended release branch
if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  echo "✗ Wrong branch: $BRANCH"
  exit 1
fi

# Fail if any file other than allowed prep files is modified
ALLOWED="CHANGELOG.md|package.json|README.md"
if echo "$STATUS" | grep -vE "^[ MADRCU?!]{1,2} ($ALLOWED)$" >/dev/null; then
  echo "✗ Non-release-prep files modified"
  echo "$STATUS"
  exit 1
fi
```

**Validation:**

- Branch is the intended release branch (usually `main` or `master`).
- Only release prep files appear in status.
- User explicitly approved execution after prep summary.

**STOP GATE:** If any validation fails, stop and report.

---

## Step 1: Lock VERSION

**Objective:** Use one version string for the entire execution.

**Actions:**

1. Set `VERSION=X.Y.Z` and export it.
2. Validate it matches `package.json`.

**Command:**

```bash
export VERSION="X.Y.Z"
CURRENT_VERSION=$(grep '"version"' package.json | cut -d'"' -f4)
if [ "$VERSION" != "$CURRENT_VERSION" ]; then
  echo "✗ VERSION mismatch: package.json=$CURRENT_VERSION, VERSION=$VERSION"
  exit 1
fi
```

**STOP GATE:** If `VERSION` does not match `package.json`, stop.

---

## Step 2: Commit Release Preparation

**Objective:** Commit only the release prep changes.

**Commands:**

```bash
git add CHANGELOG.md package.json README.md
git diff --cached

# Fail if staged files include anything else
if git diff --cached --name-only | grep -vE "^(CHANGELOG.md|package.json|README.md)$" >/dev/null; then
  echo "✗ Staged non-release-prep files"
  git diff --cached --name-only
  exit 1
fi

git commit -m "chore: prepare release v$VERSION" \
  -m "- Update CHANGELOG.md with v$VERSION changes" \
  -m "- Bump version to $VERSION in package.json" \
  -m "- Update README.md version badge and history"
git log -1 --stat
```

**Validation:**

- Only prep files are staged and committed.
- Commit message follows the required format.

**STOP GATE:** If validation fails, stop and fix.

---

## Step 3: Create Annotated Tag

**Objective:** Create a descriptive annotated tag.

**Actions:**

1. Extract 2–4 highlights from the `CHANGELOG.md` section for `VERSION`.
2. Create an annotated tag using those highlights.

**Extraction (deterministic):**

```bash
# Pull first 4 bullet lines from the VERSION section (any category)
HIGHLIGHTS=$(awk -v v="## [$VERSION]" '
  $0 ~ v {in=1; next}
  in && /^## \\[/ {exit}
  in && /^- / {print; c++}
  c==4 {exit}
' CHANGELOG.md)
```

**Command (template):**

```bash
git tag -a "v$VERSION" -m "Release v$VERSION: <Brief Description>" \
  -m "Key highlights:" \
  -m "$(echo "$HIGHLIGHTS" | sed -n '1p')" \
  -m "$(echo "$HIGHLIGHTS" | sed -n '2p')" \
  -m "$(echo "$HIGHLIGHTS" | sed -n '3p')" \
  -m "" \
  -m "See CHANGELOG.md for full details."
git tag -l "v*" | tail -1
git show "v$VERSION"
```

**STOP GATE:** If tag is not annotated or does not point at the commit just created, stop and fix.

---

## Step 4: Push Commit and Tag

**Objective:** Push to GitHub in correct order.

**Commands:**

```bash
BRANCH=$(git branch --show-current)
git push origin "$BRANCH"
git push origin "v$VERSION"
```

**STOP GATE:** If either push fails, stop and resolve before proceeding.

---

## Step 5: Create GitHub Release (CLI)

**Objective:** Publish the release using the exact changelog section.

**Actions:**

1. Extract the `CHANGELOG.md` section for `VERSION` into a temporary notes file.
2. Use `gh release create` with the notes file to avoid shell expansion.

**Commands (safe):**

```bash
# Extract the exact VERSION section into a notes file
awk -v v="## [$VERSION]" '
  $0 ~ v {in=1}
  in {print}
  in && /^## \\[/ && $0 !~ v {exit}
' CHANGELOG.md > "/tmp/release_notes_$VERSION.md"

gh release create "v$VERSION" \
  --title "Release v$VERSION: <Brief Description>" \
  --notes-file "/tmp/release_notes_$VERSION.md"
```

**STOP GATE:** If the release is not published or notes are incomplete, stop and fix.

---

## Step 5.5: Idempotency Guard

**Objective:** Prevent collisions if a tag or release already exists.

**Commands:**

```bash
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "✗ Tag v$VERSION already exists"
  exit 1
fi

if gh release view "v$VERSION" >/dev/null 2>&1; then
  echo "✗ GitHub release v$VERSION already exists"
  exit 1
fi
```

**STOP GATE:** If either exists, stop and decide whether to delete/recreate or abort.

---

## Step 6: Verification Bundle

**Objective:** Verify release integrity end-to-end.

**Commands:**

```bash
git tag -l "v*" | tail -1
git ls-remote --tags origin | grep "v$VERSION"
git log --oneline -1
git show HEAD --stat
gh release view "v$VERSION" --json name,tagName,url,isDraft,isPrerelease,publishedAt
```

**Validation:**

- Tag exists locally and on remote.
- GitHub release is published (not draft).
- Release notes match the `CHANGELOG.md` section for `VERSION`.

**STOP GATE:** If any check fails, stop and resolve before proceeding.

---

## Rollback (if needed)

**Objective:** Provide a clean recovery path if a release was created incorrectly.

**Commands:**

```bash
# Delete GitHub release (if created)
gh release delete "v$VERSION" --yes

# Delete local and remote tag
git tag -d "v$VERSION"
git push origin ":refs/tags/v$VERSION"
```

**STOP GATE:** After rollback, restart from Step 0.

---

## Step 7: Stop and Summarize (final step)

**Objective:** End execution cleanly and report status.

**Report Template (fill in):**

```
[x] Release prep commit created and pushed
[x] Annotated tag vX.Y.Z created and pushed
[x] GitHub release published
[x] Release notes match CHANGELOG.md
[x] All validation checks passed
```

**STOP GATE:** Do not proceed to any other steps here.

---

## Agent Output Guidance (recommended)

**Objective:** Make the agent's logs easy to scan for humans.

**Per-step output format:**

```
Step X: <Name>
- Status: PASS | FAIL
- Evidence: <command or artifact>
- Notes: <short reason or error>
```

**Final summary (always print):**

```
Release Execution Summary
- Version: X.Y.Z
- Commit: <sha>
- Tag: vX.Y.Z
- Release URL: <url>
- Gates passed: <count>/<count>
```
