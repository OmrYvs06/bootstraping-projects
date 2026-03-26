#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP E-DOC-BROKER"
print_info "Starting E-doc-broker setup..."

if [ ! -d "e-doc-broker" ]; then
  print_error "e-doc-broker directory is missing."
  exit 1
fi

# settings
(
  cd "e-doc-broker"

  asdf install ruby 2.6.6
  asdf set ruby 2.6.6

  bundle install
)

print_done "Setting up E-doc-broker success"