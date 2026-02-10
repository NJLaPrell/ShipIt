# Issue Analysis & Work Order for 1.0.0 Release

## Recommended Work Order

Based on dependencies and logical flow:

### Phase 1: Foundation (Independent work)

1. **#79** - Refactor init-project.sh (enables test project creation)
2. **#82** - Deprecate projects/ directory (can be done in parallel with #79)

### Phase 2: Core CLI (Foundation for everything else)

3. **#78** - CLI implementation (foundational, many depend on this)
4. **#84** - Stack-specific scaffolding (needed for CLI to work properly)

### Phase 3: CLI Features

5. **#80** - Upgrade mechanism (depends on CLI)
6. **#83** - CLI testing (depends on CLI)

### Phase 4: Testing Infrastructure

7. **#85** - Testing strategy update (depends on #79, #83)
8. **#86** - Automate tests (depends on #79, #85)

### Phase 5: Publishing & Documentation

9. **#87** - npm publishing (depends on CLI)
10. **#81** - Documentation updates (depends on everything)
11. **#88** - Production readiness (depends on everything)

---

## Risk & Confidence Assessment

### Issue #79: Refactor init-project.sh

**Risk Score: 6/10** (Medium)

- Could break test project creation if refactoring goes wrong
- Isolated to internal testing, so impact is contained
- Need to ensure all test references updated correctly

**Confidence Score: 8/10** (High)

- Clear requirements: detect framework repo, use fixtures, create tests/test-project
- Straightforward refactoring of existing script
- Well-understood codebase (init-project.sh is readable)
- Risk mitigated by: test project creation is internal-only

**Key Concerns:**

- Need to ensure framework repo detection is robust
- All references to projects/shipit-test have been updated to tests/test-project (completed in issue #79)
- Test fixtures need to be complete

---

### Issue #78: CLI Implementation

**Risk Score: 7/10** (High) ⬇️ Reduced from 9/10

- Foundational - many other issues depend on this
- Complex: npm package structure, file discovery, copying, merging
- User-facing - mistakes are visible to end users
- Package.json merging is tricky (preserve user fields, handle collisions)
- File manifest system needs to work correctly
- **Risk Reduced:** Issue now includes detailed implementation phases, specific edge cases, validation steps, and risk mitigation strategies

**Confidence Score: 8/10** (High) ⬆️ Increased from 7/10

- Well-defined requirements in CLI_DESIGN.md
- Framework-files-manifest.json already exists
- Clear command surface (init, upgrade, check, create)
- **Confidence Increased:** Issue now includes:
  - 9 detailed implementation phases with specific tasks
  - Explicit edge case handling for package.json merge
  - Validation steps for each phase
  - Risk mitigation strategies
  - Dry-run mode for safety
  - Rollback procedures

**Key Concerns:**

- Package.json merge logic (collision detection, preserving formatting)
- File discovery from npm package (node_modules/shipit/...)
- Error handling for edge cases (permissions, disk space, corrupted files)
- Non-interactive mode for CI/CD

---

### Issue #84: Stack-Specific Scaffolding

**Risk Score: 5/10** (Medium)

- Could copy wrong files if detection fails
- Stack detection logic needs to be robust
- Edge cases: multiple indicators, empty directories

**Confidence Score: 8/10** (High)

- Clear detection logic: package.json → Node, pyproject.toml → Python
- Manifest already defines stackSpecific section
- Straightforward file filtering based on stack
- Risk mitigated by: simple detection rules, manifest exists

**Key Concerns:**

- Handling ambiguous cases (both package.json and pyproject.toml exist)
- Ensuring tests/ directory never copied (framework-only)
- Stack-specific CI workflow templates

---

### Issue #80: Upgrade Mechanism

**Risk Score: 6/10** (Medium) ⬇️ Reduced from 8/10

- Could break user projects if upgrade goes wrong
- File modification detection (hash comparison) needs to be accurate
- Backup/restore must be reliable
- Merge logic for project.json and package.json is complex
- User data loss risk if backup fails
- **Risk Reduced:** Issue now includes:
  - 9 detailed implementation phases with specific tasks
  - Explicit hash calculation edge cases (empty files, binary, symlinks)
  - Detailed backup strategy with cleanup options
  - Reuse of package.json merge from issue #78 (reduces duplication risk)
  - Rollback procedures documented
  - Abort-on-backup-failure strategy (prevents data loss)

**Confidence Score: 8/10** (High) ⬆️ Increased from 6/10

- Clear requirements: use manifest, backup modified files, merge carefully
- Backup strategy is well-defined
- **Confidence Increased:** Issue now includes:
  - Detailed hash-based detection with edge cases
  - Timestamp fallback for hash failures
  - Specific backup format and cleanup strategy
  - Detailed merge logic for package.json, project.json, .gitignore
  - Validation steps for each phase
  - Testing strategy (unit, integration, manual)

**Key Concerns:**

- File hash comparison (SHA-256) - edge cases with empty files, binary files
- Backup reliability (disk space, permissions)
- Merge logic for nested JSON (project.json settings, package.json scripts)
- Restore procedures need to be tested thoroughly

---

### Issue #82: Deprecate projects/

**Risk Score: 3/10** (Low)

- Mostly documentation and search-replace
- Low risk of breaking anything
- Worst case: some references missed (easy to fix)

**Confidence Score: 9/10** (Very High)

- Straightforward: find all references, update paths
- Clear grep commands provided in issue
- Mostly mechanical work
- Risk mitigated by: comprehensive search, easy to verify

**Key Concerns:**

- Need to search comprehensively (scripts, docs, commands)
- Ensure .gitignore updated correctly

---

### Issue #83: CLI Testing

**Risk Score: 5/10** (Medium)

- Testing infrastructure needs to be robust
- Test isolation important (temp directories, cleanup)
- Could miss edge cases if tests incomplete

**Confidence Score: 7/10** (Medium-High)

- Clear test scenarios defined in issue
- Test framework choice (shell scripts) matches existing style
- Risk mitigated by: comprehensive test scenarios listed
- Risk factors: test infrastructure setup, edge case coverage

**Key Concerns:**

- Test isolation (temp directories, cleanup)
- Testing merge scenarios (package.json collisions)
- Testing upgrade with modified files
- Non-interactive mode testing

---

### Issue #85: Testing Strategy Update

**Risk Score: 3/10** (Low)

- Mostly documentation and strategy
- Low risk of breaking anything
- Clarifies existing approach

**Confidence Score: 9/10** (Very High)

- Clear requirements: update docs, clarify test layers
- Mostly documentation work
- Risk mitigated by: straightforward updates

**Key Concerns:**

- Ensure all test references updated
- Clear separation between framework tests and CLI tests

---

### Issue #86: Automate Tests

**Risk Score: 4/10** (Low-Medium) ⬇️ Reduced from 6/10

- Test automation could be flaky if not robust
- Parsing TEST_PLAN.md or creating test-config.json
- CI integration needs to be reliable
- **Risk Reduced:** Issue now includes:
  - 8 detailed implementation phases
  - Recommendation to use structured JSON (easier than markdown parsing)
  - Comprehensive test helper functions defined
  - Headless testing strategy (remove editor dependencies)
  - Incremental approach (start simple, add complexity)

**Confidence Score: 8/10** (High) ⬆️ Increased from 6/10

- Clear requirements: automated runner, CI integration
- Test helpers need to be comprehensive
- **Confidence Increased:** Issue now includes:
  - Specific test helper functions (assert_file_exists, assert_json_has_key, etc.)
  - Structured test config format (JSON) with examples
  - Detailed test runner implementation steps
  - CI integration with GitHub Actions example
  - Test result format (human-readable and JSON)
  - Validation steps for each phase

**Key Concerns:**

- Test plan parsing (structured vs markdown)
- Assertion functions need to handle edge cases
- CI integration (GitHub Actions setup)
- Test result reporting

---

### Issue #87: npm Publishing

**Risk Score: 7/10** (Medium-High)

- Publishing mistakes are visible to all users
- Package.json configuration critical (files field, bin field)
- Version alignment with GitHub releases
- npm authentication and 2FA setup

**Confidence Score: 7/10** (Medium-High)

- Well-documented npm publishing process
- Clear requirements: package.json config, files field, bin field
- Risk mitigated by: can test with npm pack locally first
- Risk factors: package size, file inclusion, version management

**Key Concerns:**

- Package.json files field (what gets published)
- Ensuring all framework files included
- Version alignment (GitHub tags vs npm versions)
- npm authentication setup
- Testing published package locally before release

---

### Issue #81: Documentation Updates

**Risk Score: 4/10** (Low-Medium)

- Documentation errors could confuse users
- Need to ensure all references updated
- Migration guide needs to be accurate

**Confidence Score: 8/10** (High)

- Clear list of docs to update
- Mostly straightforward updates
- Risk mitigated by: can review and iterate
- Risk factors: missing some references, unclear migration path

**Key Concerns:**

- Comprehensive search for all references
- Migration guide accuracy (if needed)
- VS Code extension updates

---

### Issue #88: Production Readiness

**Risk Score: 4/10** (Low-Medium)

- Missing limitations/docs could lead to user confusion
- Error handling gaps could cause user frustration
- Mostly documentation/polish work

**Confidence Score: 8/10** (High)

- Clear checklist of what's needed
- Mostly documentation work
- Risk mitigated by: comprehensive issue breakdown
- Risk factors: completeness of limitations list, error handling decisions

**Key Concerns:**

- Completeness of limitations documentation
- Error handling decisions (fail-fast vs retry)
- Release checklist completeness

---

## Summary Statistics

**Average Risk Score: 5.1/10** (Medium) ⬇️ Reduced from 5.5/10
**Average Confidence Score: 7.9/10** (High) ⬆️ Increased from 7.5/10

**Improvements Made:**

- **Issue #78:** Risk reduced 9→7, Confidence increased 7→8
- **Issue #80:** Risk reduced 8→6, Confidence increased 6→8
- **Issue #86:** Risk reduced 6→4, Confidence increased 6→8

**Highest Risk Issues:**

1. #78 (CLI Implementation) - 9/10
2. #80 (Upgrade Mechanism) - 8/10
3. #87 (npm Publishing) - 7/10

**Lowest Confidence Issues:**

1. #80 (Upgrade Mechanism) - 6/10
2. #86 (Automate Tests) - 6/10
3. #78 (CLI Implementation) - 7/10

**Recommendations:**

- Focus extra attention on #78, #80, #87 (highest risk)
- Consider pairing/review for #78 and #80 (complex merge logic)
- Test #80 upgrade mechanism thoroughly before release
- Use npm pack to test #87 locally before publishing
