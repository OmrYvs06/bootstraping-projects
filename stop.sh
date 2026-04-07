#!/usr/bin/env bash

# This script is responsible for stopping the tmux session and 
# cleaning up any residual processes related to the projects.

set -euo pipefail

SESSION="parasutcom"

log() {
  printf '%s\n' "$1"
}

if ! command -v tmux >/dev/null 2>&1; then
  printf 'ERROR: tmux is not installed.\n' >&2
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  log "Session '$SESSION' not found."
  exit 0
fi

log "Stopping tmux session: $SESSION"

# Pane'lere Ctrl+C gönder
while IFS= read -r pane; do
  tmux send-keys -t "$pane" C-c
done < <(tmux list-panes -a -t "$SESSION" -F '#{session_name}:#{window_name}.#{pane_index}')

# Uygulamalara kapanma süresi ver
sleep 4

# Session hâlâ varsa kapat
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
fi

log "Cleaning residual processes for this project..."

# Daha hedefli temizlik (opsyonel)
pkill -f './node_modules/ember-cli/bin/ember serve' || true
pkill -f 'yarn run ember serve --watcher=polling --polling-interval=1000' || true
pkill -f 'PROJECT_TARGET=phoenix ./node_modules/ember-cli/bin/ember serve' || true
pkill -f 'PROJECT_TARGET=companion ./node_modules/ember-cli/bin/ember serve' || true
pkill -f 'bundle exec puma -C config/puma.rb' || true
pkill -f 'bundle exec sidekiq -C config/sidekiq.yml' || true
pkill -f 'rails server -p 4002' || true
pkill -f 'rails s -p 5002' || true
pkill -f 'foreman start --formation ' || true

log "Done."