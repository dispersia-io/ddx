#!/usr/bin/env bash

# Central entry point and router for the Dispersia Developer Experience (ddx) CLI.
# Manages local environment setup, workspaces dependencies, packages pinning,
# symlinks generation, and core internal pipeline utilities.
#
# Usage:
#   ddx <command> [subcommand] [options]
#   ddx [command] --help

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT_DIR="$BIN_DIR/../.."

export NO_COLOR=0
export NO_UNICODE=0
NEW_ARGS=()

for arg in "$@"; do
  if [[ "$arg" == "--no-color" || "$arg" == "-nc" ]]; then
    export NO_COLOR=1
  elif [[ "$arg" == "--no-unicode" || "$arg" == "-nu" ]]; then
    export NO_UNICODE=1
  else
    NEW_ARGS+=("$arg")
  fi
done

set -- "${NEW_ARGS[@]}"

source "$BIN_DIR/core/root.sh"
source "$BIN_DIR/core/theme.sh"

source "$BIN_DIR/cli/help.sh"

source "$BIN_DIR/utils/log.sh"

throw_unknown_command() {
  local cmd_path="$1"
  log -cl -e -m "Error: Unknown or missing command '$cmd_path'"
  log -c "gray" -m "Run 'ddx --help' for a list of available commands"
  exit 1
}

print_root_help_command() {
  local command="$1"
  local subcommand="$2"
  local description="$3"
  printf "   ${COLOR_ORANGE}%-20s %-30s${COLOR_RESET} ${COLOR_GRAY}%s${COLOR_RESET}\n" "$command" "$subcommand" "$description"
}

print_root_help() {
  echo -e "${COLOR_WHITE_BOLD}ddx${COLOR_RESET} - Dispersia Developer Experience CLI"
  echo ""

  echo -e "${COLOR_WHITE_BOLD}Usage:${COLOR_RESET}"
  echo -e "  ${COLOR_GRAY}\$${COLOR_ORANGE} ddx <command> [subcommand] [options]${COLOR_RESET}"
  echo ""

  echo -e "${COLOR_WHITE_BOLD}Commands:${COLOR_RESET}"
  print_root_help_command "e,  env            " "init (i)" "Initialize local .env files"
  # GEN:HELP:ENV
  print_root_help_command "d,  deps           " "install (i) " "Install workspace dependencies"
  print_root_help_command "                   " "scan (s)    " "Scan project dependencies"
  # GEN:HELP:DEPS
  print_root_help_command "n,  node           " "pin (p)     " "Pin Node.js version"
  print_root_help_command "                   " "validate (v)" "Validate current Node.js environment"
  # GEN:HELP:NODE
  print_root_help_command "pm, package-manager" "pin (p)     " "Pin Package Manager version"
  # GEN:HELP:PM
  print_root_help_command "sl, symlink        " "create (c)  " "Create project symlinks"
  echo ""
  # GEN:HELP:SYMLINK
  # GEN:HELP:NEW_COMMAND

  echo -e "${COLOR_WHITE_BOLD}Utilities:${COLOR_RESET}"
  print_root_help_command "x,  exec" "task (t)   " "Execute specific pipeline task"
  print_root_help_command "        " "subtask (s)" "Execute specific pipeline subtask"
  print_root_help_command "l,  log " "           " "Print formatted log message"
  echo ""

  echo -e "${COLOR_WHITE_BOLD}CLI Core & Internal:${COLOR_RESET}"
  print_root_help_command "c,  cli" "options (opts) parse (p)" "Parse raw CLI arguments into bash-eval string"
  print_root_help_command "       " "help (h) intercept (i)  " "Intercept --help flag and render formatting"
  print_root_help_command "       " "help (h) print (p)      " "Print raw help table directly"
  echo ""

  echo -e "${COLOR_GRAY}Run 'ddx <command> [subcommand] --help' for more information on a specific command${COLOR_RESET}"
  echo ""
}

if [[ -z "$1" || "$1" == "--version" || "$1" == "-v" ]]; then
  VERSION=$(grep '"version"' "$PACKAGE_ROOT_DIR/package.json" | head -n 1 | awk -F: '{ print $2 }' | sed 's/[", ]//g')
  echo "$VERSION"
  exit 0
fi

