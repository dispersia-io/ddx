#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PIN_UNSTABLE, ROOT_DIR, IS_SILENT

DEPENDABOT_FILE=""

if [ -f "$ROOT_DIR/.github/dependabot.yml" ]; then
  DEPENDABOT_FILE="$ROOT_DIR/.github/dependabot.yml"
elif [ -f "$ROOT_DIR/.github/dependabot.yaml" ]; then
  DEPENDABOT_FILE="$ROOT_DIR/.github/dependabot.yaml"
elif ((PIN_UNSTABLE)); then
  log -cl -e -m "Error: Dependabot configuration not found." -slm "$IS_SILENT"
  exit 1
fi
