#!/bin/bash

# Executes a subtask with formatted output.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Options:
#   --cmd, -c             : [Required] Command string to execute
#   --icon, -i            : [Optional] Icon for the task
#   --subject, -s         : [Optional] Subject of the action
#   --template, -t        : [Optional] Predefined action template (Mode 1)
#   --name, -n            : [Optional] Custom name for the task (Mode 2 & 3)
#   --success-msg, -sm    : [Optional] Custom success text (Mode 2 & 3)
#   --error-msg, -em      : [Optional] Custom error text (Mode 2 & 3)
#   --level, -l           : [Optional] Logging indentation level (defaults to 2)
#   --silent, -sl         : [Optional] Suppresses all logs (0/1 or false/true)
#
# Available Templates (--template):
#   install, update, pin, build, generate, verify, remove,
#   start, stop, restart, deploy, sync, test, lint, format,
#   publish, download, upload
#
# Usage Variants:
#
# 1. Template Mode:
#    Requires: --subject, --template, --cmd
#    Example: run_subtask -i "🌈" -s "Prisma Client" -t "generate" -c "$GENERATE_CMD"
#
# 2. Custom WITHOUT Subject:
#    Requires: --name, --cmd
#    Example: run_subtask -n "Pushing image" -c "docker push"
#
# 3. Custom WITH Subject:
#    Requires: --subject, --name, --cmd
#    Example: run_subtask -s "Cache files" -n "Cleaning" -c "rm -rf"

TASKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TASKS_DIR/.."
UTILS_DIR="$BIN_DIR/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/options.sh"

run_subtask() {
  local command name subject template icon success_msg error_msg level silent
  local pending_msg=""

  local OPTIONS_CONFIG="
    command      | --cmd         | -c   | required | string | 
    name         | --name        | -n   | optional | string | 
    subject      | --subject     | -s   | optional | string | 
    template     | --template    | -t   | optional | string | 
    icon         | --icon        | -i   | optional | string | 
    success_msg  | --success-msg | -sm  | optional | string | 
    error_msg    | --error-msg   | -em  | optional | string | 
    level        | --level       | -l   | optional | int    | 2
    silent       | --silent      | -sl  | optional | string | false
  "

  eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

  if [[ -n "$template" ]]; then
    if [[ -z "$subject" ]]; then
      log -cl -e -l "$level" -c "gray" -m "Error: Template mode requires --subject" -sl "$silent"
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
        log -cl -e -l "$level" -c "gray" -m "Error: Unknown subtask template '$template'" -sl "$silent"
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
    log -cl -e -l "$level" -c "gray" -m "Error: Invalid flag combination. Provide either --template AND --subject, OR custom --name." -sl "$silent"
    exit 1
  fi

  local icon_args=()
  if [[ -n "$icon" ]]; then
    icon_args=("-ic" "$icon")
  fi

  log -l "$level" "${icon_args[@]}" -m "$pending_msg..." -in -sl "$silent"

  if OUT=$(eval "$command" 2>&1); then
    log -cl -s -l "$level" "${icon_args[@]}" -m "$success_msg" -sl "$silent"
  else
    log -cl -e -l "$level" "${icon_args[@]}" -m "$error_msg" -sl "$silent"

    local silent=$(echo "$SILENT_MODE" | tr '[:upper:]' '[:lower:]')
    if [[ "$silent" != "1" && "$silent" != "true" ]]; then
      printf "\n%s\n\n" "$OUT"
    fi
    exit 1
  fi
}
