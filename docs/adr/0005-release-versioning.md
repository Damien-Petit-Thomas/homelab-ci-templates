# 0005. SemVer releases with a moving major tag

**Status:** Accepted

## Decision
- Releases are immutable annotated tags `vX.Y.Z` (protected by the
  `release-tags` ruleset), with notes written in CHANGELOG.md.
- A moving major tag `vX` follows the latest `vX.Y.Z`; callers reference `@vX`.
- Breaking changes ship only in a new major; deprecations are announced in a
  minor release first.
- `scripts/release.sh` performs the sequence from an up-to-date `main`.

## Consequences
- Callers get fixes automatically within a major, and never a breaking change.
- zizmor's `unpinned-uses` accepts the ref for our own templates through an
  explicit `ref-pin` policy in callers; third-party actions stay hash-pinned.
