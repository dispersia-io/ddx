#!/bin/bash

# Installs all dependencies and sets up git hooks.
#
# Options:
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default is auto-detect or yarn.
#   --silent, -sl                    : [Optional] Suppress standard output logs.
#
# Usage:
# bash scripts/bin/deps/install.sh [--package-manager yarn|npm|pnpm] [--silent]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_INTERNAL_DIR="$DEPS_DIR/_internal"
BIN_DIR="$DEPS_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  PACKAGE_MANAGER | --package-manager | -pm | optional | string:name |  | Specifies the package manager (Default: auto-detect or yarn)
  IS_SILENT       | --silent          | -sl | optional | flag        |  | Suppress standard output logs
"

intercept_help \
  --name "install" \
  --description "Installs all dependencies and sets up git hooks." \
  --usage "ddx install [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

source "$DEPS_INTERNAL_DIR/detect-package-manager.sh"
source "$DEPS_INTERNAL_DIR/install-node-modules.sh"
source "$DEPS_INTERNAL_DIR/install-husky.sh"
