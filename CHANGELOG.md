# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/). Callers should reference the moving
major tag (`@v1`); breaking changes only ship in a new major version.


## [1.1.0] - 2026-09-27

### Security
- `validate-helm.yml` verifies every tool it downloads: checksums for
  kubeconform and conftest, cosign signature for kube-linter against the
  upstream release key. HTTP errors on downloads now fail the job instead of
  producing a corrupt file.

### Added
- `scripts/gen-workflow-reference.sh` regenerates `docs/reference/workflows.md`
  from the reusable workflow inputs.
- Pre-commit guards: no commits on `main`, action pins must be full 40-character
  commit SHAs.

### Deprecated
- The `.gitea/workflows/` copies. Gitea callers can reference
  `.github/workflows/<name>.yml` directly (verified on Gitea Actions); the
  copies will be removed in 2.0.0. Callers pinned to `@v1` keep working.


## [1.0.0] - 2026-09-27

First stable release.

### Added
- `validate-helm.yml` reusable workflow: helm lint, kubeconform, kube-linter,
  server-side dry-run against k3d, and conftest policies, behind an early input
  validation job.
- `zizmor.yml` reusable workflow for GitHub and Gitea: auto-detects
  `.github/workflows` and `.gitea/workflows`; SARIF and online audits on GitHub,
  native offline run on other forges.
- OPA policies `no-latest-tag` and `no-raw-secrets`, each with negative fixtures
  that CI requires to be rejected with the expected message.
- `ca-updater` and `gitea-runner` images, built and published by CI with SLSA
  provenance, behaviour tests and immutable versions.

### Security
- Workflow inputs are passed through `env:` (no template injection), every
  third-party action is pinned to a commit SHA, and scripts run with
  `bash -euo pipefail`.
