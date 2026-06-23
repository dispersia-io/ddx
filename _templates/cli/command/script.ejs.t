---
to: scripts/bin/<%= command %>/<%= subcommand %>.sh
---
#!/usr/bin/env bash

# <%= description %>
#
# Options:
#   * -r, --required-opt <val>    : Example of a required option
#     -o, --optional-opt          : Example of an optional option
#
# Usage:
#   ddx <%= command %> <%= subcommand %> -r <val> [options]
#
# Alternative (Direct execution):
#   ./scripts/bin/<%= command %>/<%= subcommand %>.sh -r <val> [options]
#
# Examples:
#   ddx <%= command %> <%= subcommand %> -r "value"
#   ddx <%= command %> <%= subcommand %> -o

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/log.sh"

OPTIONS_CONFIG="
  REQUIRED_OPTION | --required-opt | -r | required | string:val |   | Example of a required option
  OPTIONAL_OPTION | --optional-opt | -o | optional | int        | 0 | Example of an optional option
"

intercept_help \
  --name "<%= command %> <%= subcommand %>" \
  --description "<%= description %>" \
  --usage "ddx <%= command %> <%= subcommand %> -r <val> [options]" \
  --options "$OPTIONS_CONFIG" \
  -- "$@"

eval "$(parse_options "$OPTIONS_CONFIG")"

# Behavior...