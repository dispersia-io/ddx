#!/usr/bin/env bash

# Executes a high-level task with content passed as a command string.
#
# Options:
#   * -n, --name             : Name of the task
#   * -c, --cmd              : Command string to execute
#     -i, --icon             : Icon for the task
#     -sm, --success-msg     : Message to display on success (Default: auto-generated)
#     -em, --error-msg       : Message to display on error (Default: auto-generated)
#     -ll, --log-level       : Logging indentation level (Default: 1)
#     -slm, --silent-mode    : Suppresses all logs (Default: "disabled")
#
# Usage:
#   ddx exec task -n <string> -c <string> [options]
#
# Examples:
#   ddx exec task -n "Push image" -c "docker push"

[[ -n "$__IS_TASKS_TASK_SH_INCLUDED" ]] && return 0
__IS_TASKS_TASK_SH_INCLUDED=1

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

run_task() {
  local task_name icon success_msg error_msg command log_level silent_mode

  local OPTIONS_CONFIG="
    task_name   | --name        | -n    | required | string |          | Name of the task
    command     | --cmd         | -c    | required | string |          | Command string to execute
    icon        | --icon        | -i    | optional | string |          | Icon for the task
    success_msg | --success-msg | -sm   | optional | string |          | Message to display on success
    error_msg   | --error-msg   | -em   | optional | string |          | Message to display on error
    log_level   | --log-level   | -ll   | optional | int    | 1        | Logging indentation level
    silent_mode | --silent-mode | -slm  | optional | toggle | disabled | Suppresses all logs
  "

  intercept_help \
    --name "ddx exec task" \
    --description "Executes a high-level task with content passed as a command string" \
    --usage "ddx exec task -n <string> -c <string> [options]" \
    --options "$OPTIONS_CONFIG" \
    -- "$@"

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  success_msg="${success_msg:-Task \"$task_name\" completed successfully}"
  error_msg="${error_msg:-Task \"$task_name\" encountered an error}"

  if [[ -n "$icon" ]]; then
    log -ic "$icon" -m "$task_name\n" -ll "$log_level" -slm "$silent_mode"
  else
    log -m "$task_name\n" -ll "$log_level" -slm "$silent_mode"
  fi

  if eval "$command"; then
    if ! is_enabled "$silent_mode"; then
      echo ""
      log -s -ic "$ICON_DONE" -m "$success_msg" -ll "$log_level"
    fi
    return 0
  else
    if ! is_enabled "$silent_mode"; then
      echo ""
      log -e -ic "$ICON_FAIL" -m "$error_msg" -ll "$log_level"
    fi
    return 1
  fi
}
