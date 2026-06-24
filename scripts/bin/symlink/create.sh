#!/usr/bin/env bash

# Automates the creation of absolute symbolic links.
#
# Options:
#   * -ps, --paths <string>     : Space-separated sequence of targets and links
#     -ll, --log-level <int>    : Logging indentation level (Default: 1)
#     -sl, --silent             : Suppress standard output logs.
#
# Usage:
#   ddx symlink create -ps "<target1> <link1> [<target2> <link2> ...]" [options]
#
# Alternative (Direct execution):
#   ./scripts/bin/symlink/create.sh -ps <pairs> [options]
#
# Examples:
#   ddx symlink create -ps "./foo ./foo_link ./bar ./bar_link"

SYMLINKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$SYMLINKS_DIR/.." && pwd)"

source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"

OPTIONS_CONFIG="
  PATHS     | --paths     | -ps | required | string:pairs |   | Space-separated sequence of target and link path pairs
  LOG_LEVEL | --log-level | -ll | optional | int          | 1 | Logging indentation level
  IS_SILENT | --silent    | -sl | optional | flag         |   | Suppress all log outputs
"

intercept_help \
  --name "ddx symlink create" \
  --description "Creates absolute symbolic links from provided path pairs" \
  --usage "ddx symlink create -ps \"<target1> <link1> [<target2> <link2> ...]\" [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

resolve_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    echo "$path"
  else
    local normalized_path="${path#./}"
    local base_dir="${INIT_CWD:-$PWD}"
    echo "$base_dir/$normalized_path"
  fi
}

read -ra PATH_ARR <<< "$PATHS"

if [ $((${#PATH_ARR[@]} % 2)) -ne 0 ] || [ ${#PATH_ARR[@]} -eq 0 ]; then
  log -e -m "Error: Symlinks must be provided in path pairs. Found ${#PATH_ARR[@]} paths" -slm "$IS_SILENT"
  exit 1
fi

for ((i = 0; i < ${#PATH_ARR[@]}; i += 2)); do
  RAW_TARGET="${PATH_ARR[i]}"
  RAW_LINK="${PATH_ARR[i + 1]}"

  ABS_TARGET="$(resolve_path "$RAW_TARGET")"
  ABS_LINK="$(resolve_path "$RAW_LINK")"

  rm -f "$ABS_LINK"

  if ln -s "$ABS_TARGET" "$ABS_LINK"; then
    log -cl -s -ic "$ICON_LINK" -m "Symlink created: $RAW_TARGET -> $RAW_LINK" -ll "$LOG_LEVEL" -slm "$IS_SILENT"
  else
    log -cl -e -ic "$ICON_LINK" -m "Failed to create symlink: $RAW_TARGET -> $RAW_LINK" -ll "$LOG_LEVEL" -slm "$IS_SILENT"
  fi
done
