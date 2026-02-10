#!/usr/bin/env bash
# Test shipit upgrade --dry-run (no actual changes)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

REPO_ROOT="${REPO_ROOT:-$(get_repo_root)}"

# Dry-run from repo root must not fail
node "$REPO_ROOT/bin/shipit" upgrade --path "$REPO_ROOT" --dry-run
assert_ok "shipit upgrade --dry-run completed"

# list-backups in repo root (may be empty)
node "$REPO_ROOT/bin/shipit" list-backups --path "$REPO_ROOT"
assert_ok "shipit list-backups completed"
