#!/bin/bash

# Executes a high-level task with content passed as a command string.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Options:
#   --name, -n             : [Required] Name of the task
#   --cmd, -c              : [Required] Command string to execute
#   --icon, -i             : [Optional] Icon for the task
#   --success-msg, -sm     : [Optional] Message to display on success (defaults to generic message)
#   --error-msg, -em       : [Optional] Message to display on error (defaults to generic message)
#   --log-level, -ll       : [Optional] Logging indentation level (defaults to 1)
#   --silent-mode, -slm    : [Optional] Suppresses all logs (boolean-like value)

[[ -n "$__IS_TASKS_TASK_SH_INCLUDED" ]] && return 0
__IS_TASKS_TASK_SH_INCLUDED=1

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

run_task() {
  local task_name icon success_msg error_msg command log_level silent_mode

  local OPTIONS_CONFIG="
    task_name   | --name        | -n    | required | string     | 
    command     | --cmd         | -c    | required | string     | 
    icon        | --icon        | -i    | optional | string     | 
    success_msg | --success-msg | -sm   | optional | string     | 
    error_msg   | --error-msg   | -em   | optional | string     | 
    log_level   | --log-level   | -ll   | optional | int        | 1
    silent_mode | --silent-mode | -slm  | optional | flag_value | disabled
  "

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  success_msg="${success_msg:-Task '$task_name' completed successfully.}"
  error_msg="${error_msg:-Task '$task_name' encountered an error.}"

  if [[ -n "$icon" ]]; then
    log -ic "$icon" -m "$task_name\n" -ll "$log_level" -slm "$silent_mode"
  else
    log -m "$task_name\n" -ll "$log_level" -slm "$silent_mode"
  fi

  if eval "$command"; then
    if ! is_flag_on "$silent_mode"; then
      echo ""
      log -s -ic "$ICON_DONE" -m "$success_msg" -ll "$log_level"
    fi
    return 0
  else
    if ! is_flag_on "$silent_mode"; then
      echo ""
      log -e -m "$error_msg" -ll "$log_level"
    fi
    return 1
  fi
}
