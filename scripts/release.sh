#!/usr/bin/env bash
# Publishes a release from CHANGELOG.md: annotated tag vX.Y.Z, moving major
# tag vX, and a GitHub Release whose notes are the changelog section.
# Usage: scripts/release.sh X.Y.Z   (run from an up-to-date main)
set -euo pipefail

version="${1:?usage: scripts/release.sh X.Y.Z}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid version: $version" >&2; exit 1; }
major="v${version%%.*}"

[[ "$(git branch --show-current)" == "main" ]] || { echo "run from main" >&2; exit 1; }
git fetch --quiet origin
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] || { echo "main is not in sync with origin/main" >&2; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo "working tree is not clean" >&2; exit 1; }

notes="$(awk -v v="$version" 'index($0, "## [" v "]") == 1 {f=1; next} /^## \[/ {f=0} f' CHANGELOG.md)"
[[ -n "${notes//[[:space:]]/}" ]] || { echo "no CHANGELOG.md section for $version" >&2; exit 1; }

git tag -a "v${version}" -m "v${version}"
git tag -f "$major" "v${version}"
git push origin "v${version}"
git push -f origin "$major"
gh release create "v${version}" --title "v${version}" --notes "$notes" --verify-tag
echo "released v${version}; ${major} now points to it"
