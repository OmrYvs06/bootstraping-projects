#!/usr/bin/env bash

set -euo pipefail

# how to:
# 1. go to your project folder
# 2. call this script
# 3. you are done
#
# examples:
#   bash ./bootstraping-projects/start_all_tmux.sh
#   bash ~/parasutcom/bootstraping-projects/start_all_tmux.sh

SESSION="parasutcom"

# project root = scriptin bulunduğu klasörün bir üstü
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() {
  printf '%s\n' "$1"
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

# dependency check
command -v tmux >/dev/null 2>&1 || fail "tmux is not installed."

# required folders
missing=0
for dir in client trinity phoenix server billing e-doc-broker; do
  if [ ! -d "$BASE_DIR/$dir" ]; then
    log "$dir directory is missing: $BASE_DIR/$dir"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  fail "Stopping because required directories are missing."
fi

# create session only if it does not already exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  log "Creating tmux session: $SESSION"

  # Client
  tmux new-session -d -s "$SESSION" -n client -c "$BASE_DIR/client"
  tmux send-keys -t "$SESSION:client" 'exec ./node_modules/ember-cli/bin/ember serve' C-m

  # Trinity
  tmux new-window -t "$SESSION" -n trinity -c "$BASE_DIR/trinity"
  tmux send-keys -t "$SESSION:trinity" 'exec yarn run ember serve --watcher=polling --polling-interval=1000' C-m

  # Phoenix
  tmux new-window -t "$SESSION" -n phoenix -c "$BASE_DIR/phoenix"
  
  # only one of them works due to port conflict, you can switch between them by commenting/uncommenting
  # Phoenix - Bizmu
  tmux send-keys -t "$SESSION:phoenix" 'exec env PROJECT_TARGET=phoenix ./node_modules/ember-cli/bin/ember serve' C-m
  # Phoenix - Companion
  #tmux send-keys -t "$SESSION:phoenix.1" 'exec env PROJECT_TARGET=companion ./node_modules/ember-cli/bin/ember serve' C-m
  
  # Server
  tmux new-window -t "$SESSION" -n server -c "$BASE_DIR/server"
  tmux send-keys -t "$SESSION:server" 'exec bundle exec puma -C config/puma.rb' C-m

  tmux split-window -v -t "$SESSION:server" -c "$BASE_DIR/server"
  tmux send-keys -t "$SESSION:server.1" 'exec bundle exec sidekiq -C config/sidekiq.yml' C-m
  tmux select-layout -t "$SESSION:server" even-vertical

  # Billing
  tmux new-window -t "$SESSION" -n billing -c "$BASE_DIR/billing"
  tmux send-keys -t "$SESSION:billing" 'exec rails server -p 4002' C-m

  tmux split-window -v -t "$SESSION:billing" -c "$BASE_DIR/billing"
  tmux send-keys -t "$SESSION:billing.1" 'exec bundle exec sidekiq -C config/sidekiq.yml' C-m
  tmux select-layout -t "$SESSION:billing" even-vertical

  # E-doc-broker
  tmux new-window -t "$SESSION" -n edoc -c "$BASE_DIR/e-doc-broker"
  tmux send-keys -t "$SESSION:edoc" 'exec rails s -p 5002' C-m

  tmux split-window -v -t "$SESSION:edoc" -c "$BASE_DIR/e-doc-broker"
  tmux send-keys -t "$SESSION:edoc.1" 'exec foreman start --formation ",sidekiq_inbound=1,sidekiq_outbound=1,sidekiq_storage=1,sidekiq_other=1,sidekiq_send=1"' C-m
  tmux select-layout -t "$SESSION:edoc" even-vertical

  # Optional shell window
  # tmux new-window -t "$SESSION" -n shell -c "$BASE_DIR"
else
  log "Session already exists: $SESSION"
fi

tmux select-window -t "$SESSION:client"
exec tmux attach-session -t "$SESSION"