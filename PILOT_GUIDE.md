# Real-World Pilot Guide

This guide helps you run a real-world feature through the complete ShipIt workflow.

## Prerequisites

1. **Project Initialized:**
   \`\`\`bash
   /init-project "My Test Project"
   \`\`\`

2. **Cursor Integration Validated:**
   \`\`\`bash
   pnpm validate-cursor
   \`\`\`

3. **Basic Project Structure:**
   - `project.json` exists
   - `intent/` directory exists
   - `workflow-state/` directory exists

## Pilot Feature Suggestions

Choose a non-trivial but manageable feature:

### Option 1: User Authentication
- **Complexity:** Medium
- **Dependencies:** None
- **Risk:** High (auth is high-risk)
- **Good for:** Testing security agent, high-risk workflows

### Option 2: API Endpoint
- **Complexity:** Low-Medium
- **Dependencies:** None
- **Risk:** Low
- **Good for:** Testing basic workflow, test-first approach

### Option 3: Database Integration
- **Complexity:** Medium
- **Dependencies:** None
- **Risk:** Medium
- **Good for:** Testing architecture decisions, integration patterns

## Step-by-Step Pilot

### Step 1: Initialize Workflow

\`\`\`bash
# Create intent
/new_intent

# Or manually create intent file
# Then initialize workflow state
pnpm workflow-orchestrator F-001
\`\`\`

### Step 2: Run Full Workflow

Use the `/ship` command and follow each phase:

1. **Phase 1: Analysis (PM Role)**
   - Read intent file
   - Fill in `workflow-state/01_analysis.md`
   - Check confidence scores
   - Verify do-not-repeat check

2. **Phase 2: Planning (Architect Role)**
   - Read analysis
   - Fill in `workflow-state/02_plan.md`
   - Check CANON.md compliance
   - **STOP for human approval**

3. **Phase 3: Test Writing (QA Role)**
   - Write tests first
   - Verify tests fail (nothing to pass yet)
   - Commit tests separately

4. **Phase 4: Implementation (Implementer Role)**
   - Implement exactly as planned
   - Make tests pass
   - Fill in `workflow-state/04_implementation.md`

5. **Phase 5: Verification (QA + Security Roles)**
   - Run all tests
   - Run mutation tests
   - Security review
   - Fill in `workflow-state/05_verification.md`

6. **Phase 6: Release (Docs + Steward Roles)**
   - Update documentation
   - Write release notes
   - Final approval
   - Fill in `workflow-state/06_release.md`

### Step 3: Document Issues

As you go through the workflow, document:

- **What worked well:**
  - [List successes]

- **What didn't work:**
  - [List issues]

- **What was confusing:**
  - [List confusion points]

- **What needs improvement:**
  - [List improvements]

### Step 4: Validate Results

After completing the pilot:

1. **Check Intent Status:**
   - Intent should be marked `shipped`
   - All acceptance criteria met

2. **Review Workflow State:**
   - All 6 phase files should be complete
   - `active.md` should be updated

3. **Check Quality:**
   - Tests pass
   - Coverage meets threshold
   - Lint/typecheck pass

4. **Review Documentation:**
   - README updated
   - CHANGELOG updated
   - Release notes written

## Common Issues & Solutions

### Issue: Cursor doesn't recognize slash commands
**Solution:** 
- Check `.cursor/commands/` files exist
- Restart Cursor
- Check Cursor settings for command recognition

### Issue: Workflow state files not auto-generated
**Solution:**
- Run `pnpm workflow-orchestrator <intent-id>` manually
- Check script permissions: `chmod +x scripts/workflow-orchestrator.sh`

### Issue: Agent roles not clear
**Solution:**
- Read `.cursor/rules/*.mdc` files
- Explicitly state role switching in chat
- Follow role constraints strictly

### Issue: Tests fail after implementation
**Solution:**
- Review test expectations
- Check implementation matches plan
- Verify no plan deviations

## Success Criteria

Pilot is successful if:

- ✅ All 6 phases completed
- ✅ Tests written before implementation
- ✅ All tests pass
- ✅ Security review completed
- ✅ Documentation updated
- ✅ Intent marked as shipped
- ✅ No blocking issues encountered

## Next Steps After Pilot

1. **Update Framework:**
   - Fix issues found
   - Improve documentation
   - Add missing features

2. **Run Another Pilot:**
   - Try different feature type
   - Test edge cases
   - Validate improvements

3. **Share Results:**
   - Document learnings
   - Update guides
   - Improve framework

---

*Last updated: 2026-01-12*
