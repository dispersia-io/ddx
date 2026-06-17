#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, ROOT_DIR, SILENT_MODE

execute subtask \
  --icon "📦" \
  --subject "node modules" \
  --template "install" \
  --cmd "cd \"$ROOT_DIR\" && $PACKAGE_MANAGER install" \
  --silent "$SILENT_MODE"
