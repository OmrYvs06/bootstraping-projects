#!/usr/bin/env bash

clone_repo_if_missing() {
  local repo="$1"

  if [ -d "$repo" ]; then
    print_skip "$repo already exists."
  else
    print_info "Cloning $repo..."
    git clone "https://github.com/parasutcom/$repo" "$repo"
    print_done "$repo cloned."
  fi
}