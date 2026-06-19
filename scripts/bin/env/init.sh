#!/bin/bash

# Initializes local environment files from examples across the project workspace.
#
# Options:
#   --workspaces <dirs>, -w      : [Optional] Space-separated list of directories to scan.
#   --from <filename>, -f        : [Optional] Source filename (e.g., .env.example). Default: ".env.example".
#   --to <filename>, -t          : [Optional] Destination filename (e.g., .env). Default: ".env".
#   --log-level <number>, -ll    : [Optional] Base level for logs (>= 1). Default: 1.
#   --silent, -sl                : [Optional] Suppress standard output logs.
#
# Usage:
#   bash scripts/bin/env/init.sh [--workspaces "apps packages"] [--from .env.example] [--to .env] [--log-level 1]

ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ENV_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"

OPTIONS_CONFIG="
  WORKSPACES       | --workspaces | -w  | optional | string:dirs     |              | Space-separated list of directories to scan
  FILE_FROM        | --from       | -f  | optional | string:filename | .env.example | Source filename template
  FILE_TO          | --to         | -t  | optional | string:filename | .env         | Destination filename to create
  HEADER_LOG_LEVEL | --log-level  | -ll | optional | int:number      | 1            | Base level for output logs
  IS_SILENT        | --silent     | -sl | optional | flag            |              | Suppress all log outputs
"

intercept_help \
  --name "init-env" \
  --description "Initializes local environment files from examples across the project workspace." \
  --usage "ddx init-env [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

LOG_LEVEL=$((HEADER_LOG_LEVEL + 1))

log -ic "$ICON_ENV" -m "Environment files:" -ll "$HEADER_LOG_LEVEL" -slm "$IS_SILENT"

FILES_TO_PROCESS=()

if [ -f "$ROOT_DIR/$FILE_FROM" ]; then
  FILES_TO_PROCESS+=("$ROOT_DIR/$FILE_FROM")
fi

if [[ -n "$WORKSPACES" ]]; then
  WS_PATHS=()
  for ws in $WORKSPACES; do
    if [ -d "$ROOT_DIR/$ws" ]; then
      WS_PATHS+=("$ROOT_DIR/$ws")
    fi
  done

  if [ ${#WS_PATHS[@]} -gt 0 ]; then
    while IFS= read -r file; do
      FILES_TO_PROCESS+=("$file")
    done < <(find "${WS_PATHS[@]}" \( -name "node_modules" -o -name "src" -o -name "build" -o -name "dist" \) -prune -o -type f -name "$FILE_FROM" -print 2> /dev/null)
  fi
fi

FILES_FOUND=${#FILES_TO_PROCESS[@]}

if [[ "$FILES_FOUND" -eq 0 ]]; then
  log -c "gray" -m "No files matching '$FILE_FROM' were found." -ll "$LOG_LEVEL" -slm "$IS_SILENT"
  exit 0
fi

for SOURCE_PATH in "${FILES_TO_PROCESS[@]}"; do
  DIR=$(dirname "$SOURCE_PATH")
  TARGET_PATH="$DIR/$FILE_TO"

  if [[ "$TARGET_PATH" == "$ROOT_DIR/$FILE_TO" ]]; then
    REL_TARGET="$FILE_TO (root)"
  else
    REL_TARGET="${TARGET_PATH#"$ROOT_DIR/"}"
  fi

  if [ ! -f "$TARGET_PATH" ]; then
    cp "$SOURCE_PATH" "$TARGET_PATH"
    log -s -m "Created: $REL_TARGET" -ll "$LOG_LEVEL" -slm "$IS_SILENT"
  else
    log -i -m "Skipped: $REL_TARGET (already exists)" -ll "$LOG_LEVEL" -slm "$IS_SILENT"
  fi
done
