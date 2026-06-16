#!/bin/bash

# Initializes local environment files from examples across the project workspace.
#
# Options:
#   --workspaces <dirs>, -w    : [Required] Space-separated list of directories to scan.
#   --from <filename>, -f      : [Optional] Source filename (e.g., .env.example). Default: ".env.example".
#   --to <filename>, -t        : [Optional] Destination filename (e.g., .env). Default: ".env".
#   --level <number>, -l       : [Optional] Base level for logs (>= 1).
#
# Usage:
# bash scripts/bin/env/init.sh --workspaces "apps packages" [--from .env.example] [--to .env] [--level 1]

ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ENV_DIR/.."

source "$BIN_DIR/utils/log.sh"

HEADER_LEVEL="1"
WORKSPACES=""
FROM_FILE=".env.example"
TO_FILE=".env"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --level | -l)
      if [[ -z "$2" || "$2" == -* ]]; then
        log -e -c "gray" -m "Error: Option '--level, -l' requires an integer argument (>= 1)."
        exit 1
      fi
      if ! [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
        log -e -c "gray" -m "Error: Option '--level, -l' must be an integer >= 1."
        exit 1
      fi
      HEADER_LEVEL="$2"
      shift 2
      ;;
    --workspaces | -w)
      if [[ -z "$2" || "$2" == -* ]]; then
        log -e -c "gray" -m "Error: Option '--workspaces, -w' requires an argument (e.g., \"apps packages\")."
        exit 1
      fi
      WORKSPACES="$2"
      shift 2
      ;;
    --from | -f)
      if [[ -z "$2" || "$2" == -* ]]; then
        log -e -c "gray" -m "Error: Option '--from, -f' requires an argument (e.g. \".env.example\")."
        exit 1
      fi
      FROM_FILE="$2"
      shift 2
      ;;
    --to | -t)
      if [[ -z "$2" || "$2" == -* ]]; then
        log -e -c "gray" -m "Error: Option '--to, -t' requires an argument (e.g. \".env\")."
        exit 1
      fi
      TO_FILE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$WORKSPACES" ]]; then
  log -e -c "gray" -m "Error: The '--workspaces, -w' option is required."
  exit 1
fi

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
