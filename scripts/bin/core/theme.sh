#!/bin/bash

# A centralized repository of ANSI color escape codes.
# Ensures consistent color output across all shell-based CLI utilities.

[[ -n "$__IS_CORE_THEME_SH_INCLUDED" ]] && return 0
__IS_CORE_THEME_SH_INCLUDED=1

# --- Colors ---
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

# --- Process Icons ---
ICON_DONE='✨'
ICON_ERROR='❌'
ICON_INFO='ℹ️'
ICON_LINK='🔗'
ICON_PROGRESS='⏳'
ICON_SKIP='⏩'
ICON_SUCCESS='✅'
ICON_TIP='💡'
ICON_WARNING='⚠️ '

# --- Specific Icons ---
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
