---
inject: true
to: scripts/bin/README.md
before: "\\bGEN:TREE:NEW_COMMAND\\b"
skip_if: "├── <%= command %>\\b/"
---
├── <%= command %>/
│   └── <%= subcommand %>.sh<%- ' '.repeat(Math.max(1, 24 - subcommand.length - 3)) %># ddx <%= command %> <%= subcommand %>
│