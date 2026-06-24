---
inject: true
to: scripts/bin/cli.sh
before: "\\bGEN:ROUTER:<%= command_upper %>\\b"
skip_if: "^((?!\\bGEN:ROUTER:<%= command_upper %>\\b)[\\s\\S])*$"
---
      "<% if(alias){ %><%= alias %>" | "<% } %><%= subcommand %>") bash "$BIN_DIR/<%= command %>/<%= subcommand %>.sh" "$@" ;;