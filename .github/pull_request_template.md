<!--
⚠️ IMPORTANT:

1. Your PR title MUST follow the Conventional Commits standard (e.g., "feat(deps): add audit flag to scan command").
2. Your PR MUST be targeted against the 'canary' branch. PRs targeting 'main' will be closed.
-->

📝 **Description**

<!-- Please include a summary of the changes and the related issue. Describe the rationale behind adding, modifying, or removing a CLI command, bash script, or internal utility. -->

🔗 **Related Issue**

<!-- If this PR fixes an open issue, please link it here (e.g., "Closes #123"). Do NOT link public issues for security vulnerabilities. -->

🔍 **Type of Change**

<!-- Please delete options that are not relevant. -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue, e.g., fixing a flag parsing error)
- [ ] ✨ New feature (e.g., new `ddx` command or core module)
- [ ] 💥 Breaking change (e.g., renaming an existing command or altering mandatory flags)
- [ ] 🛡️ Security fix (e.g., patching a vulnerability or upgrading compromised dependencies)
- [ ] 📚 Documentation update
- [ ] 🛠️ Refactoring / Chore (e.g., dependency updates, internal CI scripts)

✅ **Checklist**

<!-- Please review this checklist before submitting your PR. -->

- [ ] I have targeted the `canary` branch.
- [ ] My PR title follows the Conventional Commits standard.
- [ ] I have read the `CONTRIBUTING.md` document.
- [ ] I have run `yarn install` to ensure lockfile integrity (if dependencies changed).
- [ ] I have verified that the updated bash scripts have execution permissions (`chmod +x`).
- [ ] I have run my changes locally via `ddx` and confirmed they work as intended.

🧪 **How Has This Been Tested?**

<!-- Please describe how you verified your changes. -->

- [ ] Tested locally by running the modified `ddx` command against a sample workspace and verifying the terminal output.
- [ ] Added or updated unit/integration tests in the `tests/` directory.
- [ ] Verified ASCII/Unicode fallback formatting via the `--no-unicode` and `--no-color` flags.
- [ ] Verified Shellcheck and ESLint passing on all modified files.
- [ ] ...
