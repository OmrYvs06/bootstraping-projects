# Project Improvement Advice (Top 10)

1. Create a single source of truth for project names/directories to avoid duplication between setup/start scripts.
2. Improve `start.sh` behavior when tmux session already exists (for example add `--restart` or `--add-window`).
3. Make `stop.sh` process cleanup safer by targeting only PIDs from tmux session `parasutcom` instead of broad `pkill -f` patterns.
4. Standardize project-root path logic across `start.sh` and `start-all-tmux-legacy.sh` to prevent confusion.
5. Add safety checks and optional dry-run mode before destructive cleanup commands (`rm -rf`).
6. Add backup/dry-run support before editing shell rc files and `/etc/hosts`.
7. Refactor repeated `asdf` setup steps into reusable helper functions.
8. Make `arch -x86_64` usage conditional based on machine architecture.
9. Add full dependency preflight checks (`git`, `asdf`, `tmux`, etc.) before executing setup/start flows.
10. Keep docs in sync automatically (generate command docs from script definitions to avoid stale markdown files).
