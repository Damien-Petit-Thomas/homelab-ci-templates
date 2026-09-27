# Test fixtures

Charts used by `.github/workflows/ci.yml` to exercise the reusable
`validate-helm.yml` workflow on every PR. They are test data, not
deployable charts.

- `hello-test/`: minimal compliant chart; every validation job must pass.
