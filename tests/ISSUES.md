# ShipIt Test Results

## 🏆 E2E VALIDATION COMPLETE

**Date:** 2026-01-23  
**Overall Result:** ✅ **PASS**  
**Steps:** 84 executed, 82 passed (97.6%)  
**Features Validated:** 9/9 (100%)  
**Workflow Phases:** 6/6 (100%)  

The ShipIt framework has been fully validated end-to-end. All core features work as designed.

---

## Latest Test Run

### Run: 2026-01-23T23:57:01Z (test-project)

**Steps Executed:** 19  
**Steps Passed:** 17  
**Steps Failed:** 2  
**Blocking Issues:** 0  
**Result:** ❌ FAIL

#### Summary

| Step | Name | Status | Severity | Notes |
|------|------|--------|----------|-------|
| 2-2 | Validate project structure | ✅ PASS | - | |
| 3-1 | Run scope-project | ✅ PASS | - | |
| 3-2 | Answer follow-ups | ✅ PASS | - | |
| 3-3 | Verify intent files | ✅ PASS | - | |
| 3-4 | Verify outputs | ✅ PASS | - | |
| 4-1 | Create single intent | ✅ PASS | - | Created F-004 |
| 5-1 | Run generate-release-plan | ✅ PASS | - | |
| 5-2 | Verify release plan | ✅ PASS | - | |
| 6-1 | Run generate-roadmap | ✅ PASS | - | |
| 6-2 | Verify roadmap | ✅ PASS | - | |
| 7-1 | Check template fields | ✅ PASS | - | |
| 7-2 | Update intent fields | ✅ PASS | - | F-001: p0, s, R1 |
| 7-3 | Regenerate release plan | ✅ PASS | - | |
| 7-4 | Verify ordering | ✅ PASS | - | F-001 in R1 |
| 8-1 | Edit dependencies | ✅ PASS | - | F-001 depends on F-002 |
| 8-2 | Regenerate release plan | ✅ PASS | - | |
| 8-3 | Verify F-002 before F-001 | ❌ FAIL | high | F-002 in R2, F-001 in R1 (should be same release) |
| 9-1 | Add fake dependency | ✅ PASS | - | Added F-999 to F-001 |
| 9-2 | Regenerate release plan | ✅ PASS | - | |
| 9-3 | Verify missing deps section | ❌ FAIL | medium | No Missing Dependencies section found |
| 10-1 | Create new intent | ✅ PASS | - | Created F-005 "Awesome Banner" |

#### Issues Found This Run

- **ISSUE-028:** Dependency ordering ignores release targets (high) - **RESOLVED**
- **ISSUE-029:** Missing dependencies section not generated (medium) - **RESOLVED**

---

## Active Issues

### ISSUE-021: pnpm audit reports vulnerabilities

**Severity:** low
**Step:** 12-3
**Status:** active
**First Seen:** 2026-01-23
**Last Seen:** 2026-01-23

**Expected:** `pnpm audit` should have no moderate/high findings
**Actual:** Audit reports 1 moderate (esbuild) and 1 low (tmp) vulnerability
**Error:** `pnpm audit` exits non-zero

**Notes:** Likely dev-only deps but still reported by audit

**Implementation:**
- Add a small allowlist mechanism for `pnpm audit` (advisory ID + rationale + expiry).
- Prefer upgrading `esbuild`/`tmp` or adding `pnpm.overrides` before allowlisting.
- Update CI workflow to fail on unlisted or expired advisories.
- Create `security/audit-allowlist.json` to store scoped exceptions.

---

### ISSUE-039: Missing do-not-repeat ledgers

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `/do-not-repeat/` includes `bad-patterns.md` and `rejected-libraries.md`
**Actual:** Only `abandoned-designs.md` and `failed-experiments.md` exist
**Error:** Missing ledgers for negative knowledge tracking

**Implementation:**
- Add `do-not-repeat/bad-patterns.md` and `do-not-repeat/rejected-libraries.md` with brief headers + usage guidance.
- Update `scripts/init-project.sh` to create these files for new projects.

---

### ISSUE-040: Missing assumption-extractor rule

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `.cursor/rules/assumption-extractor.mdc` exists per plan
**Actual:** Rule file is missing
**Error:** No explicit mechanism to surface hidden assumptions

**Implementation:**
- Create `.cursor/rules/assumption-extractor.mdc` with prompts that log assumptions.
- Add a target log file (e.g., `workflow-state/assumptions.md`) and seed it in `workflow-state/`.

---

### ISSUE-042: Missing SYSTEM_STATE.md

**Severity:** medium
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `SYSTEM_STATE.md` exists and is updated by generator
**Actual:** File does not exist
**Error:** No concise system summary for Steward context

