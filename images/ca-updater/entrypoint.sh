#!/bin/sh
# Builds a CA bundle = system bundle + one custom CA, and exits non-zero
# (so Kubernetes retries instead of starting the pod) if anything is off.
# Each precondition is checked separately so the error names the real cause.
set -eu

CA_SOURCE="${CA_SOURCE:-/custom-ca/ca.crt}"
BUNDLE_OUT="${BUNDLE_OUT:-/shared-ca/ca-certificates.crt}"
SYSTEM_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
OUT_DIR="$(dirname "$BUNDLE_OUT")"

fail() { echo "ca-updater: $*" >&2; exit 1; }

[ -e "$CA_SOURCE" ]     || fail "custom CA '$CA_SOURCE' not found (volume not mounted?)"
[ -r "$CA_SOURCE" ]     || fail "custom CA '$CA_SOURCE' is not readable by uid $(id -u)"
[ -s "$CA_SOURCE" ]     || fail "custom CA '$CA_SOURCE' is empty"
grep -q "BEGIN CERTIFICATE" "$CA_SOURCE" || fail "'$CA_SOURCE' is not a PEM certificate"
[ -r "$SYSTEM_BUNDLE" ] || fail "system bundle '$SYSTEM_BUNDLE' is not readable"
[ -w "$OUT_DIR" ]       || fail "output directory '$OUT_DIR' is not writable by uid $(id -u)"

tmp="$(mktemp "$OUT_DIR/.bundle.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

{ cat "$SYSTEM_BUNDLE"; printf '\n'; cat "$CA_SOURCE"; } > "$tmp"
# mktemp creates 0600; consumers run under arbitrary uids (e.g. Vault: 100).
chmod 0644 "$tmp"

before="$(grep -c "BEGIN CERTIFICATE" "$SYSTEM_BUNDLE")"
after="$(grep -c "BEGIN CERTIFICATE" "$tmp")"
[ "$after" -gt "$before" ] || fail "custom CA was not added to the bundle"

mv "$tmp" "$BUNDLE_OUT"
trap - EXIT
echo "ca-updater: wrote $BUNDLE_OUT ($before system + $((after - before)) custom)"
