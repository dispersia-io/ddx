#!/usr/bin/env bash

# Resolves and exports the absolute path to the project root directory (ROOT_DIR).

if [ -n "$ROOT_DIR" ]; then
  return 0 2> /dev/null || exit 0
fi

START_DIR="${INIT_CWD:-$PWD}"

ROOT_DIR=$(cd "$START_DIR" && git rev-parse --show-toplevel 2> /dev/null)

if [ -z "$ROOT_DIR" ]; then
  CURRENT_DIR="$START_DIR"

  while [[ "$CURRENT_DIR" != "/" && -n "$CURRENT_DIR" ]]; do
    if [[ -f "$CURRENT_DIR/pnpm-lock.yaml" || -f "$CURRENT_DIR/package-lock.json" || -f "$CURRENT_DIR/yarn.lock" || -f "$CURRENT_DIR/pnpm-workspace.yaml" ]]; then
      ROOT_DIR="$CURRENT_DIR"
      break
    fi
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
  done
fi

export ROOT_DIR="${ROOT_DIR:-$START_DIR}"
