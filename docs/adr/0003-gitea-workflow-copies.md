# 0003. Per-forge workflow copies

**Status:** Superseded; copies removed in 2.0.0

## Context
An early call from Gitea to `.github/workflows/zizmor.yml` stayed stuck at job
setup, while `.gitea/workflows/` worked. The directory was taken as the cause.

## Original decision
Keep identical copies of the reusable workflows in `.github/workflows/` and
`.gitea/workflows/`, enforced by a parity CI job.

## Why it was reversed
The same period had a second, unrelated failure: job containers did not trust
the homelab CA (see ADR 0001). Once that was fixed, a direct test showed that
Gitea resolves `.github/workflows/` reusable workflows correctly. The copies had
never been necessary.

## Consequences
- 2.0.0 removes the copies and the parity job; callers use `.github/workflows/`.
- Callers pinned to `@v1` keep working: the `v1` line still contains the copies.

## Lesson
Re-test a conclusion once a confounding problem present at the same time has
been fixed.
