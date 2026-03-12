#!/usr/bin/env bash

HOSTS_FILE="/etc/hosts"

ensure_hosts_line() {
  local line="$1"

  if [ -z "$line" ]; then
    return 0
  fi

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