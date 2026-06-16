#!/bin/bash

# Acts as a central router to unify command execution between tasks and granular subtasks.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Flags:
#   --task       : Dispatches the command to the 'run_task' executor.
#   --subtask    : Dispatches the command to the 'run_subtask' executor.
#
# Usage:
# execute [--task | --subtask] [flags...] "<command>"

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$TASKS_DIR/task.sh"
source "$TASKS_DIR/subtask.sh"
source "$BIN_DIR/utils/log.sh"

execute() {
  local is_task=false
  local is_subtask=false
  local delegated_args=()

  for arg in "$@"; do
    case "$arg" in
      --task) is_task=true ;;
      --subtask) is_subtask=true ;;
      *) delegated_args+=("$arg") ;;
    esac
  done

  if [ "$is_task" = true ] && [ "$is_subtask" = true ]; then
    log -e -c "gray" -m "Error: Flags --task and --subtask cannot be used simultaneously."
    exit 1
  fi

  local last_idx=$((${#delegated_args[@]} - 1))
  local command="${delegated_args[$last_idx]}"

  if [ "$is_task" = true ]; then
    run_task "${delegated_args[@]}"
  elif [ "$is_subtask" = true ]; then
    run_subtask "${delegated_args[@]}"
  else
    eval "$command"
  fi
}
