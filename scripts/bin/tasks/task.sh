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

source "$BIN_DIR/utils/log.sh"

run_task() {
  local icon=""
  local task_name=""
  local success_msg=""
  local error_msg=""
  local command=""
  local level="1"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --icon | -i)
        icon="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --name | -n)
        task_name="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --success-msg | -sm)
        success_msg="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --error-msg | -em)
        error_msg="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --cmd | -c)
        command="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --level | -l)
        level="${2:-1}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --task)
        shift 1
        ;;
      *)
        log -w -l "$level" -c "gray" -m "Warning: Unknown argument passed to run_task: $1"
        return 1
        ;;
    esac
  done

  if [[ ! "$level" =~ ^[1-9][0-9]*$ ]]; then
    log -e -l 1 -c "gray" -m "Error: --level must be a positive integer greater than or equal to 1"
    return 1
  fi

  if [[ -z "$task_name" || -z "$command" ]]; then
    log -e -l "$level" -c "gray" -m "Error: run_task strictly requires --name and --cmd flags"
    return 1
  fi

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
