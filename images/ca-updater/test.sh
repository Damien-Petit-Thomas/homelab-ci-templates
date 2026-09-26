#!/usr/bin/env bash
# Behaviour tests for the ca-updater image, run locally and in CI.
# Usage: test.sh <image> <path/to/ca.crt>
set -euo pipefail
IMAGE="$1"; CA="$2"

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/out" && chmod 777 "$T/out"
install -m 644 "$CA" "$T/ca.crt"
install -m 600 "$CA" "$T/ca-private.crt"      # unreadable by the image's uid 10001
printf 'garbage\n' > "$T/bad.crt" && chmod 644 "$T/bad.crt"

fails=0
expect() {  # expect <exit code> <message fragment> [docker run args...]
  local want="$1" pattern="$2"; shift 2
  local out rc=0
  out="$(docker run --rm --read-only "$@" -v "$T/out:/shared-ca" "$IMAGE" 2>&1)" || rc=$?
  if [[ "$rc" == "$want" && "$out" == *"$pattern"* ]]; then
    echo "PASS  exit=$rc  $pattern"
  else
    echo "FAIL  expected exit=$want '$pattern', got exit=$rc: $out"
    fails=$((fails + 1))
  fi
}

expect 0 "+ 1 custom"   -v "$T/ca.crt:/custom-ca/ca.crt:ro"
expect 1 "not found"
expect 1 "not readable" -v "$T/ca-private.crt:/custom-ca/ca.crt:ro"
expect 1 "not a PEM"    -v "$T/bad.crt:/custom-ca/ca.crt:ro"

exit "$fails"
