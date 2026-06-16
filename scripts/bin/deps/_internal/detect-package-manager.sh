#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER, SILENT_MODE

if [[ -z "$PACKAGE_MANAGER" ]]; then
  if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
  elif [ -f "package-lock.json" ]; then
    PACKAGE_MANAGER="npm"
  else
    PACKAGE_MANAGER="yarn"
  fi
fi

case "$PACKAGE_MANAGER" in
  yarn)
    LOCKFILE="yarn.lock"
    PACKAGE_MANAGER_RUNNER="yarn"
    PACKAGE_MANAGER_AUDIT_CMD="yarn npm audit --recursive --all"
    ;;
  npm)
    LOCKFILE="package-lock.json"
    PACKAGE_MANAGER_RUNNER="npx --no"
    PACKAGE_MANAGER_AUDIT_CMD="npm audit --all"
    ;;
  pnpm)
    LOCKFILE="pnpm-lock.yaml"
    PACKAGE_MANAGER_RUNNER="pnpm exec"
    PACKAGE_MANAGER_AUDIT_CMD="pnpm audit"
    ;;
  *)
    if ((!SILENT_MODE)); then
      log -cl -e -m "Error: Unsupported package manager '$PACKAGE_MANAGER'. Supported options: yarn, npm, pnpm."
    fi
    exit 1
    ;;
esac
