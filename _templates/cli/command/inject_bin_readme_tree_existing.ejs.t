---
inject: true
to: scripts/bin/README.md
after: "^├── <%= command %>\\b/"
skip_if: "^(?![\\s\\S]*├── <%= command %>\\b/)"
---
│   ├── <%= subcommand %>.sh<%- ' '.repeat(Math.max(1, 24 - subcommand.length - 3)) %># ddx <%= command %> <%= subcommand %>