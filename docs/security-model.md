# Security model

These templates run in other repositories' CI with their tokens, and ship
images that run in clusters. The controls below are enforced by code, not only
documented.

## Supply chain
- Third-party actions pinned to full 40-character commit SHAs (peeled for
  annotated tags), enforced by a pre-commit hook; updates via Dependabot.
- Base images pinned as `tag@sha256:digest`; Python tools installed from
  hash-locked requirements.
- Every downloaded tool is verified: checksums (kubeconform, conftest), cosign
  signature against the upstream key (kube-linter).
- Published images carry SLSA provenance (`gh attestation verify`).

## Least privilege
- `permissions: {}` at workflow level, minimal grants per job.
- `persist-credentials: false` on every checkout.
- Release and admin operations never run from this repository's CI.

## Untrusted input
- Workflow inputs reach scripts through `env:` only (no template injection),
  are quoted, and are validated by a dedicated job before anything runs.
- Scripts run with `bash -euo pipefail`; downloads use `curl -f`.

## Change control
- Pull requests gated by required checks on up-to-date branches, no bypass
  (ADR 0004). Rulesets versioned and checked for drift.

## Detection
- zizmor, CodeQL, actionlint with ShellCheck, OpenSSF Scorecard, gitleaks,
  GitHub secret scanning with push protection.

## Testing the controls
- Security controls have negative tests: fixtures that policies must reject
  with the expected message, and failure cases for image entrypoints.
