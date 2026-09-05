# Contributing

## Local setup

This repository uses [pre-commit](https://pre-commit.com) to run checks
locally before code ever reaches GitHub — faster feedback than waiting
for CI, and it keeps things like secrets or private keys from ever
entering git history in the first place.

### 1. Install pre-commit

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pre-commit
```

Remember to `source .venv/bin/activate` again in any new shell before
running `pre-commit` manually — the git hooks themselves don't need
the venv active, they invoke pre-commit's own isolated environment.

### 2. Install the tools used by pre-push hooks

The heavier checks (workflow linting, chart linting) run locally at
push time using the same pinned tool versions as CI, rather than
pre-commit-managed environments:

```bash
# actionlint — see .github/workflows/ci.yml for the pinned version
curl -fsSLo actionlint.tar.gz \
  "https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz"
tar xzf actionlint.tar.gz actionlint
sudo mv actionlint /usr/local/bin/

# kube-linter — see .github/workflows/validate-helm.yml for the pinned version
curl -sSL "https://github.com/stackrox/kube-linter/releases/download/v0.8.3/kube-linter-linux.tar.gz" \
  | sudo tar xz -C /usr/local/bin kube-linter

# helm, if not already installed
```

### 3. Install the git hooks

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push
```

### 4. What runs when

| Stage | Hooks | Why |
|---|---|---|
| `pre-commit` | whitespace, YAML syntax, merge conflicts, private keys, secret scanning | Fast enough to run on every commit |
| `pre-push` | actionlint, kube-linter on fixtures | Slower checks, deferred to the point code is about to leave the machine |

To skip a hook for a specific commit (should be rare, and justified in
the commit message):

```bash
SKIP=gitleaks git commit -m "..."
```

## Commit messages

This repository follows [Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): description`, e.g. `fix(policies): handle generateName fallback`.
Common types: `feat`, `fix`, `chore`, `docs`, `ci`, `refactor`.

## Pull requests

`main` is protected via a GitHub Ruleset: changes go through a pull
request, and CI (actionlint, the internal `validate-helm.yml` exercise,
zizmor, Scorecard) must pass before merge.