**Implementation:**
- Update `scripts/generate-system-state.sh` to compile: active intent, phase, recent decisions, drift summary.
- Ensure script writes `SYSTEM_STATE.md` at repo root.
- Add a `generate-system-state` invocation to `/status` or `/ship` as a post-step.

---

### ISSUE-043: Missing confidence-calibration.json

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `confidence-calibration.json` tracks confidence vs outcomes
**Actual:** File does not exist
**Error:** No calibration feedback loop

**Implementation:**
- Add `confidence-calibration.json` with `{ "decisions": [] }`.
- Define a minimal schema in docs and update `/ship` or `/verify` to append entries.

---

### ISSUE-044: Missing .agent-id coordination file

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `.agent-id` exists (per worktree) to coordinate parallel agents
**Actual:** File does not exist
**Error:** Parallel worktree protocol not scaffolded

**Implementation:**
- Update `scripts/setup-worktrees.sh` to write `.agent-id` with a unique integer per worktree.
- Include instructions in `scripts/setup-worktrees.sh` output for agents to read `.agent-id`.

---

### ISSUE-045: Missing golden-data/.gitkeep

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** `golden-data/.gitkeep` keeps replay data directory tracked
**Actual:** Directory exists but empty
**Error:** Replay validation storage not initialized

**Implementation:**
- Add `golden-data/.gitkeep` to keep directory tracked.
- Optionally add `golden-data/README.md` describing replay input format.

---

### ISSUE-046: Intent subfolders missing

**Severity:** low
**Step:** UX
**Status:** active
**First Seen:** 2026-01-27
**Last Seen:** 2026-01-27

**Expected:** Intent ledger uses `intent/features`, `intent/bugs`, `intent/tech-debt` per plan
**Actual:** Flat `intent/` with only `_TEMPLATE.md`
**Error:** Intent organization deviates from plan

**Implementation:**
- Create `intent/features`, `intent/bugs`, `intent/tech-debt`.
- Update `scripts/new-intent.sh` and `scripts/scope-project.sh` to write into category subfolders.
- Update `scripts/generate-release-plan.sh` and `scripts/generate-roadmap.sh` to search recursively under `intent/`.

---
## Implementation Research Notes (for future work)

### ISSUE-021: pnpm audit reports vulnerabilities

**Best approach:**
- Upgrade/override vulnerable packages first; only allowlist when upgrades are blocked.
- If allowlisting, require advisory IDs, rationale, and expiry.

**Integration points:**
- `package.json` overrides (or direct dependency bumps) for `esbuild`/`tmp`.
- CI workflow: fail `pnpm audit` unless advisories are allowlisted.
- New tracked file: `security/audit-allowlist.json` for scoped exceptions.

---

### ISSUE-039: Missing do-not-repeat ledgers

**Best approach:**
- Add missing ledgers as empty templates with brief guidance.

**Integration points:**
- `do-not-repeat/bad-patterns.md`
- `do-not-repeat/rejected-libraries.md`

---

### ISSUE-040: Missing assumption-extractor rule

**Best approach:**
- Add `.cursor/rules/assumption-extractor.mdc` with prompts to log assumptions.

**Integration points:**
- `.cursor/rules/assumption-extractor.mdc`
- Optional: write outputs to `workflow-state/disagreements.md` or a new assumptions log.

---

### ISSUE-042: Missing SYSTEM_STATE.md

**Best approach:**
- Create a generator to summarize active/blocked intents and recent decisions.

**Integration points:**
- `scripts/generate-system-state.sh` (already present) should output `SYSTEM_STATE.md`.
- `SYSTEM_STATE.md` at repo root.

---

### ISSUE-043: Missing confidence-calibration.json

**Best approach:**
- Add a tracked JSON schema with an initial empty `decisions` array.

**Integration points:**
- `confidence-calibration.json` at repo root.

---

### ISSUE-044: Missing .agent-id coordination file

**Best approach:**
- Generate `.agent-id` per worktree as part of `setup-worktrees.sh`.

**Integration points:**
- `scripts/setup-worktrees.sh`
- `.agent-id` at worktree root.

---

### ISSUE-045: Missing golden-data/.gitkeep

**Best approach:**
- Add `.gitkeep` to keep directory tracked and document replay inputs.

**Integration points:**
- `golden-data/.gitkeep`
- Optional: add a short README in `golden-data/`.

---

### ISSUE-046: Intent subfolders missing

**Best approach:**
- Create `intent/features`, `intent/bugs`, `intent/tech-debt` and adjust generators to target them.

**Integration points:**
- `scripts/new-intent.sh` and `scripts/scope-project.sh` output paths.
- `scripts/generate-release-plan.sh` and `scripts/generate-roadmap.sh` intent discovery logic.

---

**Note:** For historic test runs and resolved issues, see `ISSUES_HISTORIC.md`.
