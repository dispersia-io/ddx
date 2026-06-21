#!/usr/bin/env bash

# Orchestrates the initial project setup sequence.
#
# Usage:
#   bash scripts/internal/setup.sh

set -e

PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$PWD/../bin"

source "$BIN_DIR/tasks/execute.sh"

SETUP_CMD="bash ./scripts/bin/deps/install.sh"

execute task \
  --icon "🚀" \
  --name "Project setup" \
  --success-msg "Project setup complete!" \
  --error-msg "Project setup failed!" \
  --cmd "$SETUP_CMD"
