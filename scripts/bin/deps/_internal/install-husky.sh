#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER_RUNNER

HUSKY_VERSION_STR=$(node -p "const p=require('./package.json'); p.devDependencies?.husky || p.dependencies?.husky || ''" 2> /dev/null)

if [ -n "$HUSKY_VERSION_STR" ]; then
  if [[ "$HUSKY_VERSION_STR" == *"latest"* || "$HUSKY_VERSION_STR" == *"next"* ]]; then
    HUSKY_MAJOR_VERSION=9
  else
    HUSKY_MAJOR_VERSION=$(echo "$HUSKY_VERSION_STR" | grep -oE '[0-9]+' | head -n 1)
  fi

  if [[ "$HUSKY_MAJOR_VERSION" =~ ^[0-9]+$ ]] && [ "$HUSKY_MAJOR_VERSION" -ge 9 ]; then
    HUSKY_CMD="$PACKAGE_MANAGER_RUNNER husky"
  else
    HUSKY_CMD="$PACKAGE_MANAGER_RUNNER husky install && chmod +x ./.husky/*"
  fi

  execute subtask \
    --icon "🐶" \
    --subject "Husky" \
    --template "install" \
    --cmd "$HUSKY_CMD"
fi
