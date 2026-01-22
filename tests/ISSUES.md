# ShipIt Test Results

## Test Runs

### Run Template (Copy/Paste)

```
### Run: YYYY-MM-DDTHH:MM:SSZ (root-project | test-project)

**Steps Executed:** X  
**Steps Passed:** Y  
**Steps Failed:** Z  
**Blocking Issues:** N  
**Result:** ✅ PASS | ❌ FAIL

#### Summary

| Step | Name | Status | Severity | Notes |
|------|------|--------|----------|-------|
| 1-1 | Init project | ✅ PASS | - | |
| 1-2 | Provide inputs | ✅ PASS | - | |
| 2-2 | Validate project structure | ⏭️ SKIP | - | Blocked by step 1-4 |
```

### Run: 2026-01-22T22:15:23Z (root-project)

**Steps Executed:** 4  
**Steps Passed:** 4  
**Steps Failed:** 0  
**Blocking Issues:** 0  
**Result:** ✅ PASS (root-mode stop after step 1-4)

#### Summary

| Step | Name | Status | Severity | Notes |
|------|------|--------|----------|-------|
| 1-1 | Init project | ✅ PASS | - | |
| 1-2 | Provide inputs | ✅ PASS | - | |
| 1-3 | Verify project created | ✅ PASS | - | |
| 1-4 | Verify required files | ✅ PASS | - | |
| 2-2 | Validate project structure | ⏭️ SKIP | - | Root mode stop |
| 3-1 | Run scope-project | ⏭️ SKIP | - | Root mode stop |
| 3-2 | Answer follow-ups | ⏭️ SKIP | - | Root mode stop |
| 3-3 | Verify intent files | ⏭️ SKIP | - | Root mode stop |
| 3-4 | Verify outputs | ⏭️ SKIP | - | Root mode stop |
| 4-1 | Create single intent | ⏭️ SKIP | - | Root mode stop |
| 5-1 | Run generate-release-plan | ⏭️ SKIP | - | Root mode stop |
| 5-2 | Verify release plan | ⏭️ SKIP | - | Root mode stop |
| 6-1 | Run generate-roadmap | ⏭️ SKIP | - | Root mode stop |
| 6-2 | Verify roadmap | ⏭️ SKIP | - | Root mode stop |
| 7-1 | Check template fields | ⏭️ SKIP | - | Root mode stop |
| 7-2 | Update intent fields | ⏭️ SKIP | - | Root mode stop |
| 7-3 | Regenerate release plan | ⏭️ SKIP | - | Root mode stop |
| 7-4 | Verify ordering | ⏭️ SKIP | - | Root mode stop |
| 8-1 | Edit dependencies | ⏭️ SKIP | - | Root mode stop |
| 8-2 | Regenerate release plan | ⏭️ SKIP | - | Root mode stop |
| 8-3 | Verify F-002 before F-001 | ⏭️ SKIP | - | Root mode stop |
| 9-1 | Add fake dependency | ⏭️ SKIP | - | Root mode stop |
| 9-2 | Regenerate release plan | ⏭️ SKIP | - | Root mode stop |
| 9-3 | Verify missing deps section | ⏭️ SKIP | - | Root mode stop |
| 10-1 | Create new intent | ⏭️ SKIP | - | Root mode stop |
| 10-2 | Verify roadmap+release update | ⏭️ SKIP | - | Root mode stop |

---

## Active Issues

*No active issues.*

---

## Resolved Issues

### ISSUE-001: generate-roadmap.sh treated "None" as dependency

**Severity:** high
**Step:** 6-2
**Status:** resolved
**First Seen:** 2026-01-22
**Resolved:** 2026-01-22

**Expected:** Intents with "None" dependencies should go in "Now" bucket
**Actual:** All intents placed in "Next" bucket
**Error:** Script treated any non-empty line as a dependency

**Resolution:** Updated `scripts/generate-roadmap.sh` to filter out "None", "(none)", and placeholder text.

---

### ISSUE-002: Intent template header mismatches

**Severity:** high
**Step:** 7-1
**Status:** resolved
**First Seen:** 2026-01-22
**Resolved:** 2026-01-22

**Expected:** Headers: `## Priority`, `## Effort`, `## Release Target`
**Actual:** Headers: `## Priority`, `## Size`, `## Target Release`
**Error:** Scripts couldn't parse intent fields due to wrong header names

**Resolution:** Fixed all intent files and template to use correct header names.

---

### ISSUE-003: generate-release-plan.sh dependency ordering broken

**Severity:** blocking
**Step:** 7-4
**Status:** resolved
**First Seen:** 2026-01-22
**Resolved:** 2026-01-22

**Expected:** F-002 (no deps) should appear before F-001 (depends on F-002)
**Actual:** F-001 appeared first despite depending on F-002
**Error:** `parseDependencies` returned full strings, but `topoSort` checked for ID matches

**Resolution:** Updated `parseDependencies` to extract just intent IDs using regex `^([A-Z]-\d+)`.

---

### ISSUE-004: Missing /generate-roadmap slash command

**Severity:** low
**Step:** 6-1
**Status:** resolved
**First Seen:** 2026-01-22
**Resolved:** 2026-01-22

**Expected:** All commands available as slash commands
**Actual:** TEST_PLAN.md referenced `pnpm generate-roadmap` instead of slash command
**Error:** Inconsistent command interface

**Resolution:** Created `.cursor/commands/generate_roadmap.md`.

---

## Historical Issues (Pre-2026-01-22)

<details>
<summary>Click to expand earlier issues</summary>

### /scope-project behavioral issues

Multiple issues were discovered and fixed related to `/scope-project` not following the intended interactive flow:

1. Did not ask follow-up questions
2. Performed implementation work during scoping
3. Did not prompt for intent selection
4. Did not update roadmap files
5. Assumed answers without user input

**Resolution:** Implemented deterministic script flow, updated PM rules, and added strict enforcement in command files.

### generate-roadmap.sh empty array crash

**Error:** Script failed on macOS bash with `set -u` when arrays were empty.

**Resolution:** Used `${ARRAY[@]+"${ARRAY[@]}"}` syntax for safe empty array expansion.

</details>

---

## Issue Statistics

| Severity | Total | Active | Resolved |
|----------|-------|--------|----------|
| Blocking | 1 | 0 | 1 |
| High | 2 | 0 | 2 |
| Medium | 0 | 0 | 0 |
| Low | 1 | 0 | 1 |
| **Total** | **4** | **0** | **4** |
