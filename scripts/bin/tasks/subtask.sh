#!/usr/bin/env bash

# Executes a subtask with formatted output.
#
# Options:
#   * -c, --cmd              : Command string to execute
#     -i, --icon             : Icon for the task
#     -n, --name             : Custom name for the task
#     -s, --subject          : Subject of the action
#     -t, --template         : Predefined action template
#     -sm, --success-msg     : Custom success text
#     -em, --error-msg       : Custom error text
#     -ll, --log-level       : Logging indentation level (Default: 2)
#     -slm, --silent-mode    : Suppresses all logs (Default: disabled)
#
# Available Templates (-t, --template):
#   install, update, pin, build, generate, verify, remove,
#   start, stop, restart, deploy, sync, test, lint, format,
#   publish, download, upload
#
# Usage:
#   ddx exec subtask -c <string> [options]
#
# Examples:
#   ddx exec subtask -n "Install deps" -c "yarn install"
#   ddx exec subtask -n "Installing" -s "Node modules" -c "yarn install"
#   ddx exec subtask -t "install" -s "Node modules" -c "yarn install"

[[ -n "$__IS_TASKS_SUBTASK_SH_INCLUDED" ]] && return 0
__IS_TASKS_SUBTASK_SH_INCLUDED=1

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

run_subtask() {
  local command name subject template icon success_msg error_msg log_level silent_mode
  local pending_msg=""

  local OPTIONS_CONFIG="
    command     | --cmd         | -c    | required | string |          | Command string to execute
    name        | --name        | -n    | optional | string |          | Custom name for the task
    subject     | --subject     | -s    | optional | string |          | Subject of the action
    template    | --template    | -t    | optional | string |          | Predefined action template
    icon        | --icon        | -i    | optional | string |          | Icon for the task
    success_msg | --success-msg | -sm   | optional | string |          | Custom success text
    error_msg   | --error-msg   | -em   | optional | string |          | Custom error text
    log_level   | --log-level   | -ll   | optional | int    | 2        | Logging indentation level
    silent_mode | --silent-mode | -slm  | optional | toggle | disabled | Suppresses all logs
  "

  intercept_help \
    --name "ddx exec subtask" \
    --description "Executes a subtask with formatted output" \
    --usage "ddx exec subtask -c <string> [options]" \
    --options "$OPTIONS_CONFIG" \
    -- "$@"

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  if [[ -n "$template" ]]; then
    if [[ -z "$subject" ]]; then
      log -cl -e -c "gray" -m "Error: Template mode requires --subject" -ll "$log_level" -slm "$silent_mode"
      exit 1
    fi

    local template_data=""

    # Format: "Pending message|Success message|Failed message"
    case "$template" in
      # Dependencies & Environment
      install) template_data="Installing|Installed|Failed to install" ;;
      update) template_data="Updating|Updated|Failed to update" ;;
      pin) template_data="Pinning|Pinned|Failed to pin" ;;
      # Artifacts
      build) template_data="Building|Built|Failed to build" ;;
      generate) template_data="Generating|Generated|Failed to generate" ;;
      publish) template_data="Publishing|Published|Failed to publish" ;;
      # Validation
      verify) template_data="Verifying|Verified|Failed to verify" ;;
      test) template_data="Testing|Tested|Failed to test" ;;
      lint) template_data="Linting|Linted|Failed to lint" ;;
      format) template_data="Formatting|Formatted|Failed to format" ;;
      # Process & Deploy
      start) template_data="Starting|Started|Failed to start" ;;
      stop) template_data="Stopping|Stopped|Failed to stop" ;;
      restart) template_data="Restarting|Restarted|Failed to restart" ;;
      deploy) template_data="Deploying|Deployed|Failed to deploy" ;;
      # Data & Network
      sync) template_data="Syncing|Synced|Failed to sync" ;;
      download) template_data="Downloading|Downloaded|Failed to download" ;;
      upload) template_data="Uploading|Uploaded|Failed to upload" ;;
      # Cleanup
      remove) template_data="Removing|Removed|Failed to remove" ;;
      delete) template_data="Deleting|Deleted|Failed to delete" ;;
      cleanup) template_data="Cleaning up|Cleaned up|Failed to cleanup" ;;
      *)
        log -cl -e -c "gray" -m "Error: Unknown subtask template '$template'" -ll "$log_level" -slm "$silent_mode"
        exit 1
        ;;
    esac

    IFS='|' read -r name success_msg error_msg <<< "$template_data"

    pending_msg="$name: $subject"
    success_msg="$success_msg: $subject"
    error_msg="$error_msg: $subject"

  elif [[ -n "$name" ]]; then
    success_msg="${success_msg:-$name completed successfully}"
    error_msg="${error_msg:-$name encountered an error}"

    if [[ -n "$subject" ]]; then
      pending_msg="$name: $subject"
      success_msg="$success_msg: $subject"
      error_msg="$error_msg: $subject"
    else
      pending_msg="$name"
    fi
  else
    log -cl -e -c "gray" -m "Error: Invalid flag combination. Provide either --template AND --subject, OR custom --name" -ll "$log_level" -slm "$silent_mode"
    exit 1
  fi

  local icon_args=()
  if [[ -n "$icon" ]]; then
    icon_args=("-ic" "$icon")
  fi

  log "${icon_args[@]}" -m "$pending_msg..." -in -ll "$log_level" -slm "$silent_mode"

  if OUT=$(eval "$command" 2>&1); then
    log -cl -s "${icon_args[@]}" -m "$success_msg" -ll "$log_level" -slm "$silent_mode"
  else
    log -cl -e "${icon_args[@]}" -m "$error_msg" -ll "$log_level" -slm "$silent_mode"

    if ! is_enabled "$silent_mode"; then
      printf "\n%s\n\n" "$OUT"
    fi
    exit 1
  fi
}
