# 0002. Run zizmor natively on non-GitHub forges

**Status:** Accepted

## Context
`zizmor-action` runs zizmor in a nested container. Under DinD, the job workspace
is not mounted into it: zizmor reported `invalid input` on files that exist.
Online audits also need a GitHub token, absent on Gitea.

## Decision
On GitHub, use `zizmor-action` (SARIF upload, online audits). Elsewhere, run the
zizmor binary shipped in the job image, installed from hash-locked requirements,
offline.

## Consequences
- Two execution paths: keep the image's zizmor version aligned with the one
  bundled by `zizmor-action`, so both forges apply the same rules.
- No package download at job time on Gitea.
- Online audits (known-vulnerable actions, impostor commits) run on GitHub only.

## Rejected alternatives
- `pip install zizmor` in the job: runtime network dependency, version pinned
  but content not verified (flagged by Scorecard `Pinned-Dependencies`).
