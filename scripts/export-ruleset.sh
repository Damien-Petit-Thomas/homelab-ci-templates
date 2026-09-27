#!/usr/bin/env bash
# Export a repository ruleset as a reviewed JSON snapshot (policy fields only,
# no instance-specific ids or timestamps).
# Usage: scripts/export-ruleset.sh [owner/repo] [ruleset-name] [output-file]
set -euo pipefail

REPO="${1:-Damien-Petit-Thomas/homelab-ci-templates}"
NAME="${2:-main-protection}"
OUT="${3:-.github/rulesets/${NAME}.json}"

rulesets="$(gh api "repos/${REPO}/rulesets")"
id="$(jq -r --arg n "$NAME" '.[] | select(.name == $n) | .id' <<<"$rulesets")"
if [[ -z "$id" ]]; then
  echo "ruleset '$NAME' not found in $REPO. Available rulesets:" >&2
  jq -r '.[].name' <<<"$rulesets" >&2
  exit 1
fi

gh api "repos/${REPO}/rulesets/${id}" \
  | jq -S '{name, target, enforcement, conditions, bypass_actors, rules}' > "$OUT"

jq -e '[.name, .target, .enforcement, .conditions, .rules] | all(. != null)' "$OUT" >/dev/null \
  || { echo "incomplete export: null fields in $OUT" >&2; exit 1; }

echo "exported ruleset '$NAME' (id $id) to $OUT"
