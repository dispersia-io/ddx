#!/bin/bash

# Scans lockfiles for unstable (0.x.x) dependencies.
#
# Can optionally run an audit and automatically configure Dependabot
# to ignore minor version updates for these specific packages.
#
# Options:
#   --audit, -a                      : [Optional] Run security audit before scanning.
#   --pin-unstable, -pu              : [Optional] Automatically write ignore rules to Dependabot config.
#   --silent, -sl                    : [Optional] Suppress standard output logs (useful for CI/CD).
#   --meta, -m                       : [Optional] Emit state markers (__UPDATED__, __SKIPPED__) for automation workflows.
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default: auto-detect OR yarn.
#
# Usage:
# bash scripts/bin/deps/scan.sh [--package-manager yarn|npm|pnpm] [--audit] [--pin-unstable] [--silent]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_INTERNAL_DIR="$DEPS_DIR/_internal"
BIN_DIR="$DEPS_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"
source "$BIN_DIR/utils/options.sh"

OPTIONS_CONFIG="
  RUN_AUDIT       | --audit           | -a   | optional | flag   |
  PIN_UNSTABLE    | --pin-unstable    | -pu  | optional | flag   |
  IS_SILENT       | --silent          | -sl  | optional | flag   |
  EMIT_META       | --meta            | -m   | optional | flag   |
  PACKAGE_MANAGER | --package-manager | -pm  | optional | string |
"

eval "$(parse_options "$OPTIONS_CONFIG")"

emit_meta() {
  if ((EMIT_META)); then
    echo "$1"
  fi
}

source "$DEPS_INTERNAL_DIR/detect-package-manager.sh"
source "$DEPS_INTERNAL_DIR/detect-dependabot-file.sh"

if is_truthy "$RUN_AUDIT"; then
  source "$DEPS_INTERNAL_DIR/audit.sh"
fi

if is_truthy "$PIN_UNSTABLE"; then
  source "$DEPS_INTERNAL_DIR/pin-unstable.sh"
elif [ -n "$DEPENDABOT_FILE" ]; then
  log -i -ic "💡" -m "Run with --pin-unstable to automatically block minor updates for these packages." -slm "$IS_SILENT"
fi
