#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP CLIENT"
print_info "Starting Client setup..."

if [ ! -d "client" ]; then
  print_error "client directory is missing."
  exit 1
fi

# settings
(
  cd "client"

  # true to ignore "Plugin nodejs already added" error
  asdf plugin add nodejs || true
  
  arch -x86_64 /bin/zsh -lc '
  asdf install nodejs 0.11.16
  asdf set nodejs 0.11.16
  '
  print_info "nodejs 0.11.16 setted"

  npm install -g bower
  print_info "bower installed"
  bower install
  print_info "bower dependencies installed"
)

print_done "Setting up Client success"