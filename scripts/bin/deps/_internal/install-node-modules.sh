#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, USER_ROOT_DIR

execute subtask \
  --icon "📦" \
  --subject "node modules" \
  --template "install" \
  --cmd "cd \"$USER_ROOT_DIR\" && $PACKAGE_MANAGER install"
