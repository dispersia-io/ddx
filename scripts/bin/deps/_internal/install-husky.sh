#!/usr/bin/env bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER_RUNNER, ROOT_DIR, IS_SILENT

HUSKY_VERSION_STR=$(node -p "
  try {
    const p = require('${ROOT_DIR}/package.json');
    p.devDependencies?.husky || p.dependencies?.husky || '';
  } catch {}
" 2> /dev/null)

if [ -n "$HUSKY_VERSION_STR" ]; then
  if [[ "$HUSKY_VERSION_STR" == *"latest"* || "$HUSKY_VERSION_STR" == *"next"* ]]; then
    HUSKY_MAJOR_VERSION=9
  else
    HUSKY_MAJOR_VERSION=$(echo "$HUSKY_VERSION_STR" | grep -oE '[0-9]+' | head -n 1)
  fi

  if [[ "$HUSKY_MAJOR_VERSION" =~ ^[0-9]+$ ]] && [ "$HUSKY_MAJOR_VERSION" -ge 9 ]; then
    HUSKY_CMD="CI=1 $PACKAGE_MANAGER_RUNNER husky"
  else
    HUSKY_CMD="CI=1 $PACKAGE_MANAGER_RUNNER husky install && chmod +x \"$ROOT_DIR/.husky/\"*"
  fi

  execute subtask \
    --icon "$ICON_HUSKY" \
    --subject "Husky" \
    --template "install" \
    --cmd "$HUSKY_CMD" \
    --silent-mode "$IS_SILENT"
fi
