# 0004. Branch protection for a single maintainer

**Status:** Accepted

## Context
Requiring one approval blocks every pull request, since GitHub forbids
approving one's own. The first workaround, an administrator bypass in "exempt"
mode, silently allowed direct pushes to `main`, and one happened.

## Decision
- Pull request required, **0** approvals, **no** bypass.
- Required status checks, on up-to-date branches: `ci-ok` (an aggregator that
  needs every CI job) and zizmor.
- Force pushes and deletions blocked; release tags `v*.*.*` immutable.
- Rulesets are exported to `.github/rulesets/` and checked weekly for drift.

## Consequences
- Every change is gated by automated checks; nothing reaches `main` directly.
- New CI jobs join `ci-ok`'s `needs`, never the ruleset: renames and matrix
  changes cannot leave a required check that never reports.
- Scorecard `Code-Review` and part of `Branch-Protection` cannot pass alone;
  they are documented in SECURITY.md. With a second maintainer: 1 approval,
  `CODEOWNERS`, last-push approval.
