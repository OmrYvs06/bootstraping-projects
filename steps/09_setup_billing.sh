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
  
  # true to ignore "Plugin ruby already added" error
  asdf plugin add ruby || true

  CFLAGS='-Wno-compound-token-split-by-macro -Wno-pointer-to-enum-cast -Wno-nullability-completeness -Wno-expansion-to-defined -Wno-undef-prefix -Wno-error=implicit-function-declaration' asdf install ruby 2.6.7
  asdf set ruby 2.6.7 # may be commented out
  gem install bundler:1.17.3
  bundle install
)

print_done "Setting up Billing success"