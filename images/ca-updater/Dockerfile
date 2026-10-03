# Generic init-container image: merges the system CA bundle with a custom
# CA mounted at runtime and writes the result to a shared volume.
# ca-certificates is installed at BUILD time, so the container needs no
# network when it runs and cannot fail on a DNS hiccup after a restart.
FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN apk add --no-cache ca-certificates \
 && adduser -D -H -u 10001 ca-updater

COPY --chmod=0755 entrypoint.sh /usr/local/bin/ca-updater

USER 10001
ENTRYPOINT ["/usr/local/bin/ca-updater"]
