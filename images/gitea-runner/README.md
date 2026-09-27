# gitea-runner

Gitea Actions job image: the official runner image plus the homelab root CA
and zizmor, installed from hash-locked requirements (`requirements.txt`,
generated with `pip-compile --generate-hashes`).

- **Why the CA is baked in**: job containers are spawned by dind, where
  Kubernetes volume mounts do not propagate, so runtime injection is unreliable.
- **Instance-specific**: forks replace `ca.crt` with their own root CA.
- **zizmor version**: keep `requirements.in` aligned with the version bundled
  by `zizmor-action`, so GitHub and Gitea apply the same rules.
- Smoke-tested by CI (zizmor version, CA count) before every publication.
