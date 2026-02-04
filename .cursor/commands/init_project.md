# /init-project

Initialize a new project with ShipIt framework.

## Usage

```
/init-project [project-name]
```

Example: `/init-project "my-app"`

## What To Do (AI Instructions)

**Step 1: Ask these questions in chat (all at once):**

```
To initialize your project, I need:

1. **Tech stack** — Enter 1, 2, or 3:
   - 1 = TypeScript/Node.js (recommended)
   - 2 = Python
   - 3 = Other (manual setup)

2. **Project description** — A short description of your project

3. **High-risk domains** — Comma-separated list, or "none"
   - Examples: auth, payments, permissions, infrastructure, pii
```

**Step 2: Wait for user response.**

Do NOT proceed until the user provides all 3 answers.

**Step 3: Run the script with the answers:**

```bash
printf "<tech-stack>\n<description>\n<high-risk>\n" | ./scripts/init-project.sh <project-name>
```

Replace:

- `<tech-stack>` with 1, 2, or 3
- `<description>` with the user's description
- `<high-risk>` with the user's high-risk domains (or "none")
- `<project-name>` with the project name from the command

## Output

Creates project at `./projects/<project-name>` with:

- `project.json` — Project metadata
- `intent/` — Intent directory with template
- `generated/roadmap/` — Roadmap files
- `architecture/` — CANON.md and invariants.yml
- `.cursor/` — Commands and rules (copied from framework)
- `scripts/` — Core scripts (copied from framework)
- Git repository initialized

## Next Steps

After initialization:

1. Open `./projects/<project-name>` as its own Cursor workspace
2. Run `/scope-project` to break down features
3. Start shipping with `/ship`
