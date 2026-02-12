# ADR-0002: CI/CD Pipeline Migration to GitHub Actions

## Status

Accepted — 2026-02-11

## Context

The repo used Node.js tooling (husky, semantic-release, commitlint) for versioning and local git hooks, plus Docker containers for Checkov/TFLint/TFSec via npm scripts. Problems:

1. Contributors needed Node.js, npm, nvm, and Docker installed to commit — excessive for a Terraform repo
2. Release pipeline was disabled (never actually ran)
3. Published to npm registry (irrelevant for Terraform)
4. Actions pinned to `@master` tags (supply-chain risk)
5. Required a custom `SEMVER_TOKEN` secret

## Decision

Replaced all Node.js tooling with GitHub Actions workflows:

**Test** (`test.yml`) — four parallel jobs on PRs/pushes to main:

| Job           | Tool                             | Replaces                |
| ------------- | -------------------------------- | ----------------------- |
| terraform fmt | `hashicorp/setup-terraform`      | npm format script       |
| TFLint        | `terraform-linters/setup-tflint` | reviewdog/action-tflint |
| TruffleHog    | `trufflesecurity/trufflehog`     | (new)                   |
| Trivy         | `aquasecurity/trivy-action`      | Checkov + TFSec         |

**Release** (`release.yml`) — on merge to main: `ietf-tools/semver-action` → git tag → `requarks/changelog-action` → GitHub Release.

**Dev & Staging** (`dev-staging.yml`) — deployment lifecycle tied to PRs and merges:

| Job     | Trigger        | Action                                        |
| ------- | -------------- | --------------------------------------------- |
| Plan    | PR opened/sync | `terraform plan` against development          |
| Dev     | PR opened/sync | `terraform apply` to development (after plan) |
| Cleanup | PR closed      | `terraform destroy` development resources     |
| Staging | Push to main   | `terraform apply` to staging                  |

**Production** (`production.yml`) — manual `workflow_dispatch` with a tag input and plan/apply choice. Defaults to plan-only; `apply` runs plan then deploys to production. Checks out the exact tagged commit via `ref: ${{ inputs.tag }}`.

**Supply-chain security** — all actions SHA-pinned via [pinact](https://github.com/suzuki-shunsuke/pinact), Dependabot keeps them updated. Only `GITHUB_TOKEN` needed.

**Removed:** `package.json`, `package-lock.json`, `.releaserc`, `.husky/`, `.npmrc`, `.nvmrc`, `.commitlintrc.json`

## Alternatives Considered

| Alternative                       | Why rejected                                                      |
| --------------------------------- | ----------------------------------------------------------------- |
| Keep semantic-release             | Requires Node.js; npm publishing irrelevant                       |
| `mathieudutour/github-tag-action` | Less control than `ietf-tools/semver-action`                      |
| Keep Checkov                      | Old action pinned to `@master`; Trivy covers both Checkov + TFSec |
| Keep husky hooks                  | Requires Docker + Node.js; bypassed with `--no-verify`            |

## Consequences

- No local tooling requirements beyond Terraform itself
- Conventional commit enforcement is implicit (semver parses prefixes) — add `wagoid/commitlint-github-action` if stricter enforcement needed
- `SEMVER_TOKEN` secret is now unused (remove from repo settings)
