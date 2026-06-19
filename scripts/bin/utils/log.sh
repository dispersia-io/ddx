#!/bin/bash

# A universal logging utility for project scripts.
#
# NOTE: This script is designed strictly for internal use and coordination
# between other scripts; it is not intended for standalone execution.
#
# Options:
#   --msg, -m              : [Required] Message text to display
#   --log-level, -ll       : [Optional] Indentation level: 1 (none), 2 (3 spaces), 3 (6 spaces)
#   --icon, -ic            : [Optional] Overrides the default icon for the message
#   --color, -c            : [Optional] Overrides the color (green, red, yellow, blue, gray)
#   --success, -s          : [Optional] Sets type to SUCCESS (Green, ✅)
#   --warn, -w             : [Optional] Sets type to WARNING (Yellow, ⚠️)
#   --error, -e            : [Optional] Sets type to ERROR (Red, ❌)
#   --info, -i             : [Optional] Sets type to INFO (Gray, ℹ️)
#   --clear, -cl           : [Optional] Clears the current line before printing (\r\033[K)
#   --inline, -in          : [Optional] Prints the message without a trailing newline
#   --silent-mode, -slm    : [Optional] Suppresses all output. Accepts boolean-like value.
#
# Usage Variants:
#
# 1. Standard Log:
#    Example: log -s -m "Dependencies installed successfully"
#
# 2. Status with Progress (Inline):
#    Example: log --inline --icon "⏳" --msg "Processing data..."
#    Next log: log --clear --success --msg "Data processed"
#
# 3. Indented Error:
#    Example: log -e -c "gray" -m "Failed to locate configuration file" -ll 2

[[ -n "$__IS_UTILS_LOG_SH_INCLUDED" ]] && return 0
__IS_UTILS_LOG_SH_INCLUDED=1

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$UTILS_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/flags.sh"

log() {
  local msg log_level icon color_name is_success is_warn is_error is_info clear_line is_inline silent_mode

  local OPTIONS_CONFIG="
    msg         | --msg         | -m    | required | string | 
    log_level   | --log-level   | -ll   | optional | int    | 1
    icon        | --icon        | -ic   | optional | string | 
    color_name  | --color       | -c    | optional | string | 
    is_success  | --success     | -s    | optional | flag   | 
    is_warn     | --warn        | -w    | optional | flag   | 
    is_error    | --error       | -e    | optional | flag   | 
    is_info     | --info        | -i    | optional | flag   | 
    clear_line  | --clear       | -cl   | optional | flag   | 
    is_inline   | --inline      | -in   | optional | flag   | 
    silent_mode | --silent-mode | -slm  | optional | toggle | disabled
  "

  eval "$(parse_options "$OPTIONS_CONFIG" "return 0")"

  case "$silent_mode" in
    1 | [tT][rR][uU][eE] | [yY] | [yY][eE][sS] | [oO][nN] | [eE][nN][aA][bB][lL][eE] | [eE][nN][aA][bB][lL][eE][dD])
      return 0
      ;;
    "" | 0 | [fF][aA][lL][sS][eE] | [nN] | [nN][oO] | [oO][fF][fF] | [dD][iI][sS][aA][bB][lL][eE] | [dD][iI][sS][aA][bB][lL][eE][dD]) ;;
    *)
      echo "Error: Unrecognized '--silent-mode' option value '$silent_mode'. Expected boolean-like value." >&2
      exit 1
      ;;
  esac

  local type_icon=""
  local type_color=""

  if is_truthy "$is_success"; then
    type_icon="$ICON_SUCCESS"
    type_color="$COLOR_GREEN"
  elif is_truthy "$is_warn"; then
    type_icon="$ICON_WARNING"
    type_color="$COLOR_YELLOW"
  elif is_truthy "$is_error"; then
    type_icon="$ICON_ERROR"
    type_color="$COLOR_RED"
  elif is_truthy "$is_info"; then
    type_icon="$ICON_INFO"
    type_color="$COLOR_GRAY"
  fi

  local final_color="$type_color"
  case "$color_name" in
    green) final_color="$COLOR_GREEN" ;;
    red) final_color="$COLOR_RED" ;;
    yellow) final_color="$COLOR_YELLOW" ;;
    blue) final_color="$COLOR_BLUE" ;;
    gray) final_color="$COLOR_GRAY" ;;
  esac

  local final_icon="${icon:-$type_icon}"

  local indent=""
  if [[ "$log_level" =~ ^[1-9][0-9]*$ ]]; then
    indent=$(printf '%*s' "$(((log_level - 1) * 3))" "")
  fi

  local start=""
  is_truthy "$clear_line" && start=$'\r\033[K'

  local end=$'\n'
  is_truthy "$is_inline" && end=""

  local reset_color="${COLOR_RESET:-\033[0m}"

  if [[ -n "$final_icon" ]]; then
    printf "%b${final_color}%s%b %b${reset_color}%b" "$start" "$indent" "$final_icon" "$msg" "$end"
  else
    printf "%b${final_color}%s%b${reset_color}%b" "$start" "$indent" "$msg" "$end"
  fi
}
