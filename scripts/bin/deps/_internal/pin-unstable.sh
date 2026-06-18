#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: DEPS_INTERNAL_DIR, DEPENDABOT_FILE, PACKAGE_INFO, IS_SILENT

source "$DEPS_INTERNAL_DIR/search-unstable.sh"

log -ic "$ICON_PROGRESS" -m "Updating $DEPENDABOT_FILE..." -in -slm "$IS_SILENT"

PACKAGES_ONLY=$(echo "$PACKAGE_INFO" | awk '{print $1}')
export PACKAGES_ENV="$PACKAGES_ONLY"

NODE_RESULT=$(DEPENDABOT_FILE="$DEPENDABOT_FILE" IS_SILENT="$IS_SILENT" node "$DEPS_INTERNAL_DIR/update-dependabot.js" 2>&1)

if [ $? -eq 0 ]; then
  if [[ "$NODE_RESULT" == *"UPDATED"* ]]; then
    log -cl -s -m "Package update exceptions written to $DEPENDABOT_FILE" -slm "$IS_SILENT"
    emit_meta "__UPDATED__"
  else
    log -cl -i -ic "$ICON_SKIP" -m "The $DEPENDABOT_FILE file has not been modified" -slm "$IS_SILENT"
    emit_meta "__SKIPPED__"
  fi
else
  log -cl -e -m "Error: $NODE_RESULT" -slm "$IS_SILENT"
  exit 1
fi
