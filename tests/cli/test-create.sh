#!/usr/bin/env bash
# Test shipit create (create-shipit-app) - greenfield project creation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

REPO_ROOT="${REPO_ROOT:-$(get_repo_root)}"
PROJECT_NAME="shipit-create-test-$$"

node "$REPO_ROOT/bin/shipit" create "$PROJECT_NAME" \
  --non-interactive \
  --tech-stack typescript-nodejs \
  --skip-git \
  --skip-install

assert_dir_exists "$PROJECT_NAME"
assert_file_exists "$PROJECT_NAME/project.json"
assert_json_has_key "$PROJECT_NAME/project.json" "shipitVersion"
assert_json_has_key "$PROJECT_NAME/project.json" "techStack"
assert_dir_exists "$PROJECT_NAME/.override"
assert_dir_exists "$PROJECT_NAME/scripts"
assert_file_exists "$PROJECT_NAME/AGENTS.md"
assert_file_exists "$PROJECT_NAME/package.json"
assert_file_contains "$PROJECT_NAME/package.json" '"name"'
# Framework tests/ must not be copied into user project
assert_file_not_exists "$PROJECT_NAME/tests/fixtures.json"
assert_file_not_exists "$PROJECT_NAME/tests/TEST_PLAN.md"

# Clean up created project (we're in temp dir)
rm -rf "$PROJECT_NAME"
