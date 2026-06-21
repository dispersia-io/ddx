#!/usr/bin/env bash

# Acts as a central router to unify command execution between tasks and granular subtasks.
#
# Subcommands:
#   task       : Dispatches the command to the 'run_task' executor
#   subtask    : Dispatches the command to the 'run_subtask' executor
#
# Usage:
#   ddx exec <subcommand> [options]
#
# Alternative (Direct execution):
#   ./scripts/bin/tasks/execute.sh <subcommand> [subcommand-options]
#
# Examples:
#   ddx exec task -n "Push image" -c "docker push"
#   ddx exec subtask -n "Install deps" -c "yarn install"

[[ -n "$__IS_TASKS_EXECUTE_SH_INCLUDED" ]] && return 0
__IS_TASKS_EXECUTE_SH_INCLUDED=1

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$BIN_DIR/cli/help.sh"

source "$TASKS_DIR/task.sh"
source "$TASKS_DIR/subtask.sh"

execute() {
  intercept_help \
    --name "exec" \
    --description "Acts as a central router to unify command execution between tasks and granular subtasks" \
    --usage "ddx exec <subcommand> [options]" \
    -- "$@"

  local target="$1"
  shift

  case "$target" in
    task) run_task "$@" ;;
    subtask) run_subtask "$@" ;;
    *) eval "$target" "$@" ;;
  esac
}
