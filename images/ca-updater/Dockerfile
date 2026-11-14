# Generic init-container image: merges the system CA bundle with a custom
# CA mounted at runtime and writes the result to a shared volume.
# ca-certificates is installed at BUILD time, so the container needs no
# network when it runs and cannot fail on a DNS hiccup after a restart.
FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache ca-certificates \
 && adduser -D -H -u 10001 ca-updater

COPY --chmod=0755 entrypoint.sh /usr/local/bin/ca-updater

USER 10001
ENTRYPOINT ["/usr/local/bin/ca-updater"]
