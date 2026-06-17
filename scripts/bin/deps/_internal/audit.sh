#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, SILENT_MODE, PACKAGE_MANAGER_AUDIT_CMD, ROOT_DIR

silent=$(echo "$SILENT_MODE" | tr '[:upper:]' '[:lower:]')
if [[ "$silent" != "1" && "$silent" != "true" ]]; then
  log -ic "🛡️ " -m "Running $PACKAGE_MANAGER audit...\n"
  (cd "$ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD)
  log -m "\n"
else
  (cd "$ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD > /dev/null 2>&1)
fi
