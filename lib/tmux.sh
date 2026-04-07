#!/usr/bin/env bash

SESSION="parasutcom"

ALL_PROJECTS=(
  client
  trinity
  phoenix-bizmu
  phoenix-assist
  server
  billing
  e-doc-broker
)

DEFAULT_PROJECTS=(
  client
  trinity
  phoenix-bizmu
  server
  billing
  e-doc-broker
)

tmux_fail() {
  print_error "$1"
  exit 1
}

tmux_require_dependency() {
  command -v tmux >/dev/null 2>&1 || tmux_fail "tmux is not installed."
}

tmux_has_item() {
  local needle="$1"
  shift

  local item
  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done

  return 1
}

tmux_validate_project_name() {
  local project="$1"

  if ! tmux_has_item "$project" "${ALL_PROJECTS[@]}"; then
    tmux_fail "Unknown project: $project"
  fi
}

tmux_check_required_directories() {
  local project
  for project in "$@"; do
    case "$project" in
      phoenix-bizmu|phoenix-assist)
        if [ ! -d "$PROJECT_DIR/phoenix" ]; then
          tmux_fail "Directory is missing: $PROJECT_DIR/phoenix"
        fi
        ;;
      *)
        if [ ! -d "$PROJECT_DIR/$project" ]; then
          tmux_fail "Directory is missing: $PROJECT_DIR/$project"
        fi
        ;;
    esac
  done
}

tmux_validate_project_selection() {
  local has_bizmu=0
  local has_assist=0
  local project

  for project in "$@"; do
    if [ "$project" = "phoenix-bizmu" ]; then
      has_bizmu=1
    fi

    if [ "$project" = "phoenix-assist" ]; then
      has_assist=1
    fi
  done

  if [ "$has_bizmu" -eq 1 ] && [ "$has_assist" -eq 1 ]; then
    tmux_fail "phoenix-bizmu and phoenix-assist cannot run at the same time because they use the same port."
  fi
}

tmux_create_first_window() {
  local window_name="$1"
  local workdir="$2"
  local command="$3"

  tmux new-session -d -s "$SESSION" -n "$window_name" -c "$workdir"
  tmux send-keys -t "$SESSION:$window_name" "$command" C-m
}

tmux_create_window() {
  local window_name="$1"
  local workdir="$2"
  local command="$3"

  tmux new-window -t "$SESSION" -n "$window_name" -c "$workdir"
  tmux send-keys -t "$SESSION:$window_name" "$command" C-m
}

tmux_create_window_or_first() {
  local window_name="$1"
  local workdir="$2"
  local command="$3"

  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux_create_first_window "$window_name" "$workdir" "$command"
  else
    tmux_create_window "$window_name" "$workdir" "$command"
  fi
}

run_client() {
  local workdir="$PROJECT_DIR/client"
  tmux_create_window_or_first "client" "$workdir" 'exec ./node_modules/ember-cli/bin/ember serve'
}

run_trinity() {
  local workdir="$PROJECT_DIR/trinity"
  tmux_create_window_or_first "trinity" "$workdir" 'exec yarn run ember serve --watcher=polling --polling-interval=1000'
}

run_phoenix_bizmu() {
  local workdir="$PROJECT_DIR/phoenix"
  tmux_create_window_or_first "phoenix-bizmu" "$workdir" 'exec env PROJECT_TARGET=phoenix ./node_modules/ember-cli/bin/ember serve'
}

run_phoenix_assist() {
  local workdir="$PROJECT_DIR/phoenix"
  tmux_create_window_or_first "phoenix-assist" "$workdir" 'exec env PROJECT_TARGET=companion ./node_modules/ember-cli/bin/ember serve'
}

run_server() {
  local workdir="$PROJECT_DIR/server"

  tmux_create_window_or_first "server" "$workdir" 'exec bundle exec puma -C config/puma.rb'
  tmux split-window -v -t "$SESSION:server" -c "$workdir"
  tmux send-keys -t "$SESSION:server.1" 'exec bundle exec sidekiq -C config/sidekiq.yml' C-m
  tmux select-layout -t "$SESSION:server" even-vertical
}

run_billing() {
  local workdir="$PROJECT_DIR/billing"

  tmux_create_window_or_first "billing" "$workdir" 'exec rails server -p 4002'
  tmux split-window -v -t "$SESSION:billing" -c "$workdir"
  tmux send-keys -t "$SESSION:billing.1" 'exec bundle exec sidekiq -C config/sidekiq.yml' C-m
  tmux select-layout -t "$SESSION:billing" even-vertical
}

run_e_doc_broker() {
  local workdir="$PROJECT_DIR/e-doc-broker"

  tmux_create_window_or_first "edoc" "$workdir" 'exec rails s -p 5002'
  tmux split-window -v -t "$SESSION:edoc" -c "$workdir"
  tmux send-keys -t "$SESSION:edoc.1" 'exec foreman start --formation ",sidekiq_inbound=1,sidekiq_outbound=1,sidekiq_storage=1,sidekiq_other=1,sidekiq_send=1"' C-m
  tmux select-layout -t "$SESSION:edoc" even-vertical
}

tmux_run_project() {
  local project="$1"

  case "$project" in
    client)
      run_client
      ;;
    trinity)
      run_trinity
      ;;
    phoenix-bizmu)
      run_phoenix_bizmu
      ;;
    phoenix-assist)
      run_phoenix_assist
      ;;
    server)
      run_server
      ;;
    billing)
      run_billing
      ;;
    e-doc-broker)
      run_e_doc_broker
      ;;
    *)
      tmux_fail "Unsupported project: $project"
      ;;
  esac
}

tmux_resolve_requested_projects() {
  REQUESTED_PROJECTS=()

  if [ "$#" -eq 0 ]; then
    REQUESTED_PROJECTS=("${DEFAULT_PROJECTS[@]}")
  else
    local arg
    for arg in "$@"; do
      tmux_validate_project_name "$arg"
      REQUESTED_PROJECTS+=("$arg")
    done
  fi

  tmux_validate_project_selection "${REQUESTED_PROJECTS[@]}"
}

tmux_select_first_window() {
  local first_window="$1"

  if [ "$first_window" = "e-doc-broker" ]; then
    first_window="edoc"
  fi

  tmux select-window -t "$SESSION:$first_window"
}