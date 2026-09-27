# Gitea Actions job image with the homelab root CA trusted at build time.
# Runtime injection into DinD-spawned job containers proved unreliable
# (Kubernetes mounts don't propagate to dind's child containers), so the
# trust store is baked in. Instance-specific: forks replace ca.crt.
#
# Also ships zizmor, installed from hash-locked requirements: the reusable
# zizmor workflow runs it natively on non-GitHub forges (zizmor-action's
# nested container can't see the job workspace under DinD).
FROM docker.gitea.com/runner-images:ubuntu-24.04@sha256:fd911d7417bfbf0f454530e447da95b58001e1df41bbc5e1a8dd35d432575aae

COPY ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
RUN update-ca-certificates

COPY requirements.txt /tmp/zizmor-requirements.txt
RUN python3 -m venv /opt/zizmor \
 && /opt/zizmor/bin/pip install --no-cache-dir --require-hashes -r /tmp/zizmor-requirements.txt \
 && ln -s /opt/zizmor/bin/zizmor /usr/local/bin/zizmor \
 && rm /tmp/zizmor-requirements.txt
