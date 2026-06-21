# Security Policy

We take the security of the `@dispersiajs/ddx` infrastructure tooling seriously. We appreciate your efforts to responsibly disclose your findings, as this tool executes bash scripts with high privileges across internal repositories.

## Supported Versions

Below is the list of versions that currently receive security updates.

| Version | Supported | Description                                                      |
| ------- | --------- | ---------------------------------------------------------------- |
| 1.x.x   | ✅        | Current stable release branch. Receives security patches.        |
| Canary  | ⚠️        | Pre-release versions (e.g., `2.x.x-canary.x`). See policy below. |

### Canary Releases Policy

Versions tagged with `canary` are published automatically for testing upcoming CLI commands, architectural routing changes, or dependency updates.

- **No Backports:** Canary versions **do not** receive backported security patches.
- **Forward-Fix Only:** If a vulnerability is discovered in a canary release, the fix will be applied to the `main` branch and released in the next consecutive `canary` or stable release.
- **Usage:** We strongly advise against using `canary` versions in critical CI/CD production environments. If you are using a canary version and a vulnerability is disclosed, your only remediation path is to upgrade to a newer canary or the latest stable release.

## Reporting a Vulnerability

If you discover a security vulnerability within this project (e.g., arbitrary command execution vectors in `ddx exec`), please **do not disclose it publicly** (e.g., by creating a public GitHub issue). Public disclosure could put internal pipelines at risk before a patch is available.

Please report it privately using one of the following methods:

**Option 1: GitHub Private Vulnerability Reporting (Preferred)**

1. Navigate to the **Security** tab of this repository.
2. Click on **Report a vulnerability** (or use [this direct link](https://github.com/dispersia-io/ddx/security/advisories/new)).
3. Fill in the details, including affected versions, a description of the potential impact, and detailed steps to reproduce the vulnerability via the CLI.

**Option 2: Email**

1. Send an email to **security@dispersia.io**.
2. Provide the following details:
   - The package version(s) affected (e.g., `1.0.0` or `2.0.0-canary.1`).
   - A description of the potential impact on the host system or pipelines.
   - Detailed CLI steps or arguments to reproduce the vulnerability.

We will acknowledge receipt of your vulnerability report within 48 hours and strive to provide a timeline for a fix. Once the issue is resolved and a patch is released, we will coordinate with you on public disclosure.
