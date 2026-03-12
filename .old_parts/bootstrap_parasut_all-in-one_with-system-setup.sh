#!/usr/bin/env bash

# how to: 
# 1. bu .sh dosyasını boş bir proje klasörüne kopyalayın.
# 2. bu .sh dosyasını "chmod + filename.sh" ile çalıştırılabilir yapın.
# 3. bu .sh dosyasını çalıştırın. ("bash filename.sh")
# not: koddaki bootstrap komutlarının çalışabilmesi için
#       şirket ağına ya direkt ya da vpn ile bağlantı sağlanmalıdır.

set -euo pipefail

# Helpers ----------------------------------------------
# ------------------------------------------------------

print_line() {
  local width="${1:-80}"
  local char="${2:-=}"
  printf '%*s\n' "$width" '' | tr ' ' "$char"
}

print_centered_title() {
  local text="$1"
  local width
  width=$(tput cols 2>/dev/null || echo 80)

  local text_len=${#text}
  local total_padding=$((width - text_len))

  if [ "$total_padding" -lt 0 ]; then
    total_padding=0
    width=$text_len
  fi

  local left_padding=$((total_padding / 2))
  local right_padding=$((total_padding - left_padding))

  echo
  print_line "$width" "="
  printf "%*s%s%*s\n" "$left_padding" "" "$text" "$right_padding" ""
  print_line "$width" "="
}

print_info() {
  printf "[INFO] %s\n" "$1"
}

print_done() {
  printf "[DONE] %s\n" "$1"
}

print_skip() {
  printf "[SKIP] %s\n" "$1"
}

print_warn() {
  printf "[WARN] %s\n" "$1"
}

print_error() {
  printf "[ERROR] %s\n" "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  local cmd="$1"
  local pretty_name="${2:-$1}"

  if command_exists "$cmd"; then
    print_done "$pretty_name is installed"
  else
    print_error "$pretty_name is missing"
    #return 1
  fi
}

require_asdf_plugin() {
  local plugin="$1"

  if asdf plugin list 2>/dev/null | grep -qx "$plugin"; then
    print_done "asdf plugin '$plugin' is installed"
  else
    print_error "asdf plugin '$plugin' is missing"
    return 1
  fi
}

require_asdfrc_legacy_mode() {
  local asdfrc_path="$HOME/.asdfrc"

  if [ -f "$asdfrc_path" ] && grep -qx 'legacy_version_file = yes' "$asdfrc_path"; then
    print_done "~/.asdfrc contains 'legacy_version_file = yes'"
  else
    print_error "~/.asdfrc is missing 'legacy_version_file = yes'"
    cat "legacy_version_file = yes" > ~/.asdfrc 
    print_done "'~/.asdfrc' file created with 'legacy_version_file = yes' parameter inside"
  fi
}

preflight_check() {
  local failed=0

  print_centered_title "CHECKING PRE-REQUIREMENTS"
  print_info "Validating system dependencies..."

  require_command "brew" "Homebrew" || failed=1
  require_command "git" "git" || failed=1

  print_info "Checking required system tools..."
  require_command "redis-server" "redis" || failed=1
  require_command "psql" "postgres" || failed=1
  require_command "asdf" "asdf" || failed=1

  print_info "Checking asdf build prerequisites..."
  require_command "xcode-select" "xcode-select" || failed=1
  require_command "autoconf" "autoconf" || failed=1
  require_command "python3" "python" || failed=1

  # libyaml ve gmp binary komut olarak her zaman görünmeyebilir.
  # Bu yüzden bunları brew üstünden kontrol etmek daha güvenlidir.

  if command_exists brew; then
    if brew list --versions openssl@3 >/dev/null 2>&1; then
      print_done "openssl@3 is installed"
    else
      print_error "openssl@3 is missing"
      failed=1
    fi

    if brew list --versions readline >/dev/null 2>&1; then
      print_done "readline is installed"
    else
      print_error "readline is missing"
      failed=1
    fi

    if brew list --versions libyaml >/dev/null 2>&1; then
      print_done "libyaml is installed"
    else
      print_error "libyaml is missing"
      failed=1
    fi

    if brew list --versions gmp >/dev/null 2>&1; then
      print_done "gmp is installed"
    else
      print_error "gmp is missing"
      failed=1
    fi

    if brew list --versions "rbenv/tap/openssl@1.1" >/dev/null 2>&1; then
      print_done "openssl@1.1 is installed"
    else
      print_warn "openssl@1.1 is missing (some older ruby builds may fail without it)"
    fi
  fi

  if command_exists asdf; then
    print_info "Checking asdf plugins..."
    require_asdf_plugin "ruby" || failed=1
    require_asdf_plugin "nodejs" || failed=1
    require_asdf_plugin "yarn" || failed=1

    print_info "Checking ~/.asdfrc..."
    require_asdfrc_legacy_mode || failed=1
  fi

  if [ "$(uname -m)" = "arm64" ]; then
    print_warn "Detected macOS arm64."
    print_warn "If ruby/node installs fail, check the team's arm64 guides and asdf-ruby / asdf-nodejs troubleshooting docs."
  fi

  if [ "$failed" -ne 0 ]; then
    print_line 80 "="
    print_error "Pre-requirements check failed."
    print_info "Install the missing dependencies first, then run this script again."
    echo
    echo "Recommended commands:"
    echo "brew update && brew install redis postgres asdf"
    echo "xcode-select --install"
    echo "brew install openssl@3 readline libyaml gmp autoconf"
    echo "brew install rbenv/tap/openssl@1.1"
    echo "brew install python"
    echo "asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git"
    echo "asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
    echo "asdf plugin add yarn"
    echo 'echo "legacy_version_file = yes" > ~/.asdfrc'
    print_line 80 "="
    exit 1
  fi

  print_done "All pre-requirements look good"
}

# MAIN BLOCK -------------------------------------------
# ---- Checking Pre-requirements -----------------------

preflight_check

# ------------------------------------------------------
# ---- Cloning Github Pages ----------------------------

print_centered_title "CLONING ALL REPOSITORIES"
print_info "Starting cloning..."

repos=(
  "server"
  "billing"
  "e-doc-broker"
  "client"
  "trinity"
  "shared-logic"
  "client-node-modules"
  "client-bower-components"
)

for repo in "${repos[@]}"; do
  if [ -d "$repo" ]; then
    print_skip "$repo already exists."
    continue
  fi

  print_info "Cloning $repo..."
  git clone "https://github.com/parasutcom/$repo"
  print_done "$repo cloned."
done

print_done "Cloning repositories success"

# ------------------------------------------------------
# ---- Copying Client Modules --------------------------

print_centered_title "COPYING CLIENT MODULES TO THEIR FOLDER"
print_info "Starting copying..."

if [ -d "client/node_modules" ]; then
  print_skip "client/node_modules already exists."
else
  cp -r client-node-modules/node_modules client
  print_done "node_modules copied to client."
fi

if [ -d "client/bower_components" ]; then
  print_skip "client/bower_components already exists."
else
  cp -r client-bower-components/bower_components client
  print_done "bower_components copied to client."
fi

print_done "Copying success"

# ------------------------------------------------------
# ---- Setting Up Client -------------------------------

print_centered_title "SETTING UP CLIENT"
print_info "Starting Client setup..."

cd client
asdf install nodejs 0.11.16 && asdf set nodejs 0.11.16
npm install -g bower
bower install
cd ..

print_done "Setting up Client success"

# ------------------------------------------------------
# ---- Setting Up Trinity ------------------------------

print_centered_title "SETTING UP TRINITY"
print_info "Starting Trinity setup..."

cd trinity
asdf install nodejs 8.16.0 && asdf set nodejs 8.16.0
asdf install yarn 1.21.1 && asdf set yarn 1.21.1
npm install -g bower
bower install
yarn install
echo "API_HOST=http://api.parasut.localhost:3000
LOGIN_HOST=http://uygulama.parasut.localhost:3000
EMBER_HOST=http://localhost:4200
EXPORT_TEMPLATE_HOST=http://uygulama.parasut.localhost:3000
PRINTAP_HOST=http://printap.parasut.localhost:3000
INTEGRATIONS_HOST=http://uygulama.parasut.localhost:3000
FULL_APP_HOST=http://uygulama.parasut.localhost:3000" > .env.development
cd ..

print_done "Setting up Trinity success"

# ------------------------------------------------------
# ---- Setting Up Shared-logic -------------------------


print_centered_title "SETTING UP SHARED-LOGIC"
print_info "Starting Shared-Logic setup..."

cd trinity
# sed sadece tek satırda iş yapar, ileride bu kural bozulursa yeni yöntem arayın
sed -i '' 's#"shared-logic": ".*"#"shared-logic": "link:../shared-logic"#' package.json
cd ..

cd shared-logic
asdf install nodejs 8.16.0 && asdf set nodejs 8.16.0
asdf install yarn 1.21.1 && asdf set yarn 1.21.1
yarn install
bower install
cd ..

print_done "Setting up Shared-Logic success"

# ------------------------------------------------------
# ---- Setting Up Server -------------------------------

print_centered_title "SETTING UP SERVER"
print_info "Starting Server setup..."

cd server
asdf install ruby 2.6.9 && asdf set ruby 2.6.9
bundle install
SEED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
cd ..

print_done "Setting up Server success"

# ------------------------------------------------------
# ---- Setting Up Billing ------------------------------

print_centered_title "SETTING UP BILLING"
print_info "Starting Billing setup..."

cd billing
asdf install ruby 2.6.7 && asdf set ruby 2.6.7
bundle install
SEED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
cd ..

print_done "Setting up Billing success"

# ------------------------------------------------------
# ---- Setting Up E-Doc-Breaker ------------------------

print_centered_title "SETTING UP E-DOC-BROKER"
print_info "Starting E-doc-broker setup..."

cd e-doc-broker
asdf install ruby 2.6.6 && asdf set ruby 2.6.6
bundle install
SEED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
cd ..

print_done "Setting up E-doc-broker success"

# ------------------------------------------------------
# ---- Deleting not needed client module folders -------

rm -rf client-node-modules
rm -rf client-bower-components

# ------------------------------------------------------
# ------------------------------------------------------