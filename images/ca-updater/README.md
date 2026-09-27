# ca-updater

Init-container image that builds a trust store (system CA bundle plus one
custom CA) with no network access at startup.

| Variable | Default | Meaning |
|---|---|---|
| `CA_SOURCE` | `/custom-ca/ca.crt` | custom CA certificate (PEM), usually mounted from a ConfigMap |
| `BUNDLE_OUT` | `/shared-ca/ca-certificates.crt` | merged bundle, written to a shared volume |

- **Output**: the bundle is written with mode `0644`, readable by consumers
  running under any uid.
- **Exit codes**: `0` on success; `1` with an explicit message if the CA is
  missing, unreadable, empty or not PEM, or if the output directory is not
  writable. Kubernetes then retries the init container instead of starting the
  pod with an incomplete trust store.
- Runs as uid `10001`, compatible with `readOnlyRootFilesystem: true`.
- Behaviour tests: `test.sh` (run by CI before every publication).

Verify provenance before use:

    gh attestation verify oci://ghcr.io/damien-petit-thomas/ca-updater:<version> --owner Damien-Petit-Thomas
