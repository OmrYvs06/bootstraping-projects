#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP TRINITY"
print_info "Starting Trinity setup..."

if [ ! -d "trinity" ]; then
  print_error "trinity directory is missing."
  exit 1
fi

# settings
(
  cd "trinity"

  asdf install nodejs 8.16.0
  asdf set nodejs 8.16.0

  asdf install yarn 1.21.1
  asdf set yarn 1.21.1

  npm install -g bower
  bower install
  yarn install

  cat > .env.development <<'EOF'
API_HOST=http://api.parasut.localhost:3000
LOGIN_HOST=http://uygulama.parasut.localhost:3000
EMBER_HOST=http://localhost:4200
EXPORT_TEMPLATE_HOST=http://uygulama.parasut.localhost:3000
PRINTAP_HOST=http://printap.parasut.localhost:3000
INTEGRATIONS_HOST=http://uygulama.parasut.localhost:3000
FULL_APP_HOST=http://uygulama.parasut.localhost:3000
EOF
)

print_done "Setting up Trinity success"