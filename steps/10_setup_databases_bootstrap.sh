#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP DATABASES - BOOTSTRAP"
print_info "Starting databases and seeding setup..."

if [ ! -d "server" ]; then
  print_error "Server directory is missing."
  exit 1
fi

# Cannot be used without a VPN connection.
# Consider adding a VPN connection check script later in here.

# settings
(
  bash "$BASE_DIR/steps/sub-steps/bootstrap_server.sh"
  bash "$BASE_DIR/steps/sub-steps/bootstrap_billing.sh"
  bash "$BASE_DIR/steps/sub-steps/bootstrap_edocbroker.sh"
)
print_done "Databases and seeding setup completed"