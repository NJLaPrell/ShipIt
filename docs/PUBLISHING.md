# Publishing ShipIt to npm

This document describes how to publish the ShipIt CLI package to npm. The package name is `shipit` (check availability: `npm view shipit`). If the name is taken, use a scoped name such as `@shipit-framework/cli` and update this doc.

## Prerequisites

- npm account with 2FA enabled
- GitHub release tag created (e.g. `v0.6.0`) — version in `package.json` should match
- All tests passing: `pnpm test`, `pnpm test:cli`, `pnpm test:shipit`

## Package contents

The `files` field in `package.json` controls what is included in the tarball:

- `bin/` — CLI entry points (`shipit`, `create-shipit-app`)
- `cli/` — CLI command implementations and utils
- `_system/` — Architecture, manifest, behaviors, etc.
- `.cursor/` — Commands and rules
- `scripts/` — Framework scripts
- `work/intent/templates/` — Intent templates
- `dashboard-app/` — Dashboard
- `AGENTS.md`, `stryker.conf.json`

Excluded (not in `files`): `tests/`, `src/`, `docs/`, `README.md`, `CHANGELOG.md`, TypeScript configs, etc.

## Verify package locally

```bash
# Create tarball
npm pack

# Inspect contents (optional)
tar -tf shipit-0.6.0.tgz | head -50

# Install globally from tarball and smoke-test
npm install -g ./shipit-0.6.0.tgz
shipit --help
shipit check --path .
create-shipit-app --help
```

## Publish (manual)

1. Bump version in `package.json` to match the release (e.g. `0.7.0`).
2. Run `npm publish --dry-run` to preview.
3. Run `npm publish` (requires npm login and 2FA).
4. Verify on npm: https://www.npmjs.com/package/shipit

## CI publish (optional)

To publish automatically on GitHub release creation, add a workflow that runs on `release: published`, runs tests, then `npm publish` using `NODE_AUTH_TOKEN` (GitHub Secret set to an npm automation token). See issue #87 for a YAML sketch.

## Version alignment

- Keep `package.json` version in sync with GitHub release tags (e.g. tag `v0.6.0` → version `0.6.0`).
- Use semantic versioning: major for breaking changes, minor for features, patch for fixes.
