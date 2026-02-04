# /generate-roadmap

Regenerate roadmap files from current intents.

## Usage

```
/generate-roadmap
```

## What To Do

Run this command in the terminal:

```bash
./scripts/generate-roadmap.sh
```

Or if `pnpm` scripts are set up:

```bash
pnpm generate-roadmap
```

## Output

Updates these files based on intent status and dependencies:

- `roadmap/now.md` — Intents with no unmet dependencies (ready to work on)
- `roadmap/next.md` — Intents with dependencies on "Now" items
- `roadmap/later.md` — Intents with deeper dependency chains or lower priority
- `artifacts/dependencies.md` — Dependency graph visualization

## When To Use

- After creating or modifying intents
- After changing intent status or dependencies
- To verify roadmap reflects current state
