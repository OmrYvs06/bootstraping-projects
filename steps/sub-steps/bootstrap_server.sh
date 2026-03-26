#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP SERVER - BOOTSTRAP"
print_info "Starting Server databases and seeding setup..."

if [ ! -d "server" ]; then
  print_error "Server directory is missing."
  exit 1
fi

# settings
(
  cd "server"

  SEED_E_MIKRO_EINVOICE=true \
  SEED_E_MIKRO_ESMM=true \
  SEED_FORIBA_EINVOICE=true \
  SEED_E_MIKRO_EARCHIVE_ONLY=true \
  SEED_IRGAT_EARCHIVE_ONLY=true \
  bin/bootstrap
)

print_done "Setting up Server databases and seeding success."