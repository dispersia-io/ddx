#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PIN_UNSTABLE, SILENT_MODE, USER_ROOT_DIR

DEPENDABOT_FILE=""

if [ -f "$USER_ROOT_DIR/.github/dependabot.yml" ]; then
  DEPENDABOT_FILE="$USER_ROOT_DIR/.github/dependabot.yml"
elif [ -f "$USER_ROOT_DIR/.github/dependabot.yaml" ]; then
  DEPENDABOT_FILE="$USER_ROOT_DIR/.github/dependabot.yaml"
elif ((PIN_UNSTABLE)); then
  if ((!SILENT_MODE)); then
    log -cl -e -m "Error: Dependabot configuration not found."
  fi
  exit 1
fi
