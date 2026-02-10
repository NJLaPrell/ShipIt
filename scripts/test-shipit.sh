#!/usr/bin/env bash
# Automated ShipIt framework E2E test: create test project and run basic assertions.
# Headless (no editor). For full workflow use .cursor/commands/test_shipit.md.
# Usage: ./scripts/test-shipit.sh [--clean]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

# Optional: remove existing test project first
if [[ "${1:-}" == "--clean" ]]; then
  rm -rf tests/test-project
fi

# Source common for error_exit
# shellcheck source=scripts/lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

echo "ShipIt framework E2E test (headless)"
echo "  Root: $ROOT_DIR"
echo ""

# 1) Create test project (non-interactive; reads tests/fixtures.json)
echo "Step 1: Create test project..."
./scripts/init-project.sh shipit-test || error_exit "init-project.sh failed" 1

# 2) Assert key files and dirs exist
TP="$ROOT_DIR/tests/test-project"
assert() {
  local path="$1"
  local desc="${2:-$path}"
  if [[ -e "$path" ]]; then
    echo "  ok: $desc"
  else
    error_exit "Missing: $desc ($path)" 1
  fi
}

echo "Step 2: Assert project structure..."
assert "$TP/project.json" "project.json"
assert "$TP/AGENTS.md" "AGENTS.md"
assert "$TP/scripts" "scripts/"
assert "$TP/scripts/verify.sh" "scripts/verify.sh"
assert "$TP/_system/architecture/CANON.md" "_system/architecture/CANON.md"
assert "$TP/work/intent" "work/intent/"
# .override/ is created by CLI init; init-project.sh may or may not create it
[[ -d "$TP/.override" ]] && echo "  ok: .override/" || true

echo ""
echo "PASS: ShipIt framework E2E (test project creation and structure)"
exit 0
