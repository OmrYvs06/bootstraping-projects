#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/lib/common.sh"

print_centered_title "PARASUT LOCAL SETUP"

print_info " (pwd) Current Directory Location: $(pwd)"
print_info "          Base Directory Location: ${BASE_DIR}"

# customizable all setup files
#bash "$BASE_DIR/steps/00_system_software_setup.sh" # eklenecek
bash "$BASE_DIR/steps/01_setup_shell_and_hosts.sh"
bash "$BASE_DIR/steps/02_clone_repos.sh"
bash "$BASE_DIR/steps/03_check-clone-copy_client_assets.sh"
bash "$BASE_DIR/steps/04_setup_shared_logic.sh"
bash "$BASE_DIR/steps/05_setup_client.sh"
bash "$BASE_DIR/steps/06_setup_trinity.sh"
bash "$BASE_DIR/steps/07_setup_phoenix.sh"
bash "$BASE_DIR/steps/08_setup_server.sh"
bash "$BASE_DIR/steps/09_setup_billing.sh"
bash "$BASE_DIR/steps/10_setup_e_doc_broker.sh"
# bash "$BASE_DIR/steps/11_bootstrap_databases.sh" # don't fotget to connect to VPN before running this step
bash "$BASE_DIR/steps/12_cleanup.sh"

print_done "All setup steps completed successfully."

# how to: 
# 1. go to your project folder
# 2. call this script
# 3. you are done

# this script installs and set all projects to your current folder

# examples:
# $ bash ./bootstraping-projects/setup.sh
# $ bash ~/parasutcom/bootstraping-projects/setup.sh

# omeryavas@Omers-MacBook-Pro ~/parasutcom % bash ./bootstraping-projects/setup.sh
# |
# |--> this clones and sets all repos in "~/parasutcom" folder