#!/bin/bash

# Executes a high-level task with content passed as a command string.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Options:
#   --name, -n            : [Required] Name of the task
#   --cmd, -c             : [Required] Command string to execute
#   --icon, -i            : [Optional] Icon for the task
#   --success-msg, -sm    : [Optional] Message to display on success (defaults to generic message)
#   --error-msg, -em      : [Optional] Message to display on error (defaults to generic message)
#   --level, -l           : [Optional] Logging indentation level (defaults to 1)
#   --silent, -sl         : [Optional] Suppresses all logs (0/1 or false/true)

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."
UTILS_DIR="$BIN_DIR/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/options.sh"

run_task() {
  local task_name icon success_msg error_msg command level silent

  local OPTIONS_CONFIG="
    task_name   | --name        | -n   | required | string | 
    command     | --cmd         | -c   | required | string | 
    icon        | --icon        | -i   | optional | string | 
    success_msg | --success-msg | -sm  | optional | string | 
    error_msg   | --error-msg   | -em  | optional | string | 
    level       | --level       | -l   | optional | int    | 1
    silent_mode | --silent      | -sl  | optional | string | false
  "

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  success_msg="${success_msg:-Task '$task_name' completed successfully.}"
  error_msg="${error_msg:-Task '$task_name' encountered an error.}"

  local silent=$(echo "$silent_mode" | tr '[:upper:]' '[:lower:]')

  if [[ -n "$icon" ]]; then
    log -l "$level" -ic "$icon" -m "$task_name\n" -sl "$silent_mode"
  else
    log -l "$level" -m "$task_name\n" -sl "$silent_mode"
  fi

  if eval "$command"; then
    if [[ "$silent" != "1" && "$silent" != "true" ]]; then
      echo ""
      log -s -l "$level" -ic "✨" -m "$success_msg"
    fi
    return 0
  else
    if [[ "$silent" != "1" && "$silent" != "true" ]]; then
      echo ""
      log -e -l "$level" -m "$error_msg"
    fi
    return 1
  fi
}
