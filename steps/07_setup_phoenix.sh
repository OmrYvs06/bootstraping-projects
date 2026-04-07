#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP PHOENIX"
print_info "Starting Phoenix setup..."

if [ ! -d "phoenix" ]; then
  print_error "phoenix directory is missing."
  exit 1
fi

# settings
(
  cd "phoenix"
  
  # true to ignore "Plugin nodejs already added" error
  asdf plugin add nodejs || true
  arch -x86_64 /bin/zsh -lc '
  asdf install nodejs 10.15.3
  asdf set nodejs 10.15.3
  '
  print_info "nodejs 10.15.3 setted"
  
  # true to ignore "Plugin yarn already added" error
  asdf plugin add yarn || true
  asdf install yarn 1.21.1
  asdf set yarn 1.21.1
  print_info "yarn 1.21.1 setted"

  npm install -g bower
  print_info "bower installed"
  bower install
  print_info "bower dependencies installed"

  yarn install
  print_info "yarn dependencies installed"
)

print_done "Setting up Phoenix success"