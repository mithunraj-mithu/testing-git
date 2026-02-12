# ADR-0001: Terraform Project Structure

## Status

Accepted — 2026-02-11

## Context

Template for Terraform stacks needing multi-environment support (dev/staging/prod) with isolated state. Terraform runs exclusively in CI/CD pipelines.

## Decision

- **Flat file layout** in `terraform/` — files named by purpose (`iam.tf`, `s3.tf`), no `main.tf`. Follows [HashiCorp conventions](https://developer.hashicorp.com/terraform/language/files).
- **Workspaces + per-environment configs** — `backends/*.conf` for state isolation, `workspaces/*.tfvars` for environment-specific values, explicit `-var-file` flags.
- **S3 backend** with encryption and DynamoDB locking.
- **Pessimistic provider constraint** (`~> 5.52.0`) — allows patches, blocks breaking changes.
- **No `.terraform.lock.hcl`** — pipeline runs `terraform init` fresh; lock file adds no value and goes stale.
- **Default tags** on all resources via provider config (Service, Team, Environment, etc.).

## Alternatives Considered

| Alternative                     | Why rejected                                                 |
| ------------------------------- | ------------------------------------------------------------ |
| Directory-per-environment       | Code duplication                                             |
| `terraform.tfvars` auto-loading | Implicit — `-var-file` makes the active environment explicit |
| Committing lock file            | No local runs; pipeline resolves providers fresh each time   |

## Consequences

- Explicit `-backend-config` and `-var-file` flags required (verbose but safe)
- New environments need a backend config, tfvars file, and S3 bucket
- Flat structure works for small-to-medium stacks; larger deployments may need modules
