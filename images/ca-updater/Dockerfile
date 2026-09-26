# Generic init-container image: merges the system CA bundle with a custom
# CA mounted at runtime and writes the result to a shared volume.
# ca-certificates is installed at BUILD time, so the container needs no
# network when it runs and cannot fail on a DNS hiccup after a restart.
FROM alpine:3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

RUN apk add --no-cache ca-certificates \
 && adduser -D -H -u 10001 ca-updater

COPY --chmod=0755 entrypoint.sh /usr/local/bin/ca-updater

USER 10001
ENTRYPOINT ["/usr/local/bin/ca-updater"]
