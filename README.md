# homelab-ci-templates

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Damien-Petit-Thomas/homelab-ci-templates/badge)](https://scorecard.dev/viewer/?uri=github.com/Damien-Petit-Thomas/homelab-ci-templates)
[![CI](https://github.com/Damien-Petit-Thomas/homelab-ci-templates/actions/workflows/ci.yml/badge.svg)](https://github.com/Damien-Petit-Thomas/homelab-ci-templates/actions/workflows/ci.yml)
[![zizmor](https://github.com/Damien-Petit-Thomas/homelab-ci-templates/actions/workflows/zizmor.yml/badge.svg)](https://github.com/Damien-Petit-Thomas/homelab-ci-templates/actions/workflows/zizmor.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

Reusable GitHub Actions workflows and OPA policies for GitOps validation,
shared across the `homelab-charts`, `homelab-argocd`, `homelab-iac`, and
`homelab-ansible` repositories.

## Philosophy

Every policy in this repository exists because of a real incident, not a
theoretical best practice.
The goal: mechanically prevent the same class of mistake from
happening twice.

## Available reusable workflows

### validate-helm.yml
Validates a Helm chart against multiple layers:
- `helm lint --strict`
- Schema validation via [kubeconform](https://github.com/yannh/kubeconform)
- Best-practice linting via [kube-linter](https://github.com/stackrox/kube-linter)
- Server-side dry-run against a real k3d cluster (catches CRD/admission
  webhook issues that client-side dry-run cannot)
- Custom OPA policies via [conftest](https://www.conftest.dev/)

Usage from a calling repository:

```yaml
jobs:
  validate:
    uses: Damien-Petit-Thomas/homelab-ci-templates/.github/workflows/validate-helm.yml@main
    with:
      chart-path: charts/actual
```

### zizmor.yml
Statically scans a repository's own GitHub Actions workflow files for
security issues (template injection, excessive permissions, credential
leakage). Every repository in this homelab should call this on itself,
not just rely on it being scanned here — this repository only ever
sees its own workflow files, never those of `homelab-charts`,
`homelab-argocd`, `homelab-iac`, or `homelab-ansible`.

Usage from a calling repository:

```yaml
jobs:
  zizmor:
    uses: Damien-Petit-Thomas/homelab-ci-templates/.github/workflows/zizmor.yml@main
```

## Policies

| Policy | What it prevents |
|---|---|
| `no-latest-tag.rego` | Images pinned to `:latest` (including `:latest@sha256:...`), or with no tag at all |
| `no-raw-secrets.rego` | Any `Secret` object authored directly — should always be an `ExternalSecret` |


## Reference

### `validate-helm.yml` inputs

| Input | Type | Required | Default | Description |
|---|---|---|---|---|
| `chart-path` | string | true | — | Path to the Helm chart to validate |
 | `helm-version` | string | false | `v3.16.3` | Helm version to install for validation |
 | `kubeconform-version` | string | false | `0.8.0` | kubeconform version used for schema validation |
 | `kubeconform-kubernetes-version` | string | false | `1.31.0` | Kubernetes version passed to kubeconform |
 | `kube-linter-version` | string | false | `0.8.3` | kube-linter version used for linting |
 | `conftest-version` | string | false | `0.69.0` | conftest version used to run OPA policies |

### `zizmor.yml` inputs

| Input | Type | Required | Default | Description |
|---|---|---|---|---|
| `paths` | string | false | `` | Space-separated workflow files to scan. Empty (default): every *.yml/*.yaml under .github/workflows and .gitea/workflows.  |


Neither workflow exposes outputs: the result is the job status. On GitHub,
zizmor also uploads SARIF results to Code Scanning.

### `ca-updater` image

Init-container image that builds a trust store: system CA bundle plus one
custom CA, with no network access at startup.

| Variable | Default | Meaning |
|---|---|---|
| `CA_SOURCE` | `/custom-ca/ca.crt` | custom CA certificate (PEM), usually mounted from a ConfigMap |
| `BUNDLE_OUT` | `/shared-ca/ca-certificates.crt` | merged bundle, written to a shared volume |

- **Output**: the bundle is written with mode `0644`, readable by consumers running under any uid.
- **Exit codes**: `0` on success; `1` with an explicit message if the CA is missing, unreadable,
  empty or not PEM, or if the output directory is not writable. Kubernetes then retries the
  init container instead of starting the pod with an incomplete trust store.
- Runs as uid `10001`, compatible with `readOnlyRootFilesystem: true`.

Verify provenance before use:

    gh attestation verify oci://ghcr.io/damien-petit-thomas/ca-updater:<version> --owner Damien-Petit-Thomas

### `gitea-runner` image

Gitea Actions job image: the official runner image plus the homelab root CA and
zizmor (installed from hash-locked requirements). Instance-specific: forks
replace `ca.crt`. Keep its zizmor version aligned with the one bundled by
`zizmor-action`, so both forges apply the same rules.
## Security

Every workflow in this repository follows least-privilege defaults:
- `permissions: {}` at the workflow level, explicit grants per job
- `persist-credentials: false` on every checkout
- Actions pinned to a full commit SHA, not a mutable tag
- [zizmor](https://docs.zizmor.sh) statically analyzes every workflow file
  on each push and pull request, catching template injection, excessive
  permissions, and credential leakage before they can ever run
- [OpenSSF Scorecard](https://scorecard.dev) tracks the repository's overall
  supply-chain posture on every push to `main` and weekly
- Branch protection enforced via a GitHub Ruleset (not classic branch
  protection), requiring a pull request and passing checks before merge

## License

[Apache 2.0](LICENSE)

## Acknowledgments

Several CI/CD security patterns in this repository (Dependabot cooldown
periods, `harden-runner` + a dedicated protected environment for
privileged workflows, preferring GitHub Rulesets over classic branch
protection to avoid privileged tokens) were inspired by
[Stéphane Robert](https://github.com/stephrobert)'s
[dsoxlab](https://github.com/stephrobert/dsoxlab) (Apache 2.0 licensed).
No code was copied verbatim; every workflow here was rewritten and
adapted to this repository's own context.
