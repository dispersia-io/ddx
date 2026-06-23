---
inject: true
to: README.md
before: "\\bGEN:README:<%= command_upper %>\\b"
skip_if: "^((?!\\bGEN:README:<%= command_upper %>\\b)[\\s\\S])*$"
---

### `ddx <%= command %> <%= subcommand %>`

<%= description %>

- **Usage:** `ddx <%= command %> <%= subcommand %> -r <val> [options]`
- **Example:**
  ```bash
  ddx <%= command %> <%= subcommand %> -r "value"
  ```
  