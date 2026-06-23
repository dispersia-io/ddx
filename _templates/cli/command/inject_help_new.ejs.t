---
inject: true
to: scripts/bin/cli.sh
before: "\\bGEN:HELP:NEW_COMMAND\\b"
skip_if: "\\bGEN:HELP:<%= command_upper %>\\b"
---
  print_root_help_command "<%= command %>" "<%= subcommand %><% if(alias){ %> (<%= alias %>)<% } %>" "<%= description %>"
  # GEN:HELP:<%= command_upper %>