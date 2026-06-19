#!/bin/bash

[[ -n "$__IS_CLI_HELP_SH_INCLUDED" ]] && return 0
__IS_CLI_HELP_SH_INCLUDED=1

CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$CLI_DIR/.."

source "$BIN_DIR/core/theme.sh"

__trim() {
  local var="$1"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf "%s" "$var"
}

# Renders and formats the CLI help screen, parsing declarative configuration for visually aligned output.
print_help() {
  intercept_help \
    --name "ddx cli help print" \
    --description "Renders and formats the CLI help screen with aligned options and descriptions." \
    --usage "ddx cli help print <command_name> <description> <usage> [config]" \
    -- "$@"

  local cmd_name="$1"
  local description="$2"
  local usage="$3"
  local config="$4"

  echo "$description"
  echo ""
  echo -e "${COLOR_WHITE_BOLD}Usage:${COLOR_RESET}"
  echo -e "  ${COLOR_GRAY}\$${COLOR_ORANGE} $usage${COLOR_RESET}"
  echo ""

  if [ -n "$config" ]; then
    echo -e "${COLOR_WHITE_BOLD}Options:${COLOR_RESET}"

    local max_short_len=0
    local has_required=false

    while IFS='|' read -r var long short req type default desc || [ -n "$var" ]; do
      var=$(__trim "$var")
      [ -z "$var" ] && continue

      short=$(__trim "$short")
      long=$(__trim "$long")
      req=$(__trim "$req")

      if [[ "$req" == "required" ]]; then
        has_required=true
      fi

      local total_short=""
      if [[ -n "$short" && -n "$long" ]]; then
        total_short="$short,"
      elif [[ -n "$short" ]]; then
        total_short="$short"
      fi

      if ((${#total_short} > max_short_len)); then
        max_short_len=${#total_short}
      fi
    done <<< "$config"

    local short_width=$((max_short_len + 1))
    ((short_width < 1)) && short_width=1

    echo "$config" | while IFS='|' read -r var long short req type default desc || [ -n "$var" ]; do
      var=$(__trim "$var")
      [ -z "$var" ] && continue

      long=$(__trim "$long")
      short=$(__trim "$short")
      req=$(__trim "$req")
      type=$(__trim "$type")
      default=$(__trim "$default")
      desc=$(__trim "$desc")

      local short_str=""
      if [[ -n "$short" && -n "$long" ]]; then
        short_str="$short,"
      elif [[ -n "$short" ]]; then
        short_str="$short"
      fi

      local type_str=""
      if [[ -n "$type" && "$type" != "flag" ]]; then
        local placeholder="$type"
        [[ "$type" == *":"* ]] && placeholder="${type#*:}"
        type_str="<$placeholder>"
      fi

      local short_pad long_pad type_pad
      printf -v short_pad "%-${short_width}s" "$short_str"
      printf -v long_pad "%-18s" "$long"
      printf -v type_pad "%-14s" "$type_str"

      local req_marker=""
      if [[ "$has_required" == true ]]; then
        if [[ "$req" == "required" ]]; then
          req_marker="${COLOR_RED}*${COLOR_RESET}  "
        else
          req_marker="   "
        fi
      fi

      local meta=""
      if [ -n "$default" ]; then
        meta="(Default: $default)"
      fi

      local full_desc="$desc"
      if [ -n "$meta" ]; then
        if [ -n "$full_desc" ]; then
          full_desc="$full_desc $meta"
        else
          full_desc="$meta"
        fi
      fi

      echo -e "  ${COLOR_ORANGE}${short_pad}${long_pad}${COLOR_GRAY}${type_pad}${COLOR_RESET}${req_marker}${COLOR_GRAY}${full_desc}${COLOR_RESET}"
    done
    echo ""
  fi
}

# Scans provided arguments for help flags (-h, --help) and triggers the help formatter before exiting.
intercept_help() {
  local name=""
  local description=""
  local usage=""
  local config=""
  local user_args=()

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --name | -n)
        name="$2"
        shift 2
        ;;
      --description | -d)
        description="$2"
        shift 2
        ;;
      --usage | -u)
        usage="$2"
        shift 2
        ;;
      --options | -o)
        config="$2"
        shift 2
        ;;
      --)
        shift
        user_args+=("$@")
        break
        ;;
      *)
        user_args+=("$1")
        shift 1
        ;;
    esac
  done

  local help_requested=false
  for arg in "${user_args[@]}"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
      help_requested=true
      break
    fi
  done

  if [ "$help_requested" = true ]; then
    print_help "$name" "$description" "$usage" "$config"
    exit 0
  fi
}
