#!/usr/bin/env bash

# how to: 
# 1. go to your project folder
# 2. call this script
# 3. you are done

# this script starts the repos in current folder and set tmux settings

# examples:
# $ bash ./bootstraping-projects/start_all_tmux.sh
# $ bash ~/parasutcom/bootstraping-projects/start_all_tmux.sh

# omeryavas@Omers-MacBook-Pro ~/parasutcom % bash ./bootstraping-projects/start_all_tmux.sh
# |
# |--> this starts all repos in "~/parasutcom" folder


BASE_DIR="./" # its current directory
SESSION="parasutcom"

exit_var=0

for dir in client trinity server billing e-doc-broker; do
  if [ ! -d "$BASE_DIR/$dir" ]; then
    print "$dir directory is missing."
    exit_var=1
  fi
done

if [ "$exit_var" -ne 0 ]; then
  print "Stopping the program because required directories are missing."
  exit "$exit_var"
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Frontend
  tmux new-session -d -s "$SESSION" -n frontend -c "$BASE_DIR/client"
  tmux send-keys -t "$SESSION:frontend" 'exec ./node_modules/ember-cli/bin/ember serve' C-m
  tmux split-window -h -t "$SESSION:frontend" -c "$BASE_DIR/trinity"
  tmux send-keys -t "$SESSION:frontend.1" 'exec yarn run ember serve --watcher=polling --polling-interval=1000' C-m
  tmux select-layout -t "$SESSION:frontend" even-horizontal

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

  # Shell
  # tmux new-window -t "$SESSION" -n shell -c "$BASE_DIR"
fi

tmux attach-session -t "$SESSION"