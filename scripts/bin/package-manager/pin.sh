#!/usr/bin/env bash

# Updates and pins the Package Manager version across the entire workspace.
#
# Synchronizes the version of the specified package manager (yarn, npm, or pnpm)
# by automatically updating targeted parts of the project using specific flags.
#
# Options:
#   --name, -n <string>              : [Required] The package manager to use (yarn, npm, pnpm).
#   --version, -v <semver>           : [Required] Strict semantic version (e.g., 4.13.0).
#   --workspaces, -w <dirs>          : [Optional] Space or comma-separated list of workspace
#                                      directories to recursively scan (e.g., "apps packages docs").
#   --silent, -sl                    : [Optional] Suppress standard output logs.
#
# Target Flags (At least one must be specified):
#   --volta                          : Update version in Volta configuration.
#   --package-json                   : Update 'packageManager' in package.json files.
#   --dockerfile                     : Update corepack in Dockerfile files.
#   --docs                           : Update dynamic version markers in Markdown documents.
#
# Usage:
#   bash scripts/bin/package-manager/pin.sh -n yarn -v 4.13.0 --package-json --dockerfile

PM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PM_INTERNAL_DIR="$PM_DIR/_internal"
BIN_DIR="$PM_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  PM_NAME               | --name         | -n  | required | string        | | The package manager to use (yarn, npm, pnpm)
  PM_VERSION            | --version      | -v  | required | string:semver | | Strict semantic version (e.g., 4.13.0)
  PM_WORKSPACES         | --workspaces   | -w  | optional | string:dirs   | | Space or comma-separated list of workspace directories to scan
  SHOULD_PIN_VOLTA      | --volta        |     | optional | flag          | | Update version in Volta configuration
  SHOULD_PIN_PKG_JSON   | --package-json |     | optional | flag          | | Update 'packageManager' in package.json files
  SHOULD_PIN_DOCKERFILE | --dockerfile   |     | optional | flag          | | Update corepack in Dockerfile files
  SHOULD_PIN_DOCS       | --docs         |     | optional | flag          | | Update dynamic version markers in Markdown documents
  IS_SILENT             | --silent       | -sl | optional | flag          | | Suppress standard output logs
"

intercept_help \
  --name "package-manager pin" \
  --description "Updates and pins the Package Manager version across the entire workspace." \
  --usage "ddx package-manager pin [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

if [[ "$PM_NAME" != "yarn" && "$PM_NAME" != "npm" && "$PM_NAME" != "pnpm" ]]; then
  log -e -c "gray" -m "Error: Unsupported package manager '$PM_NAME'. Use: yarn, npm, or pnpm." -slm "$IS_SILENT"
  exit 1
fi

if [[ ! "$PM_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log -e -c "gray" -m "Error: Version '$PM_VERSION' must be a strict SemVer (e.g., 1.2.3)." -slm "$IS_SILENT"
  exit 1
fi

if is_falsy "$SHOULD_PIN_VOLTA" && is_falsy "$SHOULD_PIN_PKG_JSON" && is_falsy "$SHOULD_PIN_DOCKERFILE" && is_falsy "$SHOULD_PIN_DOCS"; then
  log -e -c "gray" -m "Error: At least one target flag must be specified: --volta, --package-json, --dockerfile, or --docs." -slm "$IS_SILENT"
  exit 1
fi

export PM_NAME PM_VERSION PM_WORKSPACES

if [[ "$PM_NAME" == "yarn" ]]; then
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/@yarnpkg/cli-dist/${PM_VERSION}\" || curl -s -f -I \"https://registry.npmjs.org/yarn/${PM_VERSION}\""
else
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/${PM_NAME}/${PM_VERSION}\""
fi

PIN_CMD="execute subtask \\
  --icon \"${ICON_SUCCESS}\" \\
  --subject \"${PM_NAME}@${PM_VERSION}\" \\
  --template \"verify\" \\
  --cmd \"${VERIFY_RELEASE_CMD}\" \\
  --silent-mode \"${IS_SILENT}\""

if is_truthy "$SHOULD_PIN_VOLTA"; then
  VOLTA_PIN_CMD="cd \"${ROOT_DIR}\" && volta pin ${PM_NAME}@${PM_VERSION}"

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_VOLTA}\" \\
      --subject \"Volta\" \\
      --template \"pin\" \\
      --cmd \"${VOLTA_PIN_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_DOCKERFILE"; then
  UPDATE_DOCKERFILE_CMD="node \"$PM_INTERNAL_DIR/update-dockerfile.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_DOCKER}\" \\
      --subject \"Dockerfile files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_DOCKERFILE_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_PKG_JSON"; then
  UPDATE_PKG_JSON_CMD="node \"$PM_INTERNAL_DIR/update-package-json.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_JSON}\" \\
      --subject \"package.json files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_PKG_JSON_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""

  INSTALL_CMD="cd \"${ROOT_DIR}\" && ${PM_NAME} install"

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"${ICON_PACKAGE}\" \\
      --subject \"Lockfile\" \\
      --template \"sync\" \\
      --cmd \"${INSTALL_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_DOCS"; then
  UPDATE_DOCS_CMD="node \"$PM_INTERNAL_DIR/update-docs.js\""

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
  --name "${PM_NAME} version update" \
  --success-msg "${PM_NAME} version updated across the project!" \
  --error-msg "Failed to update ${PM_NAME} version!" \
  --cmd "$PIN_CMD" \
  --silent-mode "$IS_SILENT"
