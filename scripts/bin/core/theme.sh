#!/usr/bin/env bash
# shellcheck disable=SC2034

# A centralized repository of ANSI color escape codes and unicode icons.
# Ensures consistent visual output across all shell-based CLI utilities.

[[ -n "$__IS_CORE_THEME_SH_INCLUDED" ]] && return 0
__IS_CORE_THEME_SH_INCLUDED=1

# --- Colors ---
if [[ "$NO_COLOR" == "1" ]]; then
  COLOR_BLUE=''
  COLOR_GRAY=''
  COLOR_GREEN=''
  COLOR_ORANGE=''
  COLOR_RED=''
  COLOR_RESET=''
  COLOR_VIOLET=''
  COLOR_WHITE=''
  COLOR_WHITE_BOLD=''
  COLOR_YELLOW=''
else
  COLOR_BLUE='\033[0;34m'
  COLOR_GRAY='\033[0;90m'
  COLOR_GREEN='\033[0;32m'
  COLOR_ORANGE='\033[38;2;251;211;141m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m'
  COLOR_VIOLET='\033[0;35m'
  COLOR_WHITE='\033[0;37m'
  COLOR_WHITE_BOLD='\033[1;37m'
  COLOR_YELLOW='\033[0;33m'
fi

# --- Icons ---
if [[ "$NO_UNICODE" == "1" ]]; then
  # Fallback ASCII Process Icons
  ICON_DONE="${COLOR_GREEN}[DONE]${COLOR_RESET}"
  ICON_ERROR="${COLOR_RED}[ERROR]${COLOR_RESET}"
  ICON_FAIL="${COLOR_RED}[FAIL]${COLOR_RESET}"
  ICON_INFO="${COLOR_BLUE}[INFO]${COLOR_RESET}"
  ICON_LINK="${COLOR_BLUE}[LINK]${COLOR_RESET}"
  ICON_PROGRESS="${COLOR_BLUE}[WAIT]${COLOR_RESET}"
  ICON_SKIP="${COLOR_GRAY}[SKIP]${COLOR_RESET}"
  ICON_SUCCESS="${COLOR_GREEN}[OK]  ${COLOR_RESET}"
  ICON_TIP="${COLOR_VIOLET}[TIP] ${COLOR_RESET}"
  ICON_WARNING="${COLOR_YELLOW}[WARN]${COLOR_RESET}"

  # Fallback ASCII Specific Icons
  ICON_CLEAN=''
  ICON_DOCS=''
  ICON_DOCKER=''
  ICON_ENV=''
  ICON_HUSKY=''
  ICON_JSON=''
  ICON_FILE=''
  ICON_PACKAGE=''
  ICON_SECURE=''
  ICON_VOLTA=''
else
  # Standard Unicode Process Icons
  ICON_DONE='✨'
  ICON_ERROR='❌'
  ICON_FAIL='❌'
  ICON_INFO='ℹ️ '
  ICON_LINK='🔗'
  ICON_PROGRESS='⏳'
  ICON_SKIP='⏩'
  ICON_SUCCESS='✅'
  ICON_TIP='💡'
  ICON_WARNING='⚠️ '

  # Standard Unicode Specific Icons
  ICON_CLEAN='🧹'
  ICON_DOCS='📖'
  ICON_DOCKER='🐳'
  ICON_ENV='🔐'
  ICON_HUSKY='🐶'
  ICON_JSON='📝'
  ICON_FILE='📄'
  ICON_PACKAGE='📦'
  ICON_SECURE='🛡️ '
  ICON_VOLTA='⚡️'
fi
