# /scope-project

AI-assisted project scoping to break down a project into features, identify dependencies, and create initial intents.

## Usage

```
/scope-project [project-description]
```

Example: `/scope-project "Build a todo app with user authentication and payment processing"`

## What It Does

This command uses AI to scope a project:

1. **Project Breakdown:**
   - AI analyzes project description
   - Breaks down into discrete features
   - Identifies dependencies between features
   - Estimates complexity
   - Identifies risks

2. **Architecture Suggestions:**
   - AI suggests system architecture
   - Identifies key components
   - Suggests technology choices
   - Identifies integration points

3. **Intent Generation:**
   - Creates initial intent files for each feature
   - Maps dependencies between intents
   - Sets initial priorities
   - Creates project roadmap

4. **Documentation:**
   - Generates `project-scope.md` with full analysis
   - Updates `roadmap/now.md`, `next.md`, `later.md`
   - Creates dependency graph

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
   - Create intent file for each feature
   - Set dependencies in intent files
   - Set initial priorities
   - Generate roadmap

7. **Save Results:**
   - Save to `project-scope.md`
   - Update roadmap files
   - Create dependency visualization

## Output

Creates:
- `project-scope.md` - Full scoping analysis
- Intent files in `/intent/` for each feature
- Updated `roadmap/now.md`, `next.md`, `later.md`
- Dependency graph (text or visual)

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
