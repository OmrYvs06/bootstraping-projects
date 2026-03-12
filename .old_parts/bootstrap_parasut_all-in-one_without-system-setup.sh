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

# ------------------------------------------------------
# ---- Detect shell rc file ----------------------------

detect_rc_file() {
  if [ -n "${ZSH_VERSION:-}" ] || [[ "${SHELL:-}" == *"zsh" ]]; then
    echo "${HOME}/.zshrc"
  elif [ -n "${BASH_VERSION:-}" ] || [[ "${SHELL:-}" == *"bash" ]]; then
    echo "${HOME}/.bashrc"
  else
    # Fallback: zshrc tercih et, yoksa bashrc
    if [ -f "${HOME}/.zshrc" ]; then
      echo "${HOME}/.zshrc"
    else
      echo "${HOME}/.bashrc"
    fi
  fi
}

RC_FILE="$(detect_rc_file)"
touch "$RC_FILE"

print_info "Using shell config file: $RC_FILE"

# ------------------------------------------------------
# ---- Ensure export lines exist -----------------------

ensure_export_line() {
  local file="$1"
  local line="$2"

  if grep -Fxq "$line" "$file"; then
    print_skip "Already exists in $(basename "$file"): $line"
  else
    echo "$line" >> "$file"
    print_done "Added to $(basename "$file"): $line"
  fi
}

ensure_export_line "$RC_FILE" 'export EMBER_DOORKEEPER_APPLICATION_ID=1'
ensure_export_line "$RC_FILE" 'export PHOENIX_DOORKEEPER_APPLICATION_ID=1'

# ------------------------------------------------------
# ---- Hosts entries -----------------------------------

HOSTS_FILE="/etc/hosts"
TMP_HOSTS_BLOCK="$(mktemp)"

cat > "$TMP_HOSTS_BLOCK" <<'EOF'

# Parasut Hosts Configuration
127.0.0.1 uygulama.parasut.localhost
127.0.0.1 abone.parasut.localhost
127.0.0.1 admin.parasut.localhost
127.0.0.1 api.parasut.localhost

# Bizmu Hosts Configuration
127.0.0.1 uygulama.bizmu.localhost
127.0.0.1 api.bizmu

# Asist Hosts Configuration
127.0.0.1 uygulama.atlas-asist.localhost
127.0.0.1 api.atlas-asist
EOF

ensure_hosts_line() {
  local line="$1"

  # boş satırsa direkt geç
  if [ -z "$line" ]; then
    return 0
  fi

  # comment satırıysa aynen eklenmemesi çok kritik değil; varsa geç, yoksa ekle
  if [[ "$line" =~ ^# ]]; then
    if grep -Fqx "$line" "$HOSTS_FILE"; then
      print_skip "Hosts comment already exists: $line"
    else
      echo "$line" | sudo tee -a "$HOSTS_FILE" > /dev/null
      print_done "Added hosts comment: $line"
    fi
    return 0
  fi

  if grep -Fqx "$line" "$HOSTS_FILE"; then
    print_skip "Hosts entry already exists: $line"
  else
    echo "$line" | sudo tee -a "$HOSTS_FILE" > /dev/null
    print_done "Added hosts entry: $line"
  fi
}

print_info "Checking hosts entries in $HOSTS_FILE"

while IFS= read -r line; do
  ensure_hosts_line "$line"
done < "$TMP_HOSTS_BLOCK"

rm -f "$TMP_HOSTS_BLOCK"

# ------------------------------------------------------
# ---- Finishing Info ----------------------------------

echo
print_info "Reload your shell config with:"
echo "source \"$RC_FILE\""
echo "or just relaunch zsh/bash"
echo
print_info "Then Verify:"
echo 'echo $EMBER_DOORKEEPER_APPLICATION_ID'
echo 'echo $PHOENIX_DOORKEEPER_APPLICATION_ID'

# MAIN BLOCK -------------------------------------------
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