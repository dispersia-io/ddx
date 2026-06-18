#!/bin/bash

# A centralized repository of ANSI color escape codes.
# Ensures consistent color output across all shell-based CLI utilities.

[[ -n "$__IS_CORE_THEME_SH_INCLUDED" ]] && return 0
__IS_CORE_THEME_SH_INCLUDED=1

# --- Colors ---
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_GRAY='\033[0;90m'
COLOR_RESET='\033[0m'

# --- Process Icons ---
ICON_SUCCESS='✅'
ICON_WARNING='⚠️ '
ICON_ERROR='❌'
ICON_INFO='ℹ️'
ICON_PROGRESS='⏳'
ICON_SKIP='⏩'
ICON_DONE='✨'
ICON_TIP='💡'
ICON_LINK='🔗'
ICON_CLEAN='🧹'

# --- Specific Icons ---
ICON_ENV='🔐'
ICON_PACKAGE='📦'
ICON_DOCS='📖'
ICON_JSON='📝'
ICON_DOCKER='🐳'
ICON_VOLTA='⚡️'
ICON_HUSKY='🐶'
ICON_SECURE='🛡️ '
