#!/bin/bash

# Scans lockfiles for unstable (0.x.x) dependencies.
#
# Can optionally run an audit and automatically configure Dependabot
# to ignore minor version updates for these specific packages.
#
# Options:
#   --audit, -a                      : [Optional] Run security audit before scanning.
#   --pin-unstable, -pu              : [Optional] Automatically write ignore rules to Dependabot config.
#   --silent, -s                     : [Optional] Suppress standard output logs (useful for CI/CD).
#   --meta, -m                       : [Optional] Emit state markers (__UPDATED__, __SKIPPED__) for automation workflows.
#   --package-manager, -pm <name>    : [Optional] Specifies the package manager (yarn, npm, pnpm). Default: auto-detect OR yarn.
#
# Usage:
# bash scripts/bin/deps/scan.sh [--audit] [--pin-unstable] [--silent] [--package-manager yarn|npm|pnpm]

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$DEPS_DIR/.."
INTERNAL_DIR="$DEPS_DIR/_internal"

source "$BIN_DIR/utils/log.sh"

cd "$DEPS_DIR/../../.." || exit 1

RUN_AUDIT=false
PIN_UNSTABLE=false
SILENT_MODE=false
EMIT_META=false
PACKAGE_MANAGER=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --audit | -a)
      RUN_AUDIT=true
      shift 1
      ;;
    --pin-unstable | -pu)
      PIN_UNSTABLE=true
      shift 1
      ;;
    --silent | -s)
      SILENT_MODE=true
      shift 1
      ;;
    --meta | -m)
      EMIT_META=true
      shift 1
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
      shift 1
      ;;
  esac
done

emit_meta() {
  if [ "$EMIT_META" = true ]; then
    echo "$1"
  fi
}

source "$INTERNAL_DIR/init-env.sh"

if [ "$RUN_AUDIT" = true ]; then
  source "$INTERNAL_DIR/audit.sh"
fi

if [ "$PIN_UNSTABLE" = true ]; then
  source "$INTERNAL_DIR/pin-unstable.sh"
else
  if [ "$SILENT_MODE" = false ] && [ -n "$DEPENDABOT_FILE" ]; then
    log -i -ic "💡" -m "Run with --pin-unstable to automatically block minor updates for these packages."
  fi
fi
