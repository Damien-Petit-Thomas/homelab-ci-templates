# homelab-ci-templates

Reusable GitHub Actions workflows and OPA policies for GitOps validation

## Philosophy

Every policy in this repository exists because of a real incident, not a
theoretical best practice.

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

## Policies

| Policy | What it prevents |
|---|---|
| `no-latest-tag.rego` | Images pinned to `:latest` or no tag at all |
| `no-raw-secrets.rego` | Any `Secret` object authored directly (should always be an `ExternalSecret`) |

## Security

Every workflow in this repository follows least-privilege defaults:
- `permissions: {}` at the workflow level, explicit grants per job
- `persist-credentials: false` on every checkout
- No action referenced by a mutable tag or branch (pinned to a released
  version; SHA-pinning tracked as a follow-up)
