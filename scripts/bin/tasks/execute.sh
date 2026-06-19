#!/bin/bash

# Acts as a central router to unify command execution between tasks and granular subtasks.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Subcommands:
#   task       : [Optional] Dispatches the command to the 'run_task' executor.
#   subtask    : [Optional] Dispatches the command to the 'run_subtask' executor.
#
# Usage:
# execute [task | subtask] [options...]

[[ -n "$__IS_TASKS_EXECUTE_SH_INCLUDED" ]] && return 0
__IS_TASKS_EXECUTE_SH_INCLUDED=1

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$BIN_DIR/cli/help.sh"

source "$TASKS_DIR/task.sh"
source "$TASKS_DIR/subtask.sh"

execute() {
  intercept_help \
    --name "execute" \
    --description "Acts as a central router to unify command execution between tasks and granular subtasks." \
    --usage "execute [task | subtask] [options...]" \
    -- "$@"

  local target="$1"
  shift

  case "$target" in
    task) run_task "$@" ;;
    subtask) run_subtask "$@" ;;
    *) eval "$target" "$@" ;;
  esac
}
