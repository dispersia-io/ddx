#!/usr/bin/env bash

# Updates and pins the Node.js version across the entire workspace.
#
# Synchronizes the Node.js version by automatically updating targeted parts
# of the project using specific flags.
#
# Options:
#   * -v, --version <semver>     : Strict semantic version (e.g., 24.14.1)
#     -w, --workspaces <dirs>    : Space or comma-separated list of workspace
#                                  directories to recursively scan
#     -sl, --silent              : Suppress standard output logs
#
# Target Flags (At least one must be specified):
#     --volta                    : Update version in Volta configuration
#     --version-file             : Update the root .node-version file
#     --engine                   : Update 'engines.node' in package.json files
#     --env                      : Update NODE_VERSION in environment files
#     --docs                     : Update dynamic version markers in Markdown documents
#
# Usage:
#   ddx node pin -v <semver> [options]
#
# Alternative (Direct execution):
#   ./scripts/bin/node/pin.sh -v <semver> [options]
#
# Examples:
#   ddx node pin -v 24.14.1 --volta --engine
#   ddx node pin -v 24.14.1 -w "apps packages" --env --docs

NODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_INTERNAL_DIR="$NODE_DIR/_internal"
BIN_DIR="$NODE_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  NODE_VERSION            | --version      | -v  | required | string:semver | | Strict semantic version (e.g., 24.14.1)
  NODE_WORKSPACES         | --workspaces   | -w  | optional | string:dirs   | | Space or comma-separated list of workspace directories to scan
  SHOULD_PIN_VOLTA        | --volta        |     | optional | flag          | | Update version in Volta configuration
  SHOULD_PIN_VERSION_FILE | --version-file |     | optional | flag          | | Update the root .node-version file
  SHOULD_PIN_ENGINE       | --engine       |     | optional | flag          | | Update 'engines.node' in package.json files
  SHOULD_PIN_ENV          | --env          |     | optional | flag          | | Update NODE_VERSION in environment files
  SHOULD_PIN_DOCS         | --docs         |     | optional | flag          | | Update version markers in documentation
  IS_SILENT               | --silent       | -sl | optional | flag          | | Suppress standard output logs
"

intercept_help \
  --name "ddx node pin" \
  --description "Updates and pins the Node.js version across the entire workspace" \
  --usage "ddx node pin -v <semver> [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

if [[ ! "$NODE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log -e -c "gray" -m "Error: Version '$NODE_VERSION' must be a strict SemVer (e.g., 24.14.1)" -slm "$IS_SILENT"
  exit 1
fi

if is_falsy "$SHOULD_PIN_VOLTA" && is_falsy "$SHOULD_PIN_VERSION_FILE" && is_falsy "$SHOULD_PIN_ENGINE" && is_falsy "$SHOULD_PIN_ENV" && is_falsy "$SHOULD_PIN_DOCS"; then
  log -e -c "gray" -m "Error: At least one target flag must be specified: --volta, --version-file, --engine, --env, or --docs" -slm "$IS_SILENT"
  exit 1
fi

export NODE_VERSION NODE_WORKSPACES

VERIFY_RELEASE_CMD="curl -s -f -I \"https://nodejs.org/dist/v${NODE_VERSION}/\""

PIN_CMD="execute subtask \\
  --icon \"${ICON_SUCCESS}\" \\
  --subject \"node@${NODE_VERSION}\" \\
  --template \"verify\" \\
  --cmd \"${VERIFY_RELEASE_CMD}\" \\
  --silent-mode \"${IS_SILENT}\""

if is_truthy "$SHOULD_PIN_VOLTA"; then
  VOLTA_PIN_CMD="cd \"${ROOT_DIR}\" && volta pin node@${NODE_VERSION}"

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_VOLTA}\" \\
      --subject \"Volta\" \\
      --template \"pin\" \\
      --cmd \"${VOLTA_PIN_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_VERSION_FILE"; then
  UPDATE_VERSION_FILE_CMD="echo \"${NODE_VERSION}\" > \"${ROOT_DIR}/.node-version\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_FILE}\" \\
      --subject \".node-version\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_VERSION_FILE_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_ENGINE"; then
  UPDATE_PKG_JSON_CMD="node \"$NODE_INTERNAL_DIR/update-engine.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_JSON}\" \\
      --subject \"package.json files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_PKG_JSON_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""

  INSTALL_CMD="cd \"${ROOT_DIR}\" && ${PACKAGE_MANAGER} install"

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_PACKAGE}\" \\
      --subject \"Lockfile\" \\
      --template \"sync\" \\
      --cmd \"${INSTALL_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_ENV"; then
  UPDATE_ENV_CMD="node \"$NODE_INTERNAL_DIR/update-env.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_ENV}\" \\
      --subject \"Environment files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_ENV_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_DOCS"; then
  UPDATE_DOCS_CMD="node \"$NODE_INTERNAL_DIR/update-docs.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_DOCS}\" \\
      --subject \"Documents\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_DOCS_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

execute task \
  --icon "$ICON_PACKAGE" \
  --name "Node.js version update" \
  --success-msg "Node.js version updated across the project!" \
  --error-msg "Failed to update Node.js version!" \
  --cmd "$PIN_CMD" \
  --silent-mode "$IS_SILENT"
