#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: EXEC_FLAG, PACKAGE_MANAGER

execute "${EXEC_FLAG[@]}" \
  --icon "📦" \
  --subject "node modules" \
  --template "install" \
  --cmd "$PACKAGE_MANAGER install"
