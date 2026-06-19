#!/bin/bash

[[ -n "$__IS_UTILS_FLAGS_SH_INCLUDED" ]] && return 0
__IS_UTILS_FLAGS_SH_INCLUDED=1

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$UTILS_DIR/log.sh"

# Validates and checks if the provided value represents an enabled flag state.
# Accepts typical boolean markers (case-insensitive).
#
# Truthy values: 1, "true", "y", "yes", "on", "enable", "enabled" -> Returns 0
# Falsy values:  0, "false", "n", "no", "off", "disable", "disabled", or empty "" -> Returns 1
# Any other value will print an error to stderr and terminate the script.
#
# Arguments:
#   $1 - The value to validate.
#
# Returns:
#   0 - If the value is truthy.
#   1 - If the value is falsy or empty.
#
# Exits:
#   1 - If the value is unrecognized.
#
# Usage:
#   if is_enabled "$IS_SILENT"; then
#     echo "Silent mode enabled"
#   fi
is_enabled() {
  case "$1" in
    1 | [tT][rR][uU][eE] | [yY] | [yY][eE][sS] | [oO][nN] | [eE][nN][aA][bB][lL][eE] | [eE][nN][aA][bB][lL][eE][dD])
      return 0
      ;;
    "" | 0 | [fF][aA][lL][sS][eE] | [nN] | [nN][oO] | [oO][fF][fF] | [dD][iI][sS][aA][bB][lL][eE] | [dD][iI][sS][aA][bB][lL][eE][dD])
      return 1
      ;;
    *)
      log -cl -e -m "Error: Unrecognized flag value '$1'."
      exit 1
      ;;
  esac
}

# Validates and checks if the provided value represents a truthy state.
# Accepts typical boolean markers (case-insensitive).
#
# Truthy values: 1, "true" -> Returns 0
# Falsy values:  0, "false", or empty "" -> Returns 1
# Any other value will print an error to stderr and terminate the script.
#
# Arguments:
#   $1 - The value to validate.
#
# Returns:
#   0 - If the value is truthy.
#   1 - If the value is falsy or empty.
#
# Exits:
#   1 - If the value is unrecognized.
#
# Usage:
#   if is_truthy "$IS_SILENT"; then
#     echo "Silent mode enabled"
#   fi
is_truthy() {
  case "$1" in
    1 | [tT][rR][uU][eE]) return 0 ;;
    "" | 0 | [fF][aA][lL][sS][eE]) return 1 ;;
    *)
      log -cl -e -m "Error: Unrecognized boolean-like value '$1'."
      exit 1
      ;;
  esac
}

# Validates and checks if the provided value represents a falsy state.
# Accepts typical boolean markers (case-insensitive).
#
# Falsy values:  0, "false", or empty "" -> Returns 0
# Truthy values: 1, "true" -> Returns 1
# Any other value will print an error to stderr and terminate the script.
#
# Arguments:
#   $1 - The value to validate.
#
# Returns:
#   0 - If the value is falsy or empty.
#   1 - If the value is truthy.
#
# Exits:
#   1 - If the value is unrecognized.
#
# Usage:
#   if is_falsy "$IS_SILENT"; then
#     echo "Verbose mode enabled"
#   fi
is_falsy() {
  ! is_truthy "$1"
}
