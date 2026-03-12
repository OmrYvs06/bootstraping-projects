#!/usr/bin/env bash

SESSION="parasutcom"

# Her pane'e Ctrl+C gönder
if tmux has-session -t "$SESSION" 2>/dev/null; then
  for pane in $(tmux list-panes -a -t "$SESSION" -F '#{session_name}:#{window_name}.#{pane_index}'); do
    tmux send-keys -t "$pane" C-c
  done

  sleep 4
  tmux kill-session -t "$SESSION"
else
  echo "Session '$SESSION' not found."
fi

echo "Trying to clean residual processes..."

# Gerekirse kalanları temizle
pkill -f 'ember serve' || true
pkill -f 'bundle exec puma -C config/puma.rb' || true
pkill -f 'bundle exec sidekiq -C config/sidekiq.yml' || true
pkill -f 'rails server -p 4002' || true
pkill -f 'rails s -p 5002' || true
pkill -f 'foreman start' || true