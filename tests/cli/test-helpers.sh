#!/usr/bin/env bash
# CLI test helpers - assertions and utilities for ShipIt CLI tests
# Source this from test scripts: source "$(dirname "$0")/test-helpers.sh"

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

assert_fail() {
  echo -e "${RED}FAIL: $*${NC}" >&2
  return 1
}

assert_ok() {
  echo -e "${GREEN}  ok: $*${NC}"
}

# Assert file exists
assert_file_exists() {
  local path="$1"
  if [[ -f "$path" ]]; then
    assert_ok "file exists: $path"
    return 0
  fi
  assert_fail "file missing: $path"
  return 1
}

# Assert file does not exist
assert_file_not_exists() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    assert_ok "file absent (expected): $path"
    return 0
  fi
  assert_fail "file should not exist: $path"
  return 1
}

# Assert directory exists
assert_dir_exists() {
  local path="$1"
  if [[ -d "$path" ]]; then
    assert_ok "dir exists: $path"
    return 0
  fi
  assert_fail "dir missing: $path"
  return 1
}

# Assert a string is in a file
assert_file_contains() {
  local path="$1"
  local pattern="$2"
  if [[ ! -f "$path" ]]; then
    assert_fail "file not found: $path"
    return 1
  fi
  if grep -q "$pattern" "$path"; then
    assert_ok "file contains: $path -> $pattern"
    return 0
  fi
  assert_fail "file does not contain pattern: $path -> $pattern"
  return 1
}

# Assert JSON file has key (using grep for portability)
assert_json_has_key() {
  local path="$1"
  local key="$2"
  if [[ ! -f "$path" ]]; then
    assert_fail "JSON file not found: $path"
    return 1
  fi
  if grep -q "\"$key\"" "$path"; then
    assert_ok "JSON has key: $path -> $key"
    return 0
  fi
  assert_fail "JSON missing key: $path -> $key"
  return 1
}

# Create temp directory and return path (caller must clean up)
create_temp_dir() {
  mktemp -d 2>/dev/null || mktemp -d -t shipit-cli-test
}

# Get repo root (parent of tests/)
get_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  echo "$(cd "$script_dir/../.." && pwd)"
}

# Run shipit CLI (from repo root)
run_shipit() {
  local root
  root="$(get_repo_root)"
  (cd "$root" && node bin/shipit "$@")
}

run_shipit_create() {
  local root
  root="$(get_repo_root)"
  (cd "$root" && node bin/create-shipit-app "$@")
}
