---
inject: true
to: scripts/bin/cli.sh
before: "\\bGEN:ROUTER:NEW_COMMAND\\b"
skip_if: "\\bGEN:ROUTER:<%= command_upper %>\\b"
---
  "<%= command %>")
    SUBCOMMAND="$1"
    shift

    <%= command_upper %>_CONFIG="
      CMD_<%= subcommand_upper %> | <%= subcommand %> |<%= alias ? ` ${alias} ` : ' ' %>| | | | <%= description %>
    "

    if [[ -z "$SUBCOMMAND" || "$SUBCOMMAND" == "--help" || "$SUBCOMMAND" == "-h" || "$SUBCOMMAND" == "help" ]]; then
      print_help "ddx <%= command %>" "<%= command %> command Management" "ddx <%= command %> <subcommand> -r <val> [options]" "$<%= command_upper %>_CONFIG"
      exit 0
    fi

    case "$SUBCOMMAND" in
      "<% if(alias){ %><%= alias %>" | "<% } %><%= subcommand %>") bash "$BIN_DIR/<%= command %>/<%= subcommand %>.sh" "$@" ;;
      # GEN:ROUTER:<%= command_upper %>
      *) throw_unknown_command "$COMMAND $SUBCOMMAND" ;;
    esac
    ;;
