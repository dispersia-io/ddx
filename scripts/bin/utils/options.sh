#!/bin/bash

# Generates JIT bash parsing logic from a declarative configuration string.
# Automates variable initialization, default values, type validation,
# binary flags handling, and required argument checks.
#
# Format:
# VAR_NAME | <long_opt> | <short_opt> | <requirement> (required/optional) | <type> (string/int/flag) | <default_value>
#
# Types:
#   string    : Standard text argument.
#   int       : Validates that the argument is an integer >= 1.
#   flag      : Binary switch (0 by default, 1 if passed). Ignores 'default_value' column.
#
# Usage Example:
#   OPTIONS_CONFIG="
#     TASK_NAME | --name  | -n | required | string |
#     RETRIES   | --retry | -r | optional | int    | 3
#     SILENT    | --quiet | -q | optional | flag   |
#   "
#
#   # For global script scope (uses 'exit 1' on error):
#   eval "$(generate_parser "$OPTIONS_CONFIG")"
#
#   # For function scope (uses 'return 1' on error to protect parent script):
#   local TASK_NAME RETRIES SILENT
#   eval "$(generate_parser "$OPTIONS_CONFIG" "return 1")"

parse_options() {
  local config="$1"
  local error_action="${2:-exit 1}"

  while IFS='|' read -r var_name long_opt short_opt requirement type default_value; do
    var_name="${var_name// /}"
    type="${type// /}"
    [[ -z "$var_name" || "$var_name" == \#* ]] && continue

    if [[ "$type" == "flag" ]]; then
      echo "$var_name=0"
    else
      default_value="${default_value#"${default_value%%[![:space:]]*}"}"
      default_value="${default_value%"${default_value##*[![:space:]]}"}"
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
      echo "      if [[ -z \"\$2\" || \"\$2\" == -* ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' requires an argument.\"; $error_action; fi"
      if [[ "$type" == "int" ]]; then
        echo "      if ! [[ \"\$2\" =~ ^[1-9][0-9]*\$ ]]; then log -e -c \"gray\" -m \"Error: Option '\$1' must be an integer >= 1.\"; $error_action; fi"
      fi
      echo "      $var_name=\"\$2\""
      echo "      shift 2"
    fi
    echo "      ;;"
  done <<< "$config"

  echo "    *)"
  echo "      log -w -l \"\${level:-2}\" -c \"gray\" -m \"Warning: Unknown argument passed: \$1\""
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
      echo "if [[ -z \"\$$var_name\" ]]; then log -e -c \"gray\" -m \"Error: The '$long_opt' option is required.\"; $error_action; fi"
    fi
  done <<< "$config"
}
