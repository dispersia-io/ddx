# scripts/internal

Development and CI/CD helper scripts. Not part of the `ddx` CLI surface — these are run directly via `bash`.

## Files

| File         | Description                                                                               |
| ------------ | ----------------------------------------------------------------------------------------- |
| `setup.sh`   | Orchestrates the initial project setup sequence.                                          |
| `cleanup.sh` | Deep workspace cleanup: clears the Yarn cache and deletes all `node_modules` directories. |

## Usage

```sh
bash scripts/internal/setup.sh
bash scripts/internal/cleanup.sh
```

## Conventions

- Scripts here are standalone and not sourced by `scripts/bin/`.
- They may call `ddx` commands internally or invoke `scripts/bin/` scripts directly.
- CI/CD pipeline steps that aren't exposed as CLI commands belong here.
