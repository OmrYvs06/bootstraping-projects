#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/lib/shell.sh"
source "$BASE_DIR/lib/hosts.sh"

print_centered_title "SETTING UP SHELL AND HOSTS"

RC_FILE="$(detect_rc_file)"
touch "$RC_FILE"

print_info "Using shell config file: $RC_FILE"

# ------------------------------------------------------
# ---- Ensure export lines exist -----------------------

ensure_export_line "$RC_FILE" 'export EMBER_DOORKEEPER_APPLICATION_ID=1'
ensure_export_line "$RC_FILE" 'export PHOENIX_DOORKEEPER_APPLICATION_ID=1'

# ------------------------------------------------------
# ---- Hosts entries -----------------------------------

print_info "Checking hosts entries in /etc/hosts"

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
print_info "Then verify:"
echo 'echo $EMBER_DOORKEEPER_APPLICATION_ID'
echo 'echo $PHOENIX_DOORKEEPER_APPLICATION_ID'

print_done "Shell and hosts setup completed"