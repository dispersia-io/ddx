#!/bin/bash

# Executes a high-level task with content passed as a command string using flags.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Flags:
#   --name, -n            : [Required] Name of the task
#   --cmd, -c             : [Required] Command string to execute
#   --icon, -i            : [Optional] Icon for the task
#   --success-msg, -sm    : [Optional] Message to display on success (defaults to generic message)
#   --error-msg, -em      : [Optional] Message to display on error (defaults to generic message)
#   --level, -l           : [Optional] Logging indentation level (defaults to 1)

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."
UTILS_DIR="$BIN_DIR/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/options.sh"

run_task() {
  local task_name icon success_msg error_msg command level

  local OPTIONS_CONFIG="
    task_name    | --name        | -n   | required | string | 
    command      | --cmd         | -c   | required | string | 
    icon         | --icon        | -i   | optional | string | 
    success_msg  | --success-msg | -sm  | optional | string | 
    error_msg    | --error-msg   | -em  | optional | string | 
    level        | --level       | -l   | optional | int    | 1
  "

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  success_msg="${success_msg:-Task '$task_name' completed successfully.}"
  error_msg="${error_msg:-Task '$task_name' encountered an error.}"

  if [[ -n "$icon" ]]; then
    log -l "$level" -ic "$icon" -m "$task_name\n"
  else
    log -l "$level" -m "$task_name\n"
  fi

  if eval "$command"; then
    echo ""
    log -s -l "$level" -ic "✨" -m "$success_msg"
    return 0
  else
    echo ""
    log -e -l "$level" -m "$error_msg"
    return 1
  fi
}
