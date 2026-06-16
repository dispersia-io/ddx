#!/bin/bash

# Executes a subtask with formatted output using flags.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Flags:
#   --cmd, -c               : (Required) Command string to execute
#   --icon, -i              : (Optional) Icon for the task
#   --subject, -s           : (Optional) Subject of the action
#   --template, -t          : (Optional) Predefined action template (Mode 1)
#   --name, -n              : (Optional) Custom name for the task (Mode 2 & 3)
#   --success-msg, -sm      : (Optional) Custom success text (Mode 2 & 3)
#   --error-msg, -em        : (Optional) Custom error text (Mode 2 & 3)
#   --level, -l             : (Optional) Logging indentation level (defaults to 2)
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

source "$BIN_DIR/utils/log.sh"

run_subtask() {
  local icon=""
  local command=""
  local subject=""
  local template=""
  local name=""
  local success_msg=""
  local error_msg=""
  local level="2"

  local pending_msg=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --icon | -i)
        icon="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --subject | -s)
        subject="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --template | -t)
        template="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --cmd | -c)
        command="${2:-}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --name | -n)
        name="${2:-}"
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
      --level | -l)
        level="${2:-2}"
        [[ $# -ge 2 ]] && shift 2 || shift 1
        ;;
      --subtask) shift 1 ;;
      *)
        log -cl -e -l 2 -c "gray" -m "Error: Unknown argument '$1' passed to run_subtask"
        exit 1
        ;;
    esac
  done

  if [[ ! "$level" =~ ^[1-9][0-9]*$ ]]; then
    log -cl -e -l 2 -c "gray" -m "Error: --level must be a positive integer greater than or equal to 1"
    exit 1
  fi

  if [[ -z "$command" ]]; then
    log -cl -e -l "$level" -c "gray" -m "Error: run_subtask requires at least --cmd"
    exit 1
  fi

  if [[ -n "$template" ]]; then
    if [[ -z "$subject" ]]; then
      log -cl -e -l "$level" -c "gray" -m "Error: Template mode requires --subject"
      exit 1
    fi

    local tpl_data=""

    # Format: "Pending Action|Success Action|Failed Action"
    case "$template" in
      # Dependencies & Environment
      install) tpl_data="Installing|Installed|Failed to install" ;;
      update) tpl_data="Updating|Updated|Failed to update" ;;
      pin) tpl_data="Pinning|Pinned|Failed to pin" ;;
      # Artifacts
      build) tpl_data="Building|Built|Failed to build" ;;
      generate) tpl_data="Generating|Generated|Failed to generate" ;;
      publish) tpl_data="Publishing|Published|Failed to publish" ;;
      # Validation
      verify) tpl_data="Verifying|Verified|Failed to verify" ;;
      test) tpl_data="Testing|Tested|Failed to test" ;;
      lint) tpl_data="Linting|Linted|Failed to lint" ;;
      format) tpl_data="Formatting|Formatted|Failed to format" ;;
      # Process & Deploy
      start) tpl_data="Starting|Started|Failed to start" ;;
      stop) tpl_data="Stopping|Stopped|Failed to stop" ;;
      restart) tpl_data="Restarting|Restarted|Failed to restart" ;;
      deploy) tpl_data="Deploying|Deployed|Failed to deploy" ;;
      # Data & Network
      sync) tpl_data="Syncing|Synced|Failed to sync" ;;
      download) tpl_data="Downloading|Downloaded|Failed to download" ;;
      upload) tpl_data="Uploading|Uploaded|Failed to upload" ;;
      # Cleanup
      remove) tpl_data="Removing|Removed|Failed to remove" ;;
      delete) tpl_data="Deleting|Deleted|Failed to delete" ;;
      cleanup) tpl_data="Cleaning up|Cleaned up|Failed to cleanup" ;;
      *)
        log -cl -e -l "$level" -c "gray" -m "Error: Unknown subtask template '$template'"
        exit 1
        ;;
    esac

    IFS='|' read -r name success_msg error_msg <<< "$tpl_data"

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
    log -cl -e -l "$level" -c "gray" -m "Error: Invalid flag combination. Provide either --template AND --subject, OR custom --name."
    exit 1
  fi

  local icon_args=()
  if [[ -n "$icon" ]]; then
    icon_args=("-ic" "$icon")
  fi

  log -l "$level" "${icon_args[@]}" -m "$pending_msg..." -in

  if OUT=$(eval "$command" 2>&1); then
    log -cl -s -l "$level" "${icon_args[@]}" -m "$success_msg"
  else
    log -cl -e -l "$level" "${icon_args[@]}" -m "$error_msg"
    printf "\n%s\n\n" "$OUT"
    exit 1
  fi
}
