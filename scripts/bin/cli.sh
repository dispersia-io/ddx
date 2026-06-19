#!/bin/bash

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/utils/log.sh"

print_root_help() {
  echo -e "${COLOR_WHITE_BOLD}ddx${COLOR_RESET} - Dispersia Developer Experience CLI"
  echo ""
  echo -e "${COLOR_WHITE_BOLD}Usage:${COLOR_RESET}"
  echo -e "  ${COLOR_GRAY}\$${COLOR_ORANGE} ddx <command> [subcommand] [options]${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_WHITE_BOLD}Commands:${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}env     init${COLOR_RESET}                 ${COLOR_GRAY}Initialize local .env files${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}deps    install${COLOR_RESET}              ${COLOR_GRAY}Install workspace dependencies${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}        scan${COLOR_RESET}                 ${COLOR_GRAY}Scan project dependencies${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}node    pin${COLOR_RESET}                  ${COLOR_GRAY}Pin Node.js version${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}        validate${COLOR_RESET}             ${COLOR_GRAY}Validate current Node.js environment${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}pm      pin${COLOR_RESET}                  ${COLOR_GRAY}Pin Package Manager version${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}symlink create${COLOR_RESET}               ${COLOR_GRAY}Create project symlinks${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_WHITE_BOLD}Utilities:${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}log${COLOR_RESET}                          ${COLOR_GRAY}Print formatted log message${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_WHITE_BOLD}CLI Core & Internal:${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}cli     options parse${COLOR_RESET}        ${COLOR_GRAY}Parse raw CLI arguments into bash-eval string${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}        help intercept${COLOR_RESET}       ${COLOR_GRAY}Intercept --help flag and render formatting${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}        help print${COLOR_RESET}           ${COLOR_GRAY}Print raw help table directly${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}execute task${COLOR_RESET}                 ${COLOR_GRAY}Execute specific pipeline task${COLOR_RESET}"
  echo -e "  ${COLOR_ORANGE}        subtask${COLOR_RESET}              ${COLOR_GRAY}Execute specific pipeline subtask${COLOR_RESET}"
  echo ""
  echo -e "${COLOR_GRAY}Run 'ddx <command> [subcommand] --help' for more information on a specific command.${COLOR_RESET}"
  echo ""
}

throw_unknown_command() {
  local cmd_path="$1"
  log -cl -e -m "Error: Unknown or missing command '$cmd_path'"
  log -c "gray" -m "Run 'ddx --help' for a list of available commands."
  exit 1
}

if [ -z "$1" ]; then
  print_root_help
  exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
  "env" | "environment")
    SUBCOMMAND="$1"
    shift

    case "$SUBCOMMAND" in
      "init") bash "$BIN_DIR/env/init.sh" "$@" ;;
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "deps" | "dependencies")
    SUBCOMMAND="$1"
    shift

    case "$SUBCOMMAND" in
      "i" | "install") bash "$BIN_DIR/deps/install.sh" "$@" ;;
      "scan") bash "$BIN_DIR/deps/scan.sh" "$@" ;;
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "pm" | "package-manager")
    SUBCOMMAND="$1"
    shift

    case "$SUBCOMMAND" in
      "pin") bash "$BIN_DIR/package-manager/pin.sh" "$@" ;;
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "symlink" | "symlinks")
    SUBCOMMAND="$1"
    shift

    case "$SUBCOMMAND" in
      "create") bash "$BIN_DIR/symlink/create.sh" "$@" ;;
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "exec" | "execute")
    source "$BIN_DIR/tasks/execute.sh"
    execute "$@"
    ;;

  "log")
    source "$BIN_DIR/utils/log.sh"
    log "$@"
    ;;

  "cli")
    SUBCOMMAND="$1"
    shift

    case "$SUBCOMMAND" in
      "options")
        ACTION="$1"
        shift

        case "$ACTION" in
          "parse")
            source "$BIN_DIR/cli/options.sh"
            parse_options "$@"
            ;;
          *) throw_unknown_command "$COMMAND $SUBCOMMAND $ACTION" ;;
        esac
        ;;

      "help")
        ACTION="$1"
        shift

        case "$ACTION" in
          "intercept")
            source "$BIN_DIR/cli/help.sh"
            intercept_help "$@"
            ;;
          "print")
            source "$BIN_DIR/cli/help.sh"
            print_help "$@"
            ;;
          *) throw_unknown_command "$COMMAND $SUBCOMMAND $ACTION" ;;
        esac
        ;;
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "-h" | "--help" | "help")
    print_root_help
    exit 0
    ;;

  *)
    throw_unknown_command "$COMMAND"
    ;;
esac
