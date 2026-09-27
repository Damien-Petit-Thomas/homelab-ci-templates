---
name: code-review
description: Review pull requests against the conventions of homelab-ci-templates (reusable CI workflows, OPA policies and container images shared across GitHub and Gitea).
---

# Code review guidelines

This repository provides reusable CI building blocks consumed from both GitHub
and Gitea (through a mirror). Changes must stay secure, reproducible and
portable across both forges.

## Workflows
- Every third-party action is pinned to a full commit SHA with a version
  comment. For annotated tags, the SHA must be the peeled commit (`^{}`),
  not the tag object.
- `permissions: {}` at workflow level; each job grants only what it needs.
- `persist-credentials: false` on every checkout.
- Expressions (`${{ ... }}`) are never interpolated in `run:` scripts: pass them
  through `env:` and quote every expansion (`"${VAR}"`).
- Every workflow value used in a `run:` script (inputs, matrix values, step
  outputs, secrets) reaches it through the step or job `env:`. Runner-provided
  variables (`GITHUB_*`, `RUNNER_*`) and variables assigned inside the script
  itself need no declaration. Scripts run with `bash -euo pipefail`, so a
  misspelled variable fails at runtime; flag it earlier in review.
- New CI jobs are added to the `needs:` of the `ci-ok` aggregator, never as
  separate required checks in the ruleset.
- Path-filtered workflows must never become required status checks.

## GitHub / Gitea parity
- A reusable workflow callable from Gitea exists in both `.github/workflows/`
  and `.gitea/workflows/`, identical. Flag a PR that changes one copy only.
- Avoid GitHub-only syntax in shared workflows (e.g. `$/` self-repository refs).

## Images (`images/<name>/`)
- Any change under `images/<name>/` bumps `images/<name>/VERSION` (published
  tags are immutable).
- Base images are pinned as `tag@sha256:digest`; Python tools are installed from
  hash-locked requirements (`--require-hashes`).
- Test from the consumer's point of view: files produced for other containers
  must be readable under an arbitrary uid (world-readable CA bundle).

## Policies and tests
- A new or changed OPA policy comes with a negative fixture that must be
  rejected with the expected message, not merely "conftest fails".
- Never remove `test-fixtures/`: they are the functional tests of the templates.

## Pull request hygiene
- The commit message and PR description must match the diff: flag any claimed
  change that is not in the code.
- Documentation (README, SECURITY.md, comments) must stay accurate after the
  change, including exceptions listed in SECURITY.md.
