#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: DEPS_INTERNAL_DIR, DEPENDABOT_FILE, PACKAGE_INFO, SILENT_MODE

source "$DEPS_INTERNAL_DIR/search-unstable.sh"

log -ic "⏳" -m "Updating $DEPENDABOT_FILE..." -in -sl "$SILENT_MODE"

PACKAGES_ONLY=$(echo "$PACKAGE_INFO" | awk '{print $1}')
export PACKAGES_ENV="$PACKAGES_ONLY"

NODE_RESULT=$(DEPENDABOT_FILE="$DEPENDABOT_FILE" SILENT_MODE="$SILENT_MODE" node "$DEPS_INTERNAL_DIR/update-dependabot.js" 2>&1)

if [ $? -eq 0 ]; then
  if [[ "$NODE_RESULT" == *"UPDATED"* ]]; then
    log -cl -s -m "Package update exceptions written to $DEPENDABOT_FILE" -sl "$SILENT_MODE"
    emit_meta "__UPDATED__"
  else
    log -cl -i -ic "⏩" -m "The $DEPENDABOT_FILE file has not been modified" -sl "$SILENT_MODE"
    emit_meta "__SKIPPED__"
  fi
else
  log -cl -e -m "Error: $NODE_RESULT" -sl "$SILENT_MODE"
  exit 1
fi
