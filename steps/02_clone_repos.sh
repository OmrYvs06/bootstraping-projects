#!/usr/bin/env bash
set -euo pipefail

# importing required libs/configs
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/lib/repos.sh"

repos=(
  "server"
  "billing"
  "e-doc-broker"
  "client"
  "trinity"
  "shared-logic"
  "phoenix"
)

# This cloning script only doing clone, not checking if its already okey to not clone 
# Cloning Process
print_centered_title "CLONING ALL REPOSITORIES"
print_info "Starting cloning..."
print_info "Cloning location: $(pwd)"
for repo in "${repos[@]}"; do
  clone_repo_if_missing "$repo" 
done

print_done "Cloning repositories success"