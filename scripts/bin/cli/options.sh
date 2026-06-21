#!/usr/bin/env bash

# Generates JIT bash parsing logic from a declarative configuration string.
# Automates variable initialization, default values, type validation,
# binary flags handling, and required argument checks.
#
# Format:
# <var_name> | <long_opt> | <short_opt> | <requirement> (required|optional) | <type[:display-type]> (string|int|flag|toggle) | <default-value> | <description>
#
# Types:
#   string    : Standard text argument
#   int       : Validates that the argument is an integer >= 1
#   flag      : Binary switch (0 by default, 1 if passed without arguments). Ignores default values.
#   toggle    : Boolean-like argument. Accepts any value, validates via is_enabled, and normalizes to 0 or 1.
#
# Types can optionally include a custom display name after a colon for help rendering, e.g.:
#   string:dirs
#   int:port
#
# Usage Example:
#   OPTIONS_CONFIG="
#     NAME        | --name         | -n   | required | string |          | Name of the project
#     RETRIES     | --retry        | -r   | optional | int    | 3        | Number of retries
#     IS_ENABLED  | --enabled      | -e   | optional | flag   |          | Enable the feature
#     SILENT_MODE | --silent-mode  | -slm | optional | toggle | disabled | Run in silent mode
#   "
#
#   eval "$(parse_options "$OPTIONS_CONFIG")"

[[ -n "$__IS_CLI_OPTIONS_SH_INCLUDED" ]] && return 0
__IS_CLI_OPTIONS_SH_INCLUDED=1

CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$CLI_DIR/.."

source "$BIN_DIR/cli/help.sh"

source "$BIN_DIR/utils/log.sh"
source "$BIN_DIR/utils/flags.sh"

parse_options() {
  intercept_help \
    --name "parse_options" \
    --description "Generates JIT bash parsing logic from a declarative configuration string." \
    --usage "parse_options <config_string> [error_action]" \
    -- "$@"

  local config="$1"
  local error_action="${2:-exit 1}"
  local var_name long_opt short_opt requirement type default_value description base_type

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value description; do
    var_name="${var_name// /}"
    type="${type// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    base_type="${type%%:*}"

    if [[ "$base_type" != "flag" ]]; then
      default_value="${default_value#"${default_value%%[![:space:]]*}"}"
      default_value="${default_value%"${default_value##*[![:space:]]}"}"
    fi

    if [[ "$base_type" == "flag" ]]; then
      echo "$var_name=0"
    elif [[ "$base_type" == "toggle" ]]; then
      if [[ -n "$default_value" ]] && is_enabled "$default_value" 2> /dev/null; then
        echo "$var_name=1"
      else
        echo "$var_name=0"
      fi
    else
      echo "$var_name=\"$default_value\""
    fi
  done <<< "$config"

  echo 'while [[ "$#" -gt 0 ]]; do'
  echo '  case "$1" in'

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value description; do
    var_name="${var_name// /}"
    long_opt="${long_opt// /}"
    short_opt="${short_opt// /}"
    type="${type// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    base_type="${type%%:*}"

    if [[ -n "$short_opt" && "$short_opt" != "$long_opt" ]]; then
      echo "    $long_opt | $short_opt)"
    else
      echo "    $long_opt)"
    fi

    if [[ "$base_type" == "flag" ]]; then
      echo "      $var_name=1"
      echo "      shift 1"
    else
      echo "      if [[ -z \"\$2\" || \"\$2\" == -* ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' requires an argument.\" -ll \"\${log_level:-1}\"; $error_action; fi"

      if [[ "$base_type" == "int" ]]; then
        echo "      if ! [[ \"\$2\" =~ ^[1-9][0-9]*\$ ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' must be an integer >= 1.\" -ll \"\${log_level:-1}\"; $error_action; fi"
        echo "      $var_name=\"\$2\""
      elif [[ "$base_type" == "toggle" ]]; then
        echo "      if is_enabled \"\$2\"; then $var_name=1; else $var_name=0; fi"
      else
        echo "      $var_name=\"\$2\""
      fi
      echo "      shift 2"
    fi
    echo "      ;;"
  done <<< "$config"

  echo "    *)"
  echo "      log -e -c \"gray\" -m \"Error: Unknown argument passed: \$1\" -ll \"\${log_level:-1}\""
  echo "      shift 1"
  echo "      $error_action"
  echo "      ;;"
  echo '  esac'
  echo 'done'

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value description; do
    var_name="${var_name// /}"
    long_opt="${long_opt// /}"
    short_opt="${short_opt// /}"
    requirement="${requirement// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    if [[ "$requirement" == "required" ]]; then
      echo "if [[ -z \"\$$var_name\" ]]; then log -e -c \"gray\" -m \"Error: The '$long_opt' option is required.\" -ll \"\${log_level:-1}\"; $error_action; fi"
    fi
  done <<< "$config"
}
