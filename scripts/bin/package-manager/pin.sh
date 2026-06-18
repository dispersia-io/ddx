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

PM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PM_INTERNAL_DIR="$PM_DIR/_internal"
BIN_DIR="$PM_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"
source "$BIN_DIR/utils/options.sh"
source "$BIN_DIR/tasks/execute.sh"

OPTIONS_CONFIG="
  PACKAGE_MANAGER       | --package-manager | -pm | required | string |
  VERSION               | --version         | -v  | required | string |
  WORKSPACES            | --workspaces      | -w  | optional | string |
  SHOULD_PIN_VOLTA      | --volta           |     | optional | flag   |
  SHOULD_PIN_PKG_JSON   | --package-json    |     | optional | flag   |
  SHOULD_PIN_DOCKERFILE | --dockerfile      |     | optional | flag   |
  SHOULD_PIN_DOCS       | --docs            |     | optional | flag   |
  IS_SILENT             | --silent          | -sl | optional | flag   |
"

eval "$(parse_options "$OPTIONS_CONFIG")"

if [[ "$PACKAGE_MANAGER" != "yarn" && "$PACKAGE_MANAGER" != "npm" && "$PACKAGE_MANAGER" != "pnpm" ]]; then
  log -e -c "gray" -m "Error: Unsupported package manager '$PACKAGE_MANAGER'. Use: yarn, npm, or pnpm." -slm "$IS_SILENT"
  exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  log -e -c "gray" -m "Error: Version '$VERSION' must be a strict SemVer (e.g., 1.2.3)." -slm "$IS_SILENT"
  exit 1
fi

if ! (is_truthy "$SHOULD_PIN_VOLTA" || is_truthy "$SHOULD_PIN_PKG_JSON" || is_truthy "$SHOULD_PIN_DOCKERFILE" || is_truthy "$SHOULD_PIN_DOCS"); then
  log -e -c "gray" -m "Error: At least one target flag must be specified: --volta, --package-json, --dockerfile, or --docs." -slm "$IS_SILENT"
  exit 1
fi

export PACKAGE_MANAGER VERSION WORKSPACES

if [[ "$PACKAGE_MANAGER" == "yarn" ]]; then
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/@yarnpkg/cli-dist/${VERSION}\" || curl -s -f -I \"https://registry.npmjs.org/yarn/${VERSION}\""
else
  VERIFY_RELEASE_CMD="curl -s -f -I \"https://registry.npmjs.org/${PACKAGE_MANAGER}/${VERSION}\""
fi

PIN_CMD="execute subtask \\
  --icon \"✅\" \\
  --subject \"${PACKAGE_MANAGER}@${VERSION}\" \\
  --template \"verify\" \\
  --cmd \"${VERIFY_RELEASE_CMD}\" \\
  --silent-mode \"${IS_SILENT}\""

if is_truthy "$SHOULD_PIN_VOLTA"; then
  VOLTA_PIN_CMD="cd \"${ROOT_DIR}\" && volta pin ${PACKAGE_MANAGER}@${VERSION}"

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"⚡️\" \\
      --subject \"Volta\" \\
      --template \"pin\" \\
      --cmd \"${VOLTA_PIN_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_DOCKERFILE"; then
  UPDATE_DOCKERFILE_CMD="node \"$PM_INTERNAL_DIR/update-dockerfile.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"🐳\" \\
      --subject \"Dockerfile files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_DOCKERFILE_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_PKG_JSON"; then
  UPDATE_PKG_JSON_CMD="node \"$PM_INTERNAL_DIR/update-package-json.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"📝\" \\
      --subject \"package.json files\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_PKG_JSON_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

if is_truthy "$SHOULD_PIN_DOCS"; then
  UPDATE_DOCS_CMD="node \"$PM_INTERNAL_DIR/update-docs.js\""

  PIN_CMD="$PIN_CMD && \\
    execute subtask \\
      --icon \"📖\" \\
      --subject \"Documents\" \\
      --template \"pin\" \\
      --cmd \"${UPDATE_DOCS_CMD}\" \\
      --silent-mode \"${IS_SILENT}\""
fi

execute task \
  --icon "📦" \
  --name "${PACKAGE_MANAGER} version update" \
  --success-msg "${PACKAGE_MANAGER} version updated across the project!" \
  --error-msg "Failed to update ${PACKAGE_MANAGER} version!" \
  --cmd "$PIN_CMD" \
  --silent-mode "$IS_SILENT"
