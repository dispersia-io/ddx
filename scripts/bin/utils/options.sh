#!/bin/bash

# Generates JIT bash parsing logic from a declarative configuration string.
# Automates variable initialization, default values, type validation,
# binary flags handling, and required argument checks.
#
# Format:
# VAR_NAME | <long_opt> | <short_opt> | <requirement> (required/optional) | <type> (string/int/flag/flag_value) | <default_value>
#
# Types:
#   string    : Standard text argument.
#   int       : Validates that the argument is an integer >= 1.
#   flag      : Binary switch (0 by default, 1 if passed without arguments). Ignores 'default_value'.
#   flag_value: Boolean-like argument. Accepts any value, validates via is_flag_on, and normalizes to 0 or 1.
#
# Usage Example:
#   OPTIONS_CONFIG="
#     NAME        | --name         | -n   | required | string     |
#     RETRIES     | --retry        | -r   | optional | int        | 3
#     IS_ENABLED  | --enabled      | -e   | optional | flag       |
#     SILENT_MODE | --silent-mode  | -slm | optional | flag_value | disabled
#   "
#
#   # For global script scope (uses 'exit 1' on error):
#   eval "$(parse_options "$OPTIONS_CONFIG")"
#
#   # For function scope (uses 'return 1' on error to protect parent script):
#   local NAME RETRIES IS_ENABLED SILENT_MODE
#   eval "$(parse_options "$OPTIONS_CONFIG" "return 1")"

[[ -n "$__IS_UTILS_OPTIONS_SH_INCLUDED" ]] && return 0
__IS_UTILS_OPTIONS_SH_INCLUDED=1

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/flags.sh"

parse_options() {
  local config="$1"
  local error_action="${2:-exit 1}"

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value; do
    var_name="${var_name// /}"
    type="${type// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    if [[ "$type" != "flag" ]]; then
      default_value="${default_value#"${default_value%%[![:space:]]*}"}"
      default_value="${default_value%"${default_value##*[![:space:]]}"}"
    fi

    if [[ "$type" == "flag" ]]; then
      echo "$var_name=0"
    elif [[ "$type" == "flag_value" ]]; then
      if [[ -n "$default_value" ]] && is_flag_on "$default_value" 2> /dev/null; then
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

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value; do
    var_name="${var_name// /}"
    long_opt="${long_opt// /}"
    short_opt="${short_opt// /}"
    type="${type// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    if [[ -n "$short_opt" && "$short_opt" != "$long_opt" ]]; then
      echo "    $long_opt | $short_opt)"
    else
      echo "    $long_opt)"
    fi

    if [[ "$type" == "flag" ]]; then
      echo "      $var_name=1"
      echo "      shift 1"
    else
      echo "      if [[ -z \"\$2\" || \"\$2\" == -* ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' requires an argument.\" -ll \"\${log_level:-1}\"; $error_action; fi"

      if [[ "$type" == "int" ]]; then
        echo "      if ! [[ \"\$2\" =~ ^[1-9][0-9]*\$ ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' must be an integer >= 1.\" -ll \"\${log_level:-1}\"; $error_action; fi"
        echo "      $var_name=\"\$2\""
      elif [[ "$type" == "flag_value" ]]; then
        echo "      if is_flag_on \"\$2\"; then $var_name=1; else $var_name=0; fi"
      else
        echo "      $var_name=\"\$2\""
      fi
      echo "      shift 2"
    fi
    echo "      ;;"
  done <<< "$config"

  echo "    *)"
  echo "      log -e -c \"gray\" -m \"Error: Unknown argument passed: \$1\" -ll \"\${log_level:-1}\""
  echo "      $error_action"
  echo "      ;;"
  echo '  esac'
  echo 'done'

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value; do
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
