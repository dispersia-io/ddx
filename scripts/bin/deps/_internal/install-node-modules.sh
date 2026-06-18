#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, ROOT_DIR, IS_SILENT

execute subtask \
  --icon "$ICON_PACKAGE" \
  --subject "node modules" \
  --template "install" \
  --cmd "cd \"$ROOT_DIR\" && $PACKAGE_MANAGER install" \
  --silent-mode "$IS_SILENT"
