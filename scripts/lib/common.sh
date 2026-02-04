#!/bin/bash

# Common script plumbing: error handling, colors, optional require_* helpers.
# Source this from scripts that need consistent exit behavior and colors.
# For intent resolution, source intent.sh instead (it sources this).
# Caller script should already use set -euo pipefail.

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Colors (safe to use in echo -e)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Optional: require a command to be present. Usage: require_cmd node jq git
require_cmd() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error_exit "$cmd is required but not installed" 1
        fi
    done
}
