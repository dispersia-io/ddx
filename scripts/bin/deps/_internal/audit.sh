#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, SILENT_MODE, PACKAGE_MANAGER_AUDIT_CMD, USER_ROOT_DIR

log -ic "🛡️ " -m "Running $PACKAGE_MANAGER audit...\n"

if ((SILENT_MODE)); then
  (cd "$USER_ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD > /dev/null 2>&1)
else
  (cd "$USER_ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD)
  log -m "\n"
fi