if [[ -z "$1" || "$1" == "--help" || "$1" == "-h" || "$1" == "help" ]]; then
  print_root_help
  exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
  "e" | "env" | "environment")
    SUBCOMMAND="$1"
    shift

    ENV_CONFIG="
      CMD_INIT | init | i | | | | Initialize local environment files from examples across the project workspace
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx env" "Environment Configurations Management" "ddx env <subcommand> [options]" "$ENV_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "i" | "init") bash "$BIN_DIR/env/init.sh" "$@" ;;
      # GEN:ROUTER:ENV
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "d" | "deps" | "dependencies")
    SUBCOMMAND="$1"
    shift

    DEPS_CONFIG="
      CMD_INSTALL | install | i | | | | Install all dependencies and set up git hooks
      CMD_SCAN    | scan    | s | | | | Scan lockfiles for unstable dependencies
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx deps" "Workspace Dependencies Management" "ddx deps <subcommand> [options]" "$DEPS_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "i" | "install") bash "$BIN_DIR/deps/install.sh" "$@" ;;
      "s" | "scan") bash "$BIN_DIR/deps/scan.sh" "$@" ;;
      # GEN:ROUTER:DEPS
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "n" | "node")
    SUBCOMMAND="$1"
    shift

    NODE_CONFIG="
      CMD_PIN      | pin      | p | | | | Update and pin the Node.js version across the entire workspace
      CMD_VALIDATE | validate | v | | | | Validate the active Node.js version against the project's requirements
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx node" "Node.js Environment Management" "ddx node <subcommand> [options]" "$NODE_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "p" | "pin") bash "$BIN_DIR/node/pin.sh" "$@" ;;
      "v" | "validate") bash "$BIN_DIR/node/validate.sh" "$@" ;;
      # GEN:ROUTER:NODE
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "pm" | "package-manager")
    SUBCOMMAND="$1"
    shift

    PM_CONFIG="
      CMD_PIN | pin | p | | | | Update and pin the Package Manager version across the entire workspace
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx pm" "Package Manager Pining Automation" "ddx pm <subcommand> [options]" "$PM_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "p" | "pin") bash "$BIN_DIR/package-manager/pin.sh" "$@" ;;
      # GEN:ROUTER:PM
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  "sl" | "symlink" | "symlinks")
    SUBCOMMAND="$1"
    shift

    SYMLINK_CONFIG="
      CMD_CREATE | create | c | | | | Create absolute symbolic links from provided path pairs
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx symlink" "Symbolic Links Orchestration" "ddx symlink <subcommand> [options]" "$SYMLINK_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "c" | "create") bash "$BIN_DIR/symlink/create.sh" "$@" ;;
      # GEN:ROUTER:SYMLINK
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  # GEN:ROUTER:NEW_COMMAND

  "x" | "ex" | "exec" | "execute")
    source "$BIN_DIR/tasks/execute.sh"
    execute "$@"
    ;;

  "l" | "log")
    source "$BIN_DIR/utils/log.sh"
    log "$@"
    ;;

  "c" | "cli")
    SUBCOMMAND="$1"
    shift

    CLI_CONFIG="
      CMD_OPTIONS | options | opts | | | | Evaluate configuration schema against raw user inputs
      CMD_HELP    | help    | h    | | | | Intercept --help flags or print layout render engine
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" ]]; then
      print_help "ddx cli" "Central CLI Core Engine Settings" "ddx cli <subcommand> [action] [options]" "$CLI_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "opts" | "options")
        ACTION="$1"
        shift

        CLI_OPTS_CONFIG="
          CMD_PARSE | parse | p | | | | Evaluate configuration schema against raw user inputs
        "

        if [[ -z "$ACTION" || "$ACTION" == "--help" || "$ACTION" == "-h" || "$ACTION" == "help" ]]; then
          print_help "ddx cli options" "Options parsing engine" "ddx cli options <action> [options]" "$CLI_OPTS_CONFIG"
          exit 0
        fi

        case "$ACTION" in
          "p" | "parse")
            source "$BIN_DIR/cli/options.sh"
            parse_options "$@"
            ;;
          *) throw_unknown_command "$COMMAND $SUBCOMMAND $ACTION" ;;
        esac
        ;;

      "h" | "help")
        ACTION="$1"
        shift

        CLI_HELP_CONFIG="
          CMD_INTERCEPT | intercept | i | | | | Check streams for --help flags to prevent failures
          CMD_PRINT     | print     | p | | | | Forced format output layout render engine
        "

        if [[ -z "$ACTION" || "$ACTION" == "--help" || "$ACTION" == "-h" || "$ACTION" == "help" ]]; then
          print_help "ddx cli help" "Dynamic help rendering core" "ddx cli help <action> [options]" "$CLI_HELP_CONFIG"
          exit 0
        fi

        case "$ACTION" in
          "i" | "intercept")
            source "$BIN_DIR/cli/help.sh"
            intercept_help "$@"
            ;;
          "p" | "print")
            source "$BIN_DIR/cli/help.sh"
            print_help "$@"
            ;;
          *) throw_unknown_command "$COMMAND $SUBCOMMAND $ACTION" ;;
        esac
        ;;

      # GEN:ROUTER:CLI

      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;

  *)
    throw_unknown_command "$COMMAND"
    ;;
esac
