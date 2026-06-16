#!/bin/bash

# Initializes local environment files from examples across the project workspace.
#
# Options:
#   --workspaces <dirs>, -w    : [Required] Space-separated list of directories to scan.
#   --from <filename>, -f      : [Optional] Source filename (e.g., .env.example). Default: ".env.example".
#   --to <filename>, -t        : [Optional] Destination filename (e.g., .env). Default: ".env".
#   --level <number>, -l       : [Optional] Base level for logs (>= 1). Default: 1.
#
# Usage:
# bash scripts/bin/env/init.sh --workspaces "apps packages" [--from .env.example] [--to .env] [--level 1]

ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ENV_DIR/.."
UTILS_DIR="$BIN_DIR/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/options.sh"

OPTIONS_CONFIG="
  WORKSPACES   | --workspaces | -w | required | string | 
  FROM_FILE    | --from       | -f | optional | string | .env.example
  TO_FILE      | --to         | -t | optional | string | .env
  HEADER_LEVEL | --level      | -l | optional | int    | 1
"

eval "$(parse_options "$OPTIONS_CONFIG")"

LEVEL=$((HEADER_LEVEL + 1))

log -l "$HEADER_LEVEL" -ic "🔐" -m "Environment files:"

FILES_FOUND=0

while IFS= read -r SOURCE_PATH; do
  FILES_FOUND=$((FILES_FOUND + 1))
  DIR=$(dirname "$SOURCE_PATH")
  TARGET_PATH="$DIR/$TO_FILE"

  if [ ! -f "$TARGET_PATH" ]; then
    cp "$SOURCE_PATH" "$TARGET_PATH"
    log -s -l "$LEVEL" -ic "📃" -m "Created: $TARGET_PATH"
  else
    log -i -l "$LEVEL" -ic "📃" -m "Skipped: $TARGET_PATH (already exists)"
  fi
done < <(find $WORKSPACES -type f -name "$FROM_FILE" 2> /dev/null)

if [[ "$FILES_FOUND" -eq 0 ]]; then
  log -l "$LEVEL" -c "gray" -m "No files matching '$FROM_FILE' were found in the specified workspaces."
fi
