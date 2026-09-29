# 0001. Bake the homelab CA into the Gitea job image

**Status:** Accepted

## Context
Gitea Actions jobs run in containers spawned by a Docker-in-Docker sidecar.
Checking out from `gitea.internal` failed with `server certificate verification
failed`: the job containers did not trust the homelab root CA.

## Decision
Build a job image (`images/gitea-runner`) with the CA installed at build time,
and map the runner labels to it, pinned by digest.

## Consequences
- The trust store is correct when the container starts; nothing to inject.
- The image is instance-specific: forks replace `ca.crt`. A CA rotation means a
  new image version.
- The image is built in CI with SLSA provenance, like every other image.

## Rejected alternatives
- `container.options` bind-mounting the bundle: Kubernetes mounts made into the
  dind sidecar are not visible to the containers dind spawns.
- The same with `mountPropagation: Bidirectional`: still not visible.
- `GIT_SSL_NO_VERIFY=true`: disables TLS verification; unacceptable, especially
  in a public repository presented as a reference.
