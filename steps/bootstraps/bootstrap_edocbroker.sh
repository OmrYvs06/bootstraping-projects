#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP E-DOC-BROKER - BOOTSTRAP"
print_info "Starting E-doc-broker databases and seeding setup..."

if [ ! -d "e-doc-broker" ]; then
  print_error "e-doc-broker directory is missing."
  exit 1
fi

# settings
(
  cd "e-doc-broker"

  SEED_E_MIKRO_EINVOICE=true \
  SEED_E_MIKRO_ESMM=true \
  SEED_FORIBA_EINVOICE=true \
  SEED_E_MIKRO_EARCHIVE_ONLY=true \
  SEED_IRGAT_EARCHIVE_ONLY=true \
  bin/bootstrap
)

print_done "Setting up E-doc-broker databases and seeding success"