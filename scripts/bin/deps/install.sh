#!/bin/bash

# Installs all dependencies and sets up git hooks.
#
# Options:
#   --subtask                        : [Optional] Formats the output for nested execution within a larger task.
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default is yarn.
#
# Usage:
# bash scripts/bin/deps/install.sh [--subtask] [--package-manager yarn|npm|pnpm]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$DEPS_DIR/.."

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/tasks/execute.sh"

EXEC_FLAG=()
PACKAGE_MANAGER="yarn"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --task)
      log -e -c "gray" -m "Error: The deps/install.sh script does not support the --task option."
      exit 1
      ;;
    --subtask)
      EXEC_FLAG=("--subtask")
      shift
      ;;
    --package-manager | -pm)
      if [[ -z "$2" || "$2" == -* ]]; then
        log -e -c "gray" -m "Error: Option '$1' requires an argument (yarn, npm, pnpm)."
        exit 1
      fi
      PACKAGE_MANAGER="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ "$PACKAGE_MANAGER" != "yarn" && "$PACKAGE_MANAGER" != "npm" && "$PACKAGE_MANAGER" != "pnpm" ]]; then
  log -e -c "gray" -m "Error: Unsupported package manager '$PACKAGE_MANAGER'. Supported arguments: yarn, npm, pnpm."
  exit 1
fi

case "$PACKAGE_MANAGER" in
  yarn) PACKAGE_MANAGER_RUNNER="yarn" ;;
  npm) PACKAGE_MANAGER_RUNNER="npx --no" ;;
  pnpm) PACKAGE_MANAGER_RUNNER="pnpm exec" ;;
esac

source "$DEPS_DIR/_internal/install-node-modules.sh"
source "$DEPS_DIR/_internal/install-husky.sh"
