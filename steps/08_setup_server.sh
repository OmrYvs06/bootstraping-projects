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
  
  # true to ignore "Plugin ruby already added" error
  asdf plugin add ruby || true
  
  CFLAGS='-Wno-compound-token-split-by-macro -Wno-pointer-to-enum-cast -Wno-nullability-completeness -Wno-expansion-to-defined -Wno-undef-prefix' asdf install ruby 2.6.9
  asdf set ruby 2.6.9
  gem install bundler:2.4.22
  bundle install
)

print_done "Setting up Server success"