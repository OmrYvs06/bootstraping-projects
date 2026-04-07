#!/usr/bin/env bash

set -euo pipefail

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





print_info()  { printf "[INFO] %s\n" "$1"; }
print_done()  { printf "[DONE] %s\n" "$1"; }
print_skip()  { printf "[SKIP] %s\n" "$1"; }
print_warn()  { printf "[WARN] %s\n" "$1"; }
print_error() { printf "[ERROR] %s\n" "$1" >&2; }