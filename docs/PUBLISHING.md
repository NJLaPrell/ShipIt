# Publishing ShipIt to npm

This document describes how to publish the ShipIt CLI package to npm.

## npm package name (required before first publish)

**The unscoped name `shipit` is taken** on npm (by a shipping/tracking package: https://www.npmjs.com/package/shipit). You cannot claim it without the current maintainer transferring it.

**Use a scoped name.** Two options:

1. **Your username (simplest):** `@nlaprell/shipit`
   - Install: `npm install -g @nlaprell/shipit`
   - No org to create; publish with `npm publish --access public`.

2. **Org (for a brand):** Create npm org `shipit-framework`, then use `@shipit-framework/cli`.
   - Install: `npm install -g @shipit-framework/cli`
   - Publish: `npm publish --access public`.

**To switch from `shipit` to a scoped name:** In `package.json` set `"name": "@nlaprell/shipit"` (or your chosen scope). Update README and docs so install instructions use the scoped name (e.g. `npm install -g @nlaprell/shipit`). The **bin** names stay `shipit` and `create-shipit-app` — users still run `shipit` and `create-shipit-app` after installing.

## Prerequisites

- npm account with 2FA enabled
- GitHub release tag created (e.g. `v1.0.0`) — version in `package.json` should match
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
tar -tf nlaprell-shipit-1.0.0.tgz | head -50

# Install globally from tarball and smoke-test
npm install -g ./nlaprell-shipit-1.0.0.tgz
shipit --help
shipit check --path .
create-shipit-app --help
```

## Publish (manual)

1. Set `package.json` **name** to your scoped name (e.g. `@nlaprell/shipit`) — see above.
2. Bump **version** in `package.json` to match the release (e.g. `0.7.0`).
3. Run `npm publish --dry-run` to preview.
4. Publish using **one** of the two methods below (2FA or token with Bypass 2FA).
5. Verify on npm (e.g. https://www.npmjs.com/package/@nlaprell/shipit).

### Method A: Interactive (browser login + OTP)

npm’s browser login gives a **short-lived session** (about 2 hours). Do login and publish in one go so the session is still valid.

1. **Clear any stale auth** (optional but recommended):

   ```bash
   npm logout
   ```

   Then edit `~/.npmrc` and remove any line like `//registry.npmjs.org/:_authToken=...`. Save.

2. **Log in** (opens browser; use your npm account + passkey or password):

   ```bash
   npm login
   ```

   Complete the browser flow until the CLI says you’re logged in.

3. **Publish immediately** (from the project root):
   ```bash
   cd /path/to/ShipIt
   npm publish --access public
   ```
   If prompted for a one-time password, enter the 6-digit code from your authenticator app (or use `--otp=123456` with the current code).

If you see “Access token expired or revoked” after login, the session wasn’t stored correctly or expired. Try Method B.

### Method B: Granular token with Bypass 2FA

Use a **granular access token** that can publish without an OTP. Classic tokens are no longer supported (as of late 2025).

1. **Create the token on the website**
   - Go to [https://www.npmjs.com/settings/~/tokens](https://www.npmjs.com/settings/~/tokens).
   - Click **Generate New Token** → **Granular Access Token**.
   - **Name:** e.g. “ShipIt publish”.
   - **Packages and scopes:** choose **Read and write** for the scope you use (e.g. `@nlaprell`).
   - **Expiration:** set as needed (e.g. 30 days).
   - **Important:** Check **“Bypass two-factor authentication (2FA)”** at creation time (required for publish without OTP). If you don’t see it or it doesn’t stick, try creating the token again; there are known UI issues.
   - Generate and copy the token (starts with `npm_`). Store it somewhere safe (e.g. password manager). Do not commit it or paste it in chat.

2. **Publish using the token**
   - Do **not** rely on an old token in `~/.npmrc`. Remove any `//registry.npmjs.org/:_authToken=...` line from `~/.npmrc` so only the token you pass is used.
   - From the project root:
     ```bash
     cd /path/to/ShipIt
     NODE_AUTH_TOKEN=<your_token> npm publish --access public
     ```
   - Replace `<your_token>` with the new granular token.

3. **If you still get “access token expired or revoked” with a fresh token**

   npm may be using a **different** token (e.g. from `.npmrc`) instead of `NODE_AUTH_TOKEN`. Force the env var to win:
   - **Remove any registry auth from both configs:** In `~/.npmrc` and in the project’s `.npmrc`, delete every line that looks like `//registry.npmjs.org/:_authToken=...`. Save both files.
   - **Optionally pin auth to the env var:** In the **project** `.npmrc` (repo root), add exactly:
     ```
     //registry.npmjs.org/:_authToken=${NODE_AUTH_TOKEN}
     ```
     Then run `NODE_AUTH_TOKEN=<your_new_token> npm publish --access public`. If the env var is set, only that token is used; if not set, publish will fail for lack of auth instead of using an old token.
   - **Token scope:** When you created the token, you must have selected the **scope** that matches your package (e.g. `@nlaprell`) and **Read and write**. If the scope was wrong or read-only, create a new token and try again.
   - **Package 2FA setting (only after the package exists):** On npm, open the package → **Settings** → **Publishing access**. If it says **“Require two-factor authentication and disallow tokens”**, tokens cannot be used. Change it to **“Require two-factor authentication or a granular access token with bypass 2fa enabled”** (the default), then retry.
   - **Bypass 2FA checkbox bug:** The “Bypass 2FA” option on the website sometimes doesn’t stick. Create the token again and ensure the checkbox is checked **before** you generate it. If it still fails, use Method A once and then Method C (Trusted Publishing) for future publishes.

### Method C: Trusted Publishing (OIDC) — no OTP, no long‑lived token

This is the recommended **non-OTP** option: npm accepts publishes from a specific GitHub Actions workflow using short-lived OIDC tokens. No `NODE_AUTH_TOKEN` or manual OTP needed after setup.

**One-time setup:**

1. **First publish** the package once using **Method A** (browser login + OTP). The package must exist on npm before you can add a Trusted Publisher.
2. On [npmjs.com](https://www.npmjs.com), open the package → **Settings** → **Trusted Publisher**. Click **GitHub Actions**.
3. Fill in: **Organization or user** (your GitHub username or org), **Repository** (this repo’s name), **Workflow filename** (e.g. `publish-npm.yml` — must match the file in `.github/workflows/` exactly, including `.yml`).
4. Save. npm will only accept publishes from that workflow.

**Use a workflow that publishes with OIDC:**

- The workflow must request `id-token: write` and run `npm publish` **without** `NODE_AUTH_TOKEN` (or with it only for installing private deps). See the [Trusted publishing](https://docs.npmjs.com/trusted-publishers) docs and the optional workflow below.
- After that, to release: create a GitHub release (or push a tag that triggers the workflow). The workflow runs, and npm accepts the OIDC token — no OTP, no token secret.

**Optional: switch the existing workflow to OIDC**

The repo’s `.github/workflows/publish-npm.yml` currently uses `NODE_AUTH_TOKEN` (secret `NPM_TOKEN`). To use Trusted Publishing instead:

- Add `id-token: write` under `permissions` (or at job level).
- Remove the `env: NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` from the publish step (or keep it only if you need it for private installs).
- Ensure the workflow **filename** matches what you entered in npm Trusted Publisher (e.g. `publish-npm.yml`).
- You can leave the `release: published` trigger as-is; when you create a release, the workflow runs and authenticates via OIDC.

**Requirements:** npm CLI 11.5.1+, Node 22.14+ for trusted publishing. If the current workflow uses Node 20, bump to 22 or 24 for the publish job when using OIDC.

### Why you might see 404 or “token expired”

- **404 on PUT** when publishing a scoped package (e.g. `@nlaprell/shipit`) usually means **authentication failed**. npm often returns 404 instead of 401 so it doesn’t reveal whether the package exists. Fix auth (Method A or B above), then retry.
- **“Access token expired or revoked”** can mean:
  - **After browser login:** The session token from `npm login` is short-lived, or an old token is still in `~/.npmrc`. Remove the `_authToken` line for `registry.npmjs.org`, run `npm login` again, then publish immediately.
  - **With Method B (granular token):** npm may be using a different token (e.g. from `.npmrc`) instead of `NODE_AUTH_TOKEN`. Follow the “If you still get expired or revoked” steps under Method B (clear all `_authToken` lines, optionally use `_authToken=${NODE_AUTH_TOKEN}` in project `.npmrc`). Also confirm token scope and package 2FA setting.
- If **Bypass 2FA** doesn’t work for a token, use Method A once, then set up **Method C (Trusted Publishing)** so future publishes need no OTP and no token.
- Ensure the registry is `https://registry.npmjs.org/`. Check with `npm config get registry`; set with `npm config set registry https://registry.npmjs.org/` if needed.

## CI publish (optional)

To publish automatically on GitHub release creation, add a workflow that runs on `release: published`, runs tests, then `npm publish` using `NODE_AUTH_TOKEN` (GitHub Secret set to an npm automation token). See issue #87 for a YAML sketch.

## Version alignment

- Keep `package.json` version in sync with GitHub release tags (e.g. tag `v1.0.0` → version `1.0.0`).
- Use semantic versioning: major for breaking changes, minor for features, patch for fixes.

## Before your first release

- [ ] Choose scoped npm name and set `"name"` in `package.json` (see above).
- [ ] Update README and any docs that say `npm install -g shipit` to use the scoped install command.
- [ ] (Optional) Add **NPM_TOKEN** (or **NODE_AUTH_TOKEN**) in GitHub repo secrets if you want the publish workflow to run on release.
- [ ] Run through [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) and [\_system/behaviors/DO_RELEASE.md](../_system/behaviors/DO_RELEASE.md).
