#!/usr/bin/env bash
# Run all ShipIt CLI tests in isolated temp directories.
# Exit 0 if all pass, 1 if any fail.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PASSED=0
FAILED=0

run_one() {
  local name="$1"
  local script="$2"
  local tmpdir
  tmpdir="$(mktemp -d 2>/dev/null || mktemp -d -t shipit-cli-test)"
  echo "--- $name (tmp: $tmpdir) ---"
  if ( cd "$tmpdir" && export TMPDIR="$tmpdir" REPO_ROOT="$REPO_ROOT" && bash "$SCRIPT_DIR/$script" ); then
    echo "PASS: $name"
    ((PASSED++)) || true
  else
    echo "FAIL: $name"
    ((FAILED++)) || true
  fi
  rm -rf "$tmpdir"
}

echo "ShipIt CLI tests (REPO_ROOT=$REPO_ROOT)"
echo ""

# Unit-style tests that don't need temp dir (Vitest runs these separately)
# E2E tests that run CLI in temp dir
for f in "$SCRIPT_DIR"/test-create.sh "$SCRIPT_DIR"/test-check.sh "$SCRIPT_DIR"/test-upgrade.sh; do
  [[ -f "$f" ]] || continue
  [[ -x "$f" ]] || chmod +x "$f" 2>/dev/null || true
  base="$(basename "$f")"
  run_one "$base" "$base"
done

echo ""
echo "Result: $PASSED passed, $FAILED failed"
[[ $FAILED -eq 0 ]]
