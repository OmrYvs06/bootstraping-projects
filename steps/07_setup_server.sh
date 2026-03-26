#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP SERVER"
print_info "Starting Server setup..."

if [ ! -d "server" ]; then
  print_error "server directory is missing."
  exit 1
fi

# settings
(
  cd "server"

  asdf install ruby 2.6.9
  asdf set ruby 2.6.9

  bundle install
)

print_done "Setting up Server success"