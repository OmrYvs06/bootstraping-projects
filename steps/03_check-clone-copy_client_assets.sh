#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/lib/repos.sh"

print_centered_title "CHECKING LIBRARIES FOR CLIENT"
print_info "Starting checking operations..."

# Checking "node_modules" ve "bower_components" for client
if [ -d "client" ]; then
  print_skip "client already exists."

  if [ -d "client/node_modules" ]; then
    print_skip "client/node_modules already exists, skipping client-node-modules clone."
  else
    clone_repo_if_missing "client-node-modules"
  fi

  if [ -d "client/bower_components" ]; then
    print_skip "client/bower_components already exists, skipping client-bower-components clone."
  else
    clone_repo_if_missing "client-bower-components"
  fi
else
  clone_repo_if_missing "client"
  clone_repo_if_missing "client-node-modules"
  clone_repo_if_missing "client-bower-components"
fi


if [ ! -d "client/node_modules" ]; then
  print_info "copying node_modules to client."
  cp -r "client-node-modules/node_modules" "client/"
  print_done "node_modules copied to client."
fi

if [ ! -d "client/bower_components" ]; then
  print_info "copying bower_components to client."
  cp -r "client-bower-components/bower_components" "client/"
  print_done "bower_components copied to client."
fi


print_done "Client assets copy completed"