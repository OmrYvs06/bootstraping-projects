#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"



print_centered_title "CLEANING UP"
print_info "Removing temporary repository folders..."

(
  bash "$BASE_DIR/steps/cleanup/cleanup_client-bower_modules.sh"
)

print_done "Cleanup completed"