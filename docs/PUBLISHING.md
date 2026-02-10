# Publishing ShipIt to npm

This document describes how to publish the ShipIt CLI package to npm.

## npm package name (required before first publish)

**The unscoped name `shipit` is taken** on npm (by a shipping/tracking package: https://www.npmjs.com/package/shipit). You cannot claim it without the current maintainer transferring it.

**Use a scoped name.** Two options:

1. **Your username (simplest):** `@njlaprell/shipit`
   - Install: `npm install -g @njlaprell/shipit`
   - No org to create; publish with `npm publish --access public`.

2. **Org (for a brand):** Create npm org `shipit-framework`, then use `@shipit-framework/cli`.
   - Install: `npm install -g @shipit-framework/cli`
   - Publish: `npm publish --access public`.

**To switch from `shipit` to a scoped name:** In `package.json` set `"name": "@njlaprell/shipit"` (or your chosen scope). Update README and docs so install instructions use the scoped name (e.g. `npm install -g @njlaprell/shipit`). The **bin** names stay `shipit` and `create-shipit-app` — users still run `shipit` and `create-shipit-app` after installing.

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

1. Set `package.json` **name** to your scoped name (e.g. `@njlaprell/shipit`) — see above.
2. Bump **version** in `package.json` to match the release (e.g. `0.7.0`).
3. Run `npm publish --dry-run` to preview.
4. Run `npm publish --access public` (required for scoped packages; requires npm login and 2FA).
5. Verify on npm (e.g. https://www.npmjs.com/package/@njlaprell/shipit).

## CI publish (optional)

To publish automatically on GitHub release creation, add a workflow that runs on `release: published`, runs tests, then `npm publish` using `NODE_AUTH_TOKEN` (GitHub Secret set to an npm automation token). See issue #87 for a YAML sketch.

## Version alignment

- Keep `package.json` version in sync with GitHub release tags (e.g. tag `v0.6.0` → version `0.6.0`).
- Use semantic versioning: major for breaking changes, minor for features, patch for fixes.

## Before your first release

- [ ] Choose scoped npm name and set `"name"` in `package.json` (see above).
- [ ] Update README and any docs that say `npm install -g shipit` to use the scoped install command.
- [ ] (Optional) Add **NPM_TOKEN** (or **NODE_AUTH_TOKEN**) in GitHub repo secrets if you want the publish workflow to run on release.
- [ ] Run through [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) and [\_system/behaviors/DO_RELEASE.md](../_system/behaviors/DO_RELEASE.md).
