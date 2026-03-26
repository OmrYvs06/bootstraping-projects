#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP BILLING"
print_info "Starting Billing setup..."

if [ ! -d "billing" ]; then
  print_error "billing directory is missing."
  exit 1
fi

# settings
(
  cd "billing"

  asdf install ruby 2.6.7
  asdf set ruby 2.6.7

  bundle install
)

print_done "Setting up Billing success"