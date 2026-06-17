#!/bin/bash

# Installs all dependencies and sets up git hooks.
#
# Options:
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default is yarn.
#   --silent, -sl                    : [Optional] Suppress standard output logs.
#
# Usage:
# bash scripts/bin/deps/install.sh [--silent] [--package-manager yarn|npm|pnpm]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_INTERNAL_DIR="$DEPS_DIR/_internal"
BIN_DIR="$DEPS_DIR/.."

export ROOT_DIR="$(pwd)"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/options.sh"
source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  PACKAGE_MANAGER | --package-manager | -pm | optional | string |
  SILENT_MODE     | --silent          | -sl | optional | flag   |
"

eval "$(parse_options "$OPTIONS_CONFIG")"

source "$DEPS_INTERNAL_DIR/detect-package-manager.sh"
source "$DEPS_INTERNAL_DIR/install-node-modules.sh"
source "$DEPS_INTERNAL_DIR/install-husky.sh"
