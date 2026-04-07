#!/usr/bin/env bash

# this script is the main entry point to start selected projects in a tmux session
# it uses lib/tmux.sh for tmux related functions and lib/common.sh for common utilities

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/tmux.sh"

print_centered_title "STARTING TMUX PROJECTS"
print_info "Script directory: $SCRIPT_DIR"
print_info "Project directory: $PROJECT_DIR"
print_info "Preparing tmux session..."

tmux_require_dependency
tmux_resolve_requested_projects "$@"
tmux_check_required_directories "${REQUESTED_PROJECTS[@]}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  print_info "Session already exists: $SESSION"
else
  print_info "Creating tmux session: $SESSION"

  for project in "${REQUESTED_PROJECTS[@]}"; do
    print_info "Starting $project..."
    tmux_run_project "$project"
    print_done "$project started."
  done
fi

tmux_select_first_window "${REQUESTED_PROJECTS[0]}"
exec tmux attach-session -t "$SESSION"