---
inject: true
to: scripts/bin/README.md
before: "\\bGEN:BIN_README:<%= command_upper %>\\b"
skip_if: "^((?!\\bGEN:BIN_README:<%= command_upper %>\\b)[\\s\\S])*$"
---

### `<%= command %>/<%= subcommand %>.sh` — `ddx <%= command %> <%= subcommand %>`

<%= description %>
