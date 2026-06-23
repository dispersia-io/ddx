---
inject: true
to: scripts/bin/cli.sh
before: "\\bGEN:HELP:<%= command_upper %>\\b"
skip_if: "^((?!\\bGEN:HELP:<%= command_upper %>\\b)[\\s\\S])*$"
---
  print_root_help_command "" "<%= subcommand %><% if(alias){ %> (<%= alias %>)<% } %>" "<%= description %>"