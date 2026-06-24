---
inject: true
to: README.md
before: "\\bGEN:README:NEW_COMMAND\\b"
skip_if: "\\bGEN:README:<%= command_upper %>\\b"
---

### `ddx <%= command %> <%= subcommand %>`

<%= description %>

- **Usage:** `ddx <%= command %> <%= subcommand %> -r <val> [options]`
- **Example:**
  ```bash
  ddx <%= command %> <%= subcommand %> -r "value"
  ```

<!-- GEN:README:<%= command_upper %> -->
