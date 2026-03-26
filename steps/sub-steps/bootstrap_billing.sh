#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP BILLING - BOOTSTRAP"
print_info "Starting Billing databases and seeding setup..."

if [ ! -d "billing" ]; then
  print_error "Billing directory is missing."
  exit 1
fi

# settings
(
  cd "billing"

  SEED_E_MIKRO_EINVOICE=true \
  SEED_E_MIKRO_ESMM=true \
  SEED_FORIBA_EINVOICE=true \
  SEED_E_MIKRO_EARCHIVE_ONLY=true \
  SEED_IRGAT_EARCHIVE_ONLY=true \
  bin/bootstrap
)

print_done "Setting up Billing databases and seeding success"