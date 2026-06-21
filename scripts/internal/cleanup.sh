#!/bin/bash

# Performs a deep cleanup of the project workspace.
# Clears the Yarn cache and deletes all node_modules directories.
#
# Usage:
#   bash scripts/internal/cleanup.sh

INTERNAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$INTERNAL_DIR/../bin"

source "$BIN_DIR/core/theme.sh"
source "$BIN_DIR/tasks/execute.sh"

YARN_CLEAN_CMD='yarn cache clean'
NODE_CLEAN_CMD='find . -name "node_modules" -type d -prune -exec rm -rf "{}" +'

CLEANUP_CMD="
  execute subtask \\
    --icon \"🗄️ \" \\
    --subject \"yarn cache\" \\
    --template \"remove\" \\
    --cmd \"${YARN_CLEAN_CMD}\" &&

  execute subtask \\
    --icon \"${ICON_PACKAGE}\" \\
    --subject \"node_modules\" \\
    --template \"remove\" \\
    --cmd \"${NODE_CLEAN_CMD}\"
"

execute task \
  --icon "$ICON_CLEAN" \
  --name "Project cleanup" \
  --success-msg "Project cleaned up!" \
  --error-msg "Project cleanup failed!" \
  --cmd "$CLEANUP_CMD"
