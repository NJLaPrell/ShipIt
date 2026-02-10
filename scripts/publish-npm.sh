#!/usr/bin/env bash
# Publish @nlaprell/shipit to npm. Run from repo root.
# Auth: set NODE_AUTH_TOKEN, or put your npm token (one line, no newline) in .npm-token (gitignored).
# Token must be granular with Bypass 2FA for scope @nlaprell.
# Uses a temp .npmrc so stale token in ~/.npmrc is ignored.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${NODE_AUTH_TOKEN:-}" ]]; then
  echo "Using NODE_AUTH_TOKEN from environment."
elif [[ -f .npm-token ]]; then
  export NODE_AUTH_TOKEN
  NODE_AUTH_TOKEN=$(cat .npm-token | tr -d '\n\r')
  echo "Using token from .npm-token"
else
  echo "No NODE_AUTH_TOKEN and no .npm-token file."
  echo "Create .npm-token with one line: your granular npm token (Bypass 2FA, scope @nlaprell)."
  echo "Or run: NODE_AUTH_TOKEN=<token> pnpm publish:npm"
  exit 1
fi

# Force npm to use only our token (ignore stale ~/.npmrc)
tmp_npmrc=$(mktemp)
echo "//registry.npmjs.org/:_authToken=${NODE_AUTH_TOKEN}" > "$tmp_npmrc"
trap 'rm -f "$tmp_npmrc"' EXIT

echo "Publishing @nlaprell/shipit@$(node -p "require('./package.json').version")..."
npm publish --access public --userconfig "$tmp_npmrc"
