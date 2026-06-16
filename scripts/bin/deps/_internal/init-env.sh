#!/bin/bash

# This is an internal script. Do not run it directly.
# Relies on variables from the parent script: PACKAGE_MANAGER

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
    AUDIT_CMD="yarn npm audit --recursive --all"
    ;;
  npm)
    LOCKFILE="package-lock.json"
    AUDIT_CMD="npm audit --all"
    ;;
  pnpm)
    LOCKFILE="pnpm-lock.yaml"
    AUDIT_CMD="pnpm audit"
    ;;
  *)
    log -cl -e -m "Error: Unsupported package manager '$PACKAGE_MANAGER'. Supported options: yarn, npm, pnpm."
    exit 1
    ;;
esac

DEPENDABOT_FILE=""
if [ -f ".github/dependabot.yml" ]; then
  DEPENDABOT_FILE=".github/dependabot.yml"
elif [ -f ".github/dependabot.yaml" ]; then
  DEPENDABOT_FILE=".github/dependabot.yaml"
elif [ "$PIN_UNSTABLE" = true ]; then
  if [ "$SILENT_MODE" = false ]; then
    log -cl -e -m "Error: Dependabot configuration not found."
  fi
  exit 1
fi
