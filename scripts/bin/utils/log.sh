#!/usr/bin/env bash

# A universal logging utility for project scripts.
#
# Options:
#   * -m, --message          : Message text to display
#     -ic, --icon            : Overrides the default icon for the message
#     -c, --color            : Overrides the color (green, red, yellow, blue, gray)
#     -s, --success          : Sets type to SUCCESS
#     -w, --warn             : Sets type to WARNING
#     -e, --error            : Sets type to ERROR
#     -i, --info             : Sets type to INFO
#     -cl, --clear           : Clears the current line before printing (\r\033[K)
#     -in, --inline          : Prints the message without a trailing newline
#     -ll, --log-level       : Logging indentation level
#     -slm, --silent-mode    : Suppresses all output
#
# Usage:
#   ddx log -m <string> [options]
#
# Examples:
#   ddx log -m "Installing dependencies..."
#   ddx log -m -s "Dependencies installed successfully"
#   ddx log -m -e "Failed to install dependencies"

[[ -n "$__IS_UTILS_LOG_SH_INCLUDED" ]] && return 0
__IS_UTILS_LOG_SH_INCLUDED=1

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$UTILS_DIR/.."

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"
source "$BIN_DIR/cli/options.sh"

source "$BIN_DIR/utils/flags.sh"

log() {
  local OPTIONS_CONFIG="
    message     | --message     | -m    | required | string      |          | Message text to display
    icon        | --icon        | -ic   | optional | string      |          | Overrides the default icon
    color_name  | --color       | -c    | optional | string:name |          | Overrides the text color
    is_success  | --success     | -s    | optional | flag        |          | Sets type to SUCCESS
    is_warn     | --warn        | -w    | optional | flag        |          | Sets type to WARNING
    is_error    | --error       | -e    | optional | flag        |          | Sets type to ERROR
    is_info     | --info        | -i    | optional | flag        |          | Sets type to INFO
    clear_line  | --clear       | -cl   | optional | flag        |          | Clears the current line before printing
    is_inline   | --inline      | -in   | optional | flag        |          | Prints without a trailing newline
    log_level   | --log-level   | -ll   | optional | int         | 1        | Logging indentation level
    silent_mode | --silent-mode | -slm  | optional | toggle      | disabled | Suppresses all output
  "

  intercept_help \
    --name "ddx log" \
    --description "A universal logging utility for project scripts" \
    --usage "log -m <string> [options]" \
    --options "$OPTIONS_CONFIG" \
    -- "$@"

  local message icon color_name is_success is_warn is_error is_info clear_line is_inline log_level silent_mode

  eval "$(parse_options "$OPTIONS_CONFIG" "return 0")"

  case "$silent_mode" in
    1 | [tT][rR][uU][eE] | [yY] | [yY][eE][sS] | [oO][nN] | [eE][nN][aA][bB][lL][eE] | [eE][nN][aA][bB][lL][eE][dD])
      return 0
      ;;
    "" | 0 | [fF][aA][lL][sS][eE] | [nN] | [nN][oO] | [oO][fF][fF] | [dD][iI][sS][aA][bB][lL][eE] | [dD][iI][sS][aA][bB][lL][eE][dD]) ;;
    *)
      echo "Error: Unrecognized '--silent-mode' option value '$silent_mode'" >&2
      exit 1
      ;;
  esac

  local type_icon=""
  local type_color=""
  local descriptor=1

  if is_truthy "$is_success"; then
    type_icon="$ICON_SUCCESS"
    type_color="$COLOR_GREEN"
  elif is_truthy "$is_warn"; then
    type_icon="$ICON_WARNING"
    type_color="$COLOR_YELLOW"
    descriptor=2
  elif is_truthy "$is_error"; then
    type_icon="$ICON_ERROR"
    type_color="$COLOR_RED"
    descriptor=2
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
    printf "%b${final_color}%s%b %b${reset_color}%b" "$start" "$indent" "$final_icon" "$message" "$end" >&"$descriptor"
  else
    printf "%b${final_color}%s%b${reset_color}%b" "$start" "$indent" "$message" "$end" >&"$descriptor"
  fi
}
