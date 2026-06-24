# ddx — Dispersia Developer Experience CLI

Internal developer tooling for managing local environments, workspace dependencies, Node.js/package manager versioning, symlinks, and CI/CD pipeline tasks across Dispersia projects.

## Installation

```bash
npm install -g @dispersiajs/ddx
```

## Usage

```
ddx <command> [subcommand] [options]
ddx [command] --help
```

**Global flags** (prepend to any command):

| Flag                  | Description            |
| --------------------- | ---------------------- |
| `-nc`, `--no-color`   | Disable colored output |
| `-nu`, `--no-unicode` | Disable unicode icons  |

---

## Command Reference

### `ddx env init`

Initializes local environment files from distributed examples across the workspace.

- **Usage:** `ddx env init [options]`
- **Example:**
  ```bash
  ddx env init -f .env.example -t .env
  ```

<!-- GEN:README:ENV -->

### `ddx deps install`

Installs all workspace dependencies and configures development hooks.

- **Usage:** `ddx deps install [options]`
- **Example:**
  ```bash
  ddx deps install -pm yarn
  ```

### `ddx deps scan`

Scans lockfiles for unstable dependencies and maps structural risks.

- **Usage:** `ddx deps scan [options]`
- **Example:**

  ```bash
  ddx deps scan --pin-unstable
  ```

<!-- GEN:README:DEPS -->

### `ddx node pin`

Updates and pins the target Node.js version across your project layers.

- **Required Options:**
  - `-v, --version <semver>` : Strict semantic version target (e.g., `24.14.1`).
  - _Target Flags (At least one required):_ `--volta`, `--version-file`, `--engine`, `--env`, `--docs`.
- **Usage:** `ddx node pin -v <semver> <target-flag> [options]`
- **Example:**
  ```bash
  ddx node pin -v 24.14.1 --volta --engine
  ```

### `ddx node validate`

Validates the system's active Node.js version against workspace boundaries.

- **Usage:** `ddx node validate [options]`
- **Example:**
  ```bash
  ddx node validate
  ```

<!-- GEN:README:NODE -->

### `ddx pm pin`

Locks and synchronizes the specified Package Manager engine version.

- **Required Options:**
  - `-n, --name <string>` : Package manager name (`yarn`, `npm`, `pnpm`).
  - `-v, --version <semver>` : Semantic version string.
  - _Target Flags (At least one required):_ `--volta`, `--package-json`, `--dockerfile`, `--docs`.
- **Usage:** `ddx pm pin -n <name> -v <semver> <target-flag> [options]`
- **Example:**
  ```bash
  ddx pm pin -n yarn -v 4.17.0 --volta --package-json
  ```

<!-- GEN:README:PM -->

### `ddx symlink create`

Automates atomic generations of absolute filesystem symbolic links.

- **Required Options:**
  - `-ps, --paths <string>` : Space-separated pairs of target and destination paths.
- **Usage:** `ddx symlink create -ps "<target> <link>"`
- **Example:**
  ```bash
  ddx symlink create -ps "./foo ./foo_link ./bar ./bar_link"
  ```

<!-- GEN:README:SYMLINK -->

<!-- GEN:README:NEW_COMMAND -->

---

## Low-Level Utilities

### `ddx exec task`

Executes a high-level orchestration pipeline task block.

- **Required Options:**
  - `-n, --name <string>` : Monitored name of the operation.
  - `-c, --cmd <string>` : Executable command string.
- **Usage:** `ddx exec task -n <string> -c <string> [options]`
- **Example:**
  ```bash
  ddx exec task -n "Push image" -c "docker push"
  ```

### `ddx exec subtask`

Executes a granular, template-driven action with lifecycle outputs.

- **Required Options:**
  - `-c, --cmd <string>` : Executable target string.
- **Usage:** `ddx exec subtask -c <string> [options]`
- **Example:**
  ```bash
  ddx exec subtask -n "Install deps" -c "yarn install"
  ```

### `ddx log`

Universal logging proxy for pipeline scripts to pipe standardized visual markers.

- **Required Options:**
  - `-m, --message <string>` : Core log payload string.
- **Usage:** `ddx log -m <string> [options]`
- **Example:**
  ```bash
  ddx log -m "Installing dependencies..."
  ```

---

## CLI Core

> Internal commands used by the CLI engine itself. Not intended for direct use in typical workflows.

### `cli options parse`

Generates bash parsing logic from a declarative options configuration schema.

### `cli help intercept`

Scans argument streams for `--help` / `-h` flags and triggers help rendering.

### `cli help print`

Directly renders a formatted help table from a configuration string.
