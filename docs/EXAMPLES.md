# ShipIt examples

Short examples for common scenarios. For full workflow see [PILOT_GUIDE.md](./PILOT_GUIDE.md).

## Create a new project (greenfield)

```bash
# Install CLI
npm install -g @nlaprell/shipit

# Create project (prompts for tech stack, description, high-risk)
create-shipit-app my-api

# Or non-interactive
shipit create my-api --tech-stack typescript-nodejs --non-interactive
cd my-api
```

Then open in Cursor/VS Code, run `/scope-project "Build a REST API with auth"`, then `/ship F-001` to ship the first feature.

## Attach ShipIt to an existing project

```bash
cd my-existing-app
shipit init
# Prompts: tech stack, description, high-risk. Merges into existing package.json and layout.
```

Use `--non-interactive` and `--path` for CI or scripts. Customize Cursor/VS Code rules via `.override/` (see [USER_OVERRIDES_DESIGN.md](./USER_OVERRIDES_DESIGN.md)).

## Upgrade framework files

```bash
# See what would change
shipit upgrade --dry-run

# Apply upgrade (backs up modified files to ._shipit_backup/)
shipit upgrade

# Restore a file from backup
shipit list-backups
shipit restore package.json
```

## Validate installation

```bash
shipit check           # Human-readable
shipit check --json    # JSON for scripts
```

## CI: run tests (framework repo)

In GitHub Actions or similar, from the ShipIt framework repo:

- Install: `pnpm install --frozen-lockfile`
- Unit tests: `pnpm test`
- CLI tests: `pnpm test:cli`
- Framework E2E: `pnpm test:shipit -- --clean`

For a **project** that uses ShipIt (not the framework repo), run your project’s test command (e.g. `pnpm test`) in CI as usual; no ShipIt-specific step required unless you use headless workflow scripts.

## Multi-developer workflow

- Intents live in `work/intent/`; manage conflicts via normal Git merge/rebase.
- Use `/status` or `/dashboard` to see current state. Use `/ship <intent-id>` per intent; one intent per branch is typical.
- Release flow: follow [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) and [DO_RELEASE.md](../_system/behaviors/DO_RELEASE.md); coordinate who tags and publishes.

## Common patterns

- **Test-first:** Write or update tests before implementation; verification phase runs them.
- **Override, don’t edit framework:** Put customizations in `.override/` so upgrades don’t overwrite them.
- **One intent per PR:** Keeps PRs small and traceable; use intent ID in branch name if helpful.

## Anti-patterns

- Don’t skip verification or gates “just this once.”
- Don’t edit files under `_system/` or `.cursor/` in the project if you want to upgrade cleanly; use `.override/` for customizations.
- Don’t run `shipit init` in an already-initialized project; use `shipit upgrade`.
