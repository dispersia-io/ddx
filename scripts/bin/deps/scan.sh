#!/bin/bash

# Scans lockfiles for unstable (0.x.x) dependencies.
#
# Can optionally run an audit and automatically configure Dependabot
# to ignore minor version updates for these specific packages.
#
# Options:
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default: auto-detect or yarn.
#   --audit, -a                      : [Optional] Run security audit before scanning.
#   --pin-unstable, -pu              : [Optional] Automatically write ignore rules to Dependabot config.
#   --meta, -m                       : [Optional] Emit state markers (__UPDATED__, __SKIPPED__) for automation workflows.
#   --silent, -sl                    : [Optional] Suppress standard output logs.
#
# Usage:
#   bash scripts/bin/deps/scan.sh [--package-manager <yarn/npm/pnpm>] [--audit] [--pin-unstable] [--silent]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_INTERNAL_DIR="$DEPS_DIR/_internal"
BIN_DIR="$DEPS_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

OPTIONS_CONFIG="
  PACKAGE_MANAGER     | --package-manager | -pm  | optional | string:name | | Specifies the package manager: yarn, npm or pnpm. (Default: auto-detect or yarn)
  SHOULD_RUN_AUDIT    | --audit           | -a   | optional | flag        | | Run security audit before scanning
  SHOULD_PIN_UNSTABLE | --pin-unstable    | -pu  | optional | flag        | | Automatically write ignore rules to Dependabot config
  SHOULD_EMIT_META    | --meta            | -m   | optional | flag        | | Emit state markers for automation workflows
  IS_SILENT           | --silent          | -sl  | optional | flag        | | Suppress standard output logs
"

intercept_help \
  --name "scan-deps" \
  --description "Scans lockfiles for unstable dependencies." \
  --usage "ddx scan-deps [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

emit_meta() {
  if is_truthy "$SHOULD_EMIT_META"; then
    echo "$1"
  fi
}

source "$DEPS_INTERNAL_DIR/detect-package-manager.sh"
source "$DEPS_INTERNAL_DIR/detect-dependabot-file.sh"

if is_truthy "$SHOULD_RUN_AUDIT"; then
  source "$DEPS_INTERNAL_DIR/audit.sh"
fi

if is_truthy "$SHOULD_PIN_UNSTABLE"; then
  source "$DEPS_INTERNAL_DIR/pin-unstable.sh"
elif [ -n "$DEPENDABOT_FILE" ]; then
  log -i -ic "$ICON_TIP" -m "Run with --pin-unstable to automatically block minor updates for these packages." -slm "$IS_SILENT"
fi
