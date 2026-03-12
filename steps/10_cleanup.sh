#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"


# this is cleaning up for installed node_modules and bower_components
# this script only deletes:
# "client-bower-components-main" and "client-node-modules-master" folders

print_centered_title "CLEANING UP"
print_info "Removing temporary repository folders..."

if [ -d "client-node-modules" ]; then
  rm -rf "client-node-modules"
  print_done "Removed client-node-modules."
else
  print_skip "client-node-modules directory does not exist."
fi

if [ -d "client-bower-components" ]; then
  rm -rf "client-bower-components"
  print_done "Removed client-bower-components."
else
  print_skip "client-bower-components directory does not exist."
fi

print_done "Cleanup completed"