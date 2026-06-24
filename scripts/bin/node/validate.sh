#!/usr/bin/env bash

# Validates the active Node.js version against the project's requirements.
#
# Options:
#   -f, --file <path>    : Override the path to the .node-version file (Default: "$ROOT_DIR/.node-version")
#   -sl, --silent        : Suppress standard output logs
#
# Usage:
#   ddx node validate [options]
#
# Alternative (Direct execution):
#   ./scripts/bin/node/validate.sh [options]
#
# Examples:
#   ddx node validate
#   ddx node validate -f "/custom/path/to/.node-version"

NODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$NODE_DIR/.." && pwd)"

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

OPTIONS_CONFIG="
  FILE_PATH | --file   | -f  | optional | string:path | | Path to a custom file containing the required Node.js version (Default: \$ROOT_DIR/.node-version)
  IS_SILENT | --silent | -sl | optional | flag        | | Suppress standard output logs
"

intercept_help \
  --name "ddx node validate" \
  --description "Validates the active Node.js version against the project's requirements" \
  --usage "ddx node validate [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

NODE_VERSION_FILE="${FILE_PATH:-"$ROOT_DIR/.node-version"}"

if [ ! -f "$NODE_VERSION_FILE" ]; then
  log -e -c "gray" -m "Error: .node-version file not found at $NODE_VERSION_FILE" -slm "$IS_SILENT"
  exit 1
fi

MIN_NODE_VERSION=$(cat "$NODE_VERSION_FILE" | tr -d 'v' | tr -d '[:space:]')

raw_node_version=$(node -v)
current_node_version="${raw_node_version#v}"

if ! MIN_NODE_VERSION="$MIN_NODE_VERSION" node "$NODE_DIR/_internal/validate-version.js" 2> /dev/null; then
  if is_falsy "$IS_SILENT"; then
    log -ll 2 -m "Node.js version mismatch\n" -e
    log -ll 3 -m "Expected: ${COLOR_GREEN}^$MIN_NODE_VERSION${COLOR_RESET}"
    log -ll 3 -m "Received: ${COLOR_RED} ^$current_node_version${COLOR_RESET}\n"
    log -ll 3 -m "Please update your local Node.js environment to match the required version" -c "gray"
    log -ll 3 -m "Examples:" -c "gray"
    log -ll 3 -m "  - NVM:   nvm use" -c "gray"
    log -ll 3 -m "  - FNM:   fnm use" -c "gray"
    log -ll 3 -m "  - Volta: volta install node@$MIN_NODE_VERSION" -c "gray"
  fi
  exit 1
fi
