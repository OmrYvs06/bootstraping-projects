#!/usr/bin/env bash

detect_rc_file() {
  if [ -n "${ZSH_VERSION:-}" ] || [[ "${SHELL:-}" == *"zsh" ]]; then
    echo "${HOME}/.zshrc"
  elif [ -n "${BASH_VERSION:-}" ] || [[ "${SHELL:-}" == *"bash" ]]; then
    echo "${HOME}/.bashrc"
  else
    if [ -f "${HOME}/.zshrc" ]; then
      echo "${HOME}/.zshrc"
    else
      echo "${HOME}/.bashrc"
    fi
  fi
}

ensure_export_line() {
  local file="$1"
  local line="$2"

  touch "$file"

  if grep -Fxq "$line" "$file"; then
    print_skip "Already exists in $(basename "$file"): $line"
  else
    echo "$line" >> "$file"
    print_done "Added to $(basename "$file"): $line"
  fi
}