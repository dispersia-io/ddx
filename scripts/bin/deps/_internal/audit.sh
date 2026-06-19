#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, PACKAGE_MANAGER_AUDIT_CMD, ROOT_DIR, IS_SILENT

if is_enabled "$IS_SILENT"; then
  (cd "$ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD > /dev/null 2>&1)
else
  log -ic "$ICON_SECURE" -m "Running $PACKAGE_MANAGER audit...\n"
  (cd "$ROOT_DIR" && $PACKAGE_MANAGER_AUDIT_CMD)
  log -m "\n"
fi
