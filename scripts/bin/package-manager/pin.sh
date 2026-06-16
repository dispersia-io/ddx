#!/bin/bash

# Updates and pins the Package Manager version across the entire workspace.
#
# Synchronizes the version of the specified package manager (yarn, npm, or pnpm)
# by automatically updating targeted parts of the project using specific flags.
#
# Options:
#   --package-manager, -pm <name>    : [Required] The package manager to use (yarn, npm, pnpm).
#   --version, -v <semver>           : [Required] Strict semantic version (e.g., 4.13.0).
#   --workspaces, -w <dirs>          : [Optional] Space or comma-separated list of workspace
#                                      directories to recursively scan (e.g., "apps packages docs").
#
# Target Flags (At least one must be specified):
#   --volta                          : Update version in Volta configuration.
#   --package-json                   : Update 'packageManager' and 'volta' in package.json files.
#   --dockerfile                     : Update corepack in Dockerfile files.
#   --docs                           : Update dynamic version markers in Markdown documents.
#
# Usage:
#   bash ./scripts/bin/package-manager/pin.sh -pm yarn -v 4.13.0 --package-json --dockerfile

ROOT_DIR="$(pwd)"
PM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PM_INTERNAL_DIR="$PM_DIR/_internal"
BIN_DIR="$PM_DIR/.."

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/options.sh"
source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  PACKAGE_MANAGER | --package-manager | -pm | required | string |
  NEW_VERSION     | --version         | -v  | required | string |
  WORKSPACES      | --workspaces      | -w  | optional | string |
  FLAG_VOLTA      | --volta           |     | optional | flag   |
  FLAG_PKG_JSON   | --package-json    |     | optional | flag   |
  FLAG_DOCKER     | --dockerfile      |     | optional | flag   |
  FLAG_DOCS       | --docs            |     | optional | flag   |
"

eval "$(parse_options "$OPTIONS_CONFIG")"

if [[ "$PACKAGE_MANAGER" != "yarn" && "$PACKAGE_MANAGER" != "npm" && "$PACKAGE_MANAGER" != "pnpm" ]]; then
  log -e -c "gray" -m "Error: Unsupported package manager '$PACKAGE_MANAGER'. Use: yarn, npm, or pnpm."
  exit 1
fi

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log -e -c "gray" -m "Error: Version '$NEW_VERSION' must be a strict SemVer (e.g., 1.2.3)."
  exit 1
fi

if [[ "$FLAG_VOLTA" -eq 0 && "$FLAG_PKG_JSON" -eq 0 && "$FLAG_DOCKER" -eq 0 && "$FLAG_DOCS" -eq 0 ]]; then
  log -e -c "gray" -m "Error: At least one target flag must be specified: --volta, --package-json, --dockerfile, or --docs."
  exit 1
fi

if [[ "$PACKAGE_MANAGER" == "yarn" ]]; then
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/@yarnpkg/cli-dist/${NEW_VERSION}\" || curl -s -f -I \"https://registry.npmjs.org/yarn/${NEW_VERSION}\""
else
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/${PACKAGE_MANAGER}/${NEW_VERSION}\""
fi

VOLTA_PIN_CMD="cd \"${ROOT_DIR}\" && volta pin ${PACKAGE_MANAGER}@${NEW_VERSION}"

export ROOT_DIR NEW_VERSION PACKAGE_MANAGER WORKSPACES

UPDATE_DOCKER_CMD="node \"$PM_INTERNAL_DIR/update-dockerfile.js\""
UPDATE_PKG_CMD="node \"$PM_INTERNAL_DIR/update-package-json.js\""
UPDATE_DOCS_CMD="node \"$PM_INTERNAL_DIR/update-docs.js\""

PIN_CMD="execute subtask \\
  --icon \"✅\" \\
  --subject \"${PACKAGE_MANAGER}@${NEW_VERSION}\" \\
  --template \"verify\" \\
  --cmd \"${VERIFY_RELEASE_CMD}\""

if [[ "$FLAG_VOLTA" -eq 1 ]]; then
  PIN_CMD="$PIN_CMD && \\
  execute subtask \\
    --icon \"⚡️\" \\
    --subject \"Volta\" \\
    --template \"pin\" \\
    --cmd \"${VOLTA_PIN_CMD}\""
fi

if [[ "$FLAG_DOCKER" -eq 1 ]]; then
  PIN_CMD="$PIN_CMD && \\
  execute subtask \\
    --icon \"🐳\" \\
    --subject \"Dockerfile files\" \\
    --template \"pin\" \\
    --cmd \"${UPDATE_DOCKER_CMD}\""
fi

if [[ "$FLAG_PKG_JSON" -eq 1 ]]; then
  PIN_CMD="$PIN_CMD && \\
  execute subtask \\
    --icon \"📝\" \\
    --subject \"package.json files\" \\
    --template \"pin\" \\
    --cmd \"${UPDATE_PKG_CMD}\""
fi

if [[ "$FLAG_DOCS" -eq 1 ]]; then
  PIN_CMD="$PIN_CMD && \\
  execute subtask \\
    --icon \"📖\" \\
    --subject \"Documents\" \\
    --template \"pin\" \\
    --cmd \"${UPDATE_DOCS_CMD}\""
fi

execute task \
  --icon "📦" \
  --name "${PACKAGE_MANAGER} version update" \
  --success-msg "${PACKAGE_MANAGER} version updated across the project!" \
  --error-msg "Failed to update ${PACKAGE_MANAGER} version!" \
  --cmd "$PIN_CMD"
