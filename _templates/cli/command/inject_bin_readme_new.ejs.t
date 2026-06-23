---
inject: true
to: scripts/bin/README.md
before: "\\bGEN:BIN_README:NEW_COMMAND\\b"
skip_if: "\\bGEN:BIN_README:<%= command_upper %>\\b"
---

### `<%= command %>/<%= subcommand %>.sh` — `ddx <%= command %> <%= subcommand %>`

<%= description %>

<!-- GEN:BIN_README:<%= command_upper %> -->
