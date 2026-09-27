# Test fixtures

Charts used by `.github/workflows/ci.yml` to exercise the reusable
`validate-helm.yml` workflow on every PR. They are test data, not
deployable charts.

- `hello-test/`: minimal compliant chart; every validation job must pass.
- `bad-latest-tag/`: negative fixture, must be rejected by `no-latest-tag.rego`.
- `bad-raw-secret/`: negative fixture, must be rejected by `no-raw-secrets.rego`.

Each negative fixture carries exactly one violation, and CI checks that it is
rejected with the expected policy message, not merely that conftest fails.
