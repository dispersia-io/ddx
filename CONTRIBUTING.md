# Contributing to @dispersiajs/ddx

This guide outlines the development process and coding standards for `@dispersiajs/ddx` (the `ddx` CLI). As an internal DX toolset for Dispersia projects, adherence to these guidelines ensures code quality, CLI stability, and a reliable developer experience across our infrastructure.

## ❗ Before You Start

Before writing your first line of code, you **MUST** read and understand the following documents:

- **[LICENSE](./LICENSE.md)**: To understand the terms under which this project is distributed.
- **[SECURITY.md](./SECURITY.md)**: To learn how to report vulnerabilities privately and handle security patches.
- **[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)**: To understand our professional standards and communication etiquette.
- **[README.md](./README.md)**: For a high-level overview of the CLI commands and global flags.
- **[scripts/bin/README.md](./scripts/bin/README.md)**: For a deep dive into the CLI core architecture, JIT options parsing, and command execution flow.

## 🛠️ Prerequisites

To ensure a consistent development environment, the following tools are required:

- **Volta**: To automatically manage Node.js and package manager versions.
- **Node.js**: <!--node-version-->24.14.1<!--/node-version--> _(or as specified in package.json)_
- **Yarn**: <!--yarn-version-->4.17.0<!--/yarn-version--> _(Berry)_

Run `yarn setup` from the root directory to initialize the environment. This command runs `yarn install` and configures local Git hooks.

## 🌿 Branching Strategy and Workflow

We follow a structured flow to ensure that the `main` branch always remains stable.

1. **Clone**: Clone the repository to your local machine.
2. **Feature Branches**: Create a branch from `canary` for any change.
   - Format: `feat/description`, `fix/description`, or `refactor/description`.
3. **Pull Requests (PR)**: All changes must be submitted via a PR targeting the **`canary`** branch. PRs targeting `main` will be closed or redirected.
4. **The `canary` Branch**: This is our integration and pre-release branch. CLI features here are tested internally before widespread adoption.
5. **The `main` Branch**: Releases are made by maintainers by merging `canary` into `main`. Direct commits to `main` are strictly prohibited.

## 📝 Commit Message Standard

This project enforces the [**Conventional Commits**](https://www.conventionalcommits.org/) standard via `commitlint`.

**If your commit message does not follow the standard, your push/PR will be automatically rejected.**

### Format

`<type>(<optional-scope>): <subject>`

### Allowed Types:

- `feat`: A new CLI command, core feature, or utility (Triggers a MINOR version bump).
- `fix`: A bug fix in script execution or argument parsing (Triggers a PATCH version bump).
- `docs`: Documentation only changes.
- `style`: Changes that do not affect the meaning of the code (e.g., formatting).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves CLI execution speed.
- `test`: Adding missing tests or correcting existing tests.
- `build`: Changes that affect the build system or external dependencies.
- `ci`: Changes to our internal CI configuration files and scripts.
- `chore`: Other changes that don't modify core CLI files.
- `__wip__`: Work in progress. Used for intermediate commits. These must be squashed or amended before merging into `canary`.

## 🏗️ Project Structure

- **`scripts/bin/`**: Core source code, routing logic, and executables for the `ddx` CLI.
- **`scripts/internal/`**: Automation scripts meant strictly for internal CI/CD orchestration.

## ⌨️ Available Commands

Run these commands from the root directory:

### 🧹 Maintenance & Utilities

- `yarn setup` — Initialize the environment (installs dependencies and configures hooks).
- `yarn cleanup` — Perform a deep workspace purge.
- `yarn audit` — Run a dependency audit utilizing the internal CLI.
- `yarn new:command` — Scaffold a new CLI command structure and boilerplate using Hygen.

---

Thank you for contributing to `@dispersiajs/ddx`!
