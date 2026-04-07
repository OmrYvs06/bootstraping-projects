#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "SETTING UP SHARED-LOGIC"
print_info "Starting Shared-Logic setup..."

if [ ! -d "trinity" ]; then
  print_error "trinity directory is missing."
  exit 1
fi

if [ ! -d "shared-logic" ]; then
  print_error "shared-logic directory is missing."
  exit 1
fi

# changing package.json for our custom "shared-logic" package
(
  cd "trinity"

  # sed sadece tek satırda iş yapar, ileride bu kural bozulursa yeni yöntem arayın
  sed -i '' 's#"shared-logic": ".*"#"shared-logic": "link:../shared-logic"#' package.json
)

# setting up shared logic
(
  cd "shared-logic"

  # true to ignore "Plugin nodejs already added" error
  asdf plugin add nodejs || true
  arch -x86_64 /bin/zsh -lc '
  asdf install nodejs 8.16.0
  asdf set nodejs 8.16.0
  '

  # true to ignore "Plugin yarn already added" error
  asdf plugin add yarn || true
  asdf install yarn 1.21.1
  asdf set yarn 1.21.1

  npm install -g bower
  bower install

  yarn install
)

print_done "Setting up Shared-Logic success"