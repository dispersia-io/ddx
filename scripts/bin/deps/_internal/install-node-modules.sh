#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER

execute subtask \
  --icon "📦" \
  --subject "node modules" \
  --template "install" \
  --cmd "$PACKAGE_MANAGER install"
