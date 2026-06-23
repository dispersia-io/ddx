# scripts/bin

Source for all `ddx` CLI commands. Each subdirectory maps to a top-level command or internal concern.

## Entry Points

| File     | Description                                                                                                                          |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `ddx.js` | npm `bin` entry point. Spawns `cli.sh` via `child_process.spawnSync`, forwarding all arguments. Exported as `ddx` in `package.json`. |
| `cli.sh` | Central router. Parses global flags (`--no-color`, `--no-unicode`), resolves subcommands, and dispatches to the appropriate script.  |

## Directory Structure

```
scripts/bin/
├── cli.sh                      # Central entry point and command router
├── ddx.js                      # npm bin wrapper (spawns cli.sh)
│
├── core/
│   ├── root.sh                 # Resolves and exports ROOT_DIR
│   └── theme.sh                # ANSI color codes and unicode icons
│
├── cli/
│   ├── help.sh                 # print_help(), intercept_help()
│   └── options.sh              # parse_options() — JIT options parser
│
├── env/
│   └── init.sh                 # ddx env init
│
├── deps/
│   ├── install.sh              # ddx deps install
│   └── scan.sh                 # ddx deps scan
│
├── node/
│   ├── pin.sh                  # ddx node pin
│   └── validate.sh             # ddx node validate
│
├── package-manager/
│   └── pin.sh                  # ddx pm pin
│
├── symlink/
│   └── create.sh               # ddx symlink create
│
<!-- GEN:TREE:NEW_COMMAND -->
├── tasks/
│   ├── execute.sh              # ddx exec — routes to task or subtask
│   ├── task.sh                 # run_task executor
│   └── subtask.sh              # run_subtask executor
│
└── utils/
    ├── env.js                  # Error classes and validation for env vars and semver
    ├── flags.sh                # Flag validation utilities
    └── log.sh                  # ddx log — universal logging utility
```

## Core

### `core/root.sh`

Resolves the absolute path to the project root and exports it as `ROOT_DIR`. Sourced at the top of `cli.sh` and available to all downstream scripts.

### `core/theme.sh`

Centralized ANSI color escape codes and unicode icon definitions. Sourced once by `cli.sh`; ensures consistent visual output across all scripts.

## CLI Engine (`cli/`)

### `cli/help.sh`

Exports two functions:

- `print_help <command> <title> <usage> <config>` — Renders a visually aligned help table from a declarative pipe-delimited config string.
- `intercept_help <args...>` — Scans arguments for `-h` / `--help`, triggers `print_help`, and exits. Used at the top of each subcommand to short-circuit execution.

### `cli/options.sh`

Exports `parse_options <config>`. Generates JIT bash parsing logic from a declarative config string. Output is meant to be consumed with `eval`.

**Config column format:**

```
<VAR_NAME> | <--long> | <-short> | <required|optional> | <string|int|flag|toggle> | <default> | <description>
```

**Types:**

| Type     | Behavior                                                     |
| -------- | ------------------------------------------------------------ |
| `string` | Standard text value                                          |
| `int`    | Validates integer ≥ 1                                        |
| `flag`   | Binary switch; `0` by default, `1` if passed                 |
| `toggle` | Accepts any value, normalizes to `0` or `1` via `is_enabled` |

Types accept an optional display-name suffix for help rendering (e.g., `string:dirs`).

## Commands

### `env/init.sh` — `ddx env init`

Copies `.env.example` (or a custom source) to `.env` (or a custom destination) across specified workspace directories.

<!-- GEN:BIN_README:ENV -->

### `deps/install.sh` — `ddx deps install`

Installs workspace dependencies and sets up git hooks. Supports package manager override and silent mode.

### `deps/scan.sh` — `ddx deps scan`

Scans lockfiles for unstable (`0.x.x`) dependencies. Optional flags enable security audit (`--audit`), Dependabot auto-configuration (`--pin-unstable`), and automation state markers (`--meta`).

<!-- GEN:BIN_README:DEPS -->

### `node/pin.sh` — `ddx node pin`

Pins a Node.js version across the workspace. Requires `--version` and at least one target flag (`--volta`, `--version-file`, `--engine`, `--env`, `--docs`).

### `node/validate.sh` — `ddx node validate`

Reads the required version from `.node-version` and asserts that the active Node.js runtime matches.

<!-- GEN:BIN_README:NODE -->

### `package-manager/pin.sh` — `ddx pm pin`

Pins a package manager version (yarn/npm/pnpm) across the workspace. Requires `--name`, `--version`, and at least one target flag (`--volta`, `--package-json`, `--dockerfile`, `--docs`).

<!-- GEN:BIN_README:PM -->

### `symlink/create.sh` — `ddx symlink create`

Creates absolute symbolic links from space-separated `<target> <link>` pairs passed via `--paths`.

<!-- GEN:BIN_README:SYMLINK -->

<!-- GEN:BIN_README:NEW_COMMAND -->

### `tasks/execute.sh` — `ddx exec`

Router script. Dispatches `task` subcommand to `run_task` (via `task.sh`) and `subtask` to `run_subtask` (via `subtask.sh`).

### `tasks/task.sh` — `ddx exec task`

Executes a high-level task with formatted output. Requires `--name` and `--cmd`.

### `tasks/subtask.sh` — `ddx exec subtask`

Executes a granular subtask with formatted output. Requires `--cmd`. Supports predefined action templates via `--template`.

## Utilities (`utils/`)

### `utils/log.sh` — `ddx log`

Universal logging utility. Supports message types (success, warning, error, info), color overrides, inline/clear printing, indentation levels, and silent mode. Sourced by most command scripts internally; also exposed as `ddx log` for use in external scripts.

### `utils/env.js`

Node.js module providing custom error classes and validation helpers for environment variables and semantic versioning. Used by scripts that require structured validation before executing.

### `utils/flags.sh`

Shell utility functions for validating CLI flag values (e.g., checking required flags are set, validating allowed values). Sourced by command scripts as needed.

## Adding a New Command

### ⚡ Quick Scaffold (Recommended)

To automatically generate a new command boilerplate and register it within the CLI infrastructure, run the following command from the root repository directory:

```bash
yarn new:command
```

Follow the interactive CLI prompts to specify your command name and description. Hygen will automatically scaffold the required scripts.

### 🛠️ Manual Process (Under the Hood)

If you need to create a command manually or understand what the generator does behind the scenes, follow these steps:

1. Create a directory under `scripts/bin/<command>/`.
2. Add your script(s). Source `core/root.sh`, `core/theme.sh`, and `utils/log.sh` as needed.
3. Add a `case` entry in `cli.sh` pointing to the new script.
4. Update `print_root_help` in `cli.sh` with the new command entry.
5. Follow the `parse_options` pattern for option handling.

## `_internal/` Subdirectories

Any `scripts/bin/<command>/_internal/` directory contains helper scripts scoped strictly to that command folder. They are not intended for direct execution or sourcing from outside their parent directory.
