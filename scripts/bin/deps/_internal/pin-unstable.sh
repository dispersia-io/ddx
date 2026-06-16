#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: INTERNAL_DIR, DEPENDABOT_FILE, PACKAGE_INFO

source "$INTERNAL_DIR/search-unstable.sh"

log -c "⏳" -m "Updating $DEPENDABOT_FILE..." -in

PACKAGES_ONLY=$(echo "$PACKAGE_INFO" | awk '{print $1}')
export PACKAGES_ENV="$PACKAGES_ONLY"

NODE_RESULT=$(DEPENDABOT_FILE="$DEPENDABOT_FILE" node ./scripts/bin/deps/_internal/update-dependabot.js 2>&1)

if [ $? -eq 0 ]; then
  if [[ "$NODE_RESULT" == *"UPDATED"* ]]; then
    log -cl -s -m "Package update exceptions written to $DEPENDABOT_FILE"
    emit_meta "__UPDATED__"
  else
    log -cl -i -ic "⏩" -m "The $DEPENDABOT_FILE file has not been modified"
    emit_meta "__SKIPPED__"
  fi
else
  log -cl -e -m "Error: $NODE_RESULT"
  exit 1
fi
