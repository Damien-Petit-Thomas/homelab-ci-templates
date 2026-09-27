# Security Policy

## Reporting a vulnerability

If you discover a vulnerability in this repository, please report it
privately using GitHub Security Advisories:
https://github.com/Damien-Petit-Thomas/homelab-ci-templates/security/advisories/new

Do not open a public issue for undisclosed vulnerabilities.

## What to include

Please include:
- impacted workflow/policy and repository context
- reproduction steps or proof of concept
- potential impact
- suggested remediation, if known

## Disclosure process and timeline

We will acknowledge vulnerability reports within 7 days and provide a
status update during triage. Coordinated disclosure is preferred; once a
fix is available, disclosure details may be published with affected
versions and mitigation guidance.

## OpenSSF Scorecard: accepted exceptions

Some Scorecard checks cannot pass for a single-maintainer project. They are
dismissed deliberately rather than ignored:

| Check | Rationale |
|---|---|
| Code-Review | Single maintainer. Every change still goes through a pull request, gated by required status checks (`ci-ok`, `zizmor`) and an automatic Copilot review. Human approval becomes mandatory as soon as a second maintainer joins (`CODEOWNERS` + 1 required approval). |
| Branch-Protection | Enforced: pull request required, required status checks on up-to-date branches, no bypass, force pushes and deletions blocked. Not satisfiable alone: required approvers, code-owner review and last-push approval all need a second person. They will be enabled (with a `CODEOWNERS` file) when one joins. |
| Fuzzing | No fuzzable code: the repository contains workflows, Rego policies and small shell entrypoints, all covered by behaviour tests (including negative fixtures). |
