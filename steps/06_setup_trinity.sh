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
  
  # true to ignore "Plugin nodejs already added" error
  asdf plugin add nodejs || true
  arch -x86_64 /bin/zsh -lc '
  asdf install nodejs 8.16.0
  asdf set nodejs 8.16.0
  '
  print_info "nodejs 8.16.0 setted"
  
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