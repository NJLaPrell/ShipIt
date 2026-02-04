# /scope-project

Run the deterministic scoping script. **Nothing else.**

## Usage

```
/scope-project [project-description]
```

## What To Do

Run this command in the terminal:

```bash
./scripts/scope-project.sh "<project-description>"
```

**CRITICAL: Show all script output**

- Display all script prompts and user responses in the chat
- Show any errors or warnings from the script
- Echo the interactive Q&A session as it happens
- After completion, read and display `project-scope.md` contents

That's it. The script handles everything:

- Asks follow-up questions
- Waits for user answers
- Collects feature candidates
- Prompts for intent selection
- Generates intent files
- Creates `project-scope.md`
- Runs roadmap and release plan generators

## Hard Rules

1. **RUN THE SCRIPT.** Do not scope manually.
2. **DO NOT** assume answers or use defaults.
3. **DO NOT** create intents without the script.
4. **DO NOT** modify `src/`, `tests/`, or `README.md`.
5. **DO NOT** edit intent files to force roadmap output.

If the script is missing, tell the user to re-run `/init-project`.

## Output

After the script runs, verify these files exist:

- `project-scope.md` (with Q/A and intent selection)
- `intent/features/F-*.md` (generated intents)
- `generated/roadmap/now.md`, `next.md`, `later.md`
- `generated/release/plan.md`
