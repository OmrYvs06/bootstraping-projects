#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$BASE_DIR/lib/common.sh"


# this is cleaning up for installed node_modules and bower_components
# this script only deletes:
# "client-bower-components-main" and "client-node-modules-master" folders

# Remove client-node-modules if it exists
if [ -d "client-node-modules" ]; then
  rm -rf "client-node-modules"
  print_done "Removed client-node-modules."
else
  print_skip "client-node-modules directory does not exist."
fi

# Remove client-bower-components if it exists
if [ -d "client-bower-components" ]; then
  rm -rf "client-bower-components"
  print_done "Removed client-bower-components."
else
  print_skip "client-bower-components directory does not exist."
fi
