# Release Checklist

Use this checklist before cutting a release. Integrates with [\_system/behaviors/DO_RELEASE.md](../_system/behaviors/DO_RELEASE.md) (commit, tag, push, GitHub release, optional npm publish).

## Pre-release

- [ ] All tests pass: `pnpm test`
- [ ] CLI tests pass: `pnpm test:cli`
- [ ] Framework E2E pass: `pnpm test:shipit -- --clean`
- [ ] Lint and typecheck: `pnpm lint && pnpm typecheck`
- [ ] Documentation updated (README, docs/, LIMITATIONS.md, TROUBLESHOOTING.md, CLI_REFERENCE.md as needed)
- [ ] CHANGELOG.md has an `[Unreleased]` section and a new version section for this release
- [ ] Breaking changes (if any) documented in CHANGELOG and relevant docs
- [ ] Version bumped in `package.json` to match release (e.g. `0.7.0`)

## Release execution

Follow [\_system/behaviors/DO_RELEASE.md](../_system/behaviors/DO_RELEASE.md):

- [ ] Step 1: Commit release preparation (CHANGELOG, package.json, README as per DO_RELEASE)
- [ ] Step 2: Create annotated git tag (e.g. `v0.7.0`)
- [ ] Step 3: Push commits and tag to GitHub
- [ ] Step 4: Create GitHub release (required) with release notes from CHANGELOG
- [ ] Step 5: Publish to npm (optional) — see [PUBLISHING.md](./PUBLISHING.md)

## Post-release

- [ ] Verify GitHub release is published and marked latest (if applicable)
- [ ] If published to npm: verify `npm install -g shipit` and run `shipit --help`, `shipit check`
- [ ] Update any external references or badges if needed
- [ ] Move CHANGELOG [Unreleased] items into the new version section and add new [Unreleased] for next release

## Version alignment

- Git tag format: `vX.Y.Z` (e.g. `v0.7.0`)
- `package.json` version: `X.Y.Z` (no `v` prefix)
- GitHub release title/notes: match CHANGELOG section for that version

See [VERSIONING.md](./VERSIONING.md) for version and deprecation policy.
