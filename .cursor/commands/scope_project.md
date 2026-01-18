# /scope-project

AI-assisted project scoping to break down a project into features, identify dependencies, and create initial intents.

## Usage

```
/scope-project [project-description]
```

Example: `/scope-project "Build a todo app with user authentication and payment processing"`

## What It Does

This command uses AI to scope a project:

1. **Follow-Up Questions (Required):**
   - Ask targeted questions until enough detail exists
   - Clarify users, platforms, scope boundaries, data model, and constraints
   - **Wait for answers** and record them in `project-scope.md`

2. **Feature Proposal:**
   - Produce a candidate feature list with dependencies
   - Tag risk level and complexity

3. **Intent Selection (Required):**
   - Prompt the user to select which features to turn into intents
   - Support selecting all, none, or a subset
   - Record the selection in `project-scope.md`
   - **Do NOT create intents before selection**

4. **Intent Generation:**
   - Create intent files only for selected features
   - Map dependencies between intents
   - Set initial priorities
   - Generate roadmap and release plan

5. **Documentation:**
   - Generate `project-scope.md` with full analysis
   - Update `roadmap/now.md`, `next.md`, `later.md`
   - Create dependency graph

## Process

**Switch to PM role** (read `.cursor/rules/pm.mdc`):

1. **Read Project Context:**
   - Read `project.json` for project metadata
   - Understand tech stack and constraints
   - Review existing architecture (if any)

2. **Analyze Project Description:**
   - Break down into core features
   - Identify user stories/use cases
   - Identify technical components
   - Identify external dependencies

3. **Feature Extraction:**
   - List all features with descriptions
   - Estimate complexity (low/medium/high)
   - Identify dependencies between features
   - Prioritize features

4. **Dependency Mapping:**
   - Create dependency graph
   - Identify critical path
   - Identify parallel work opportunities
   - Flag circular dependencies

5. **Risk Assessment:**
   - Identify high-risk features
   - Flag features requiring human approval
   - Identify technical risks
   - Suggest mitigation strategies

6. **Generate Intents:**
   - Create intent file for each selected feature
   - Set dependencies in intent files
   - Set initial priorities
   - Run `pnpm generate-roadmap` and `pnpm generate-release-plan`

7. **Save Results:**
   - Save to `project-scope.md`
   - Update roadmap files
   - Create dependency visualization

## Output

Creates:
- `project-scope.md` - Full scoping analysis and open questions
- Intent files in `/intent/` for selected features only
- `release/plan.md` - Ordered release plan
- Updated `roadmap/now.md`, `next.md`, `later.md`
- Dependency graph (text or visual)

## Required Behavior (Hard Requirements)

- Ask follow-up questions before any intents are created, then wait for answers.
- Prompt for intent selection before creating any intent files.
- Capture follow-up answers and intent selection in `project-scope.md`.
- Always create or update `project-scope.md`.
- Always generate `release/plan.md` and update roadmap files.
- Do NOT implement production code or edit `src/` or `README.md` during scoping.

## Next Steps

After scoping:
1. Review `project-scope.md`
2. Review generated intents
3. Adjust priorities in roadmap
4. Start shipping features with `/ship`

## See Also

- `project-scope.md` - Full scoping results
- `/intent/` - Generated intent files
- `/roadmap/` - Project roadmap
