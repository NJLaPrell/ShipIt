# Versioning and Deprecation

## Semantic versioning

ShipIt follows **semantic versioning** (major.minor.patch: `X.Y.Z`).

- **Major (e.g. 1.0.0)** — Breaking changes, major architecture or CLI changes. Upgrade may require migration steps (documented in CHANGELOG).
- **Minor (e.g. 0.7.0)** — New features, backward compatible. Existing projects and CLI usage continue to work.
- **Patch (e.g. 0.6.1)** — Bug fixes and docs, backward compatible.

## Version alignment

- **GitHub release tags:** `vX.Y.Z` (e.g. `v0.7.0`)
- **package.json `version`:** `X.Y.Z` (no `v`)
- **npm:** Same as package.json. Publish after or with the GitHub release; see [PUBLISHING.md](./PUBLISHING.md).

## Deprecation policy

- **Support window:** Deprecated features are supported for at least **2 minor versions** (e.g. deprecated in 0.8.0, removed no earlier than 1.0.0).
- **Communication:** Deprecations are announced in CHANGELOG.md and, when applicable, via CLI warnings or docs.
- **Migration:** Migration path and examples are provided in CHANGELOG and relevant docs (e.g. TROUBLESHOOTING.md, CLI_REFERENCE.md).

## Pre-releases

- Pre-release versions (e.g. `0.7.0-beta.1`, `0.7.0-rc.1`) may be used for testing. They are not considered stable; behavior may change before the corresponding stable release.
