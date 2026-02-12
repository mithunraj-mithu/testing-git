# Terraform Template

Template Terraform stack — currently using Terraform 1.x.x

## Quick Setup Checklist

> Complete these steps after cloning/creating a repo from this template.

- [ ] **Service name** — set the `service` default in `terraform/variables.tf` (deployment will fail if left as `terraform-template`)
- [ ] **Provider version** — update the AWS provider version constraint in `terraform/providers.tf` to the [latest release](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [ ] **Default tags** — update `Service`, `TeamName`, `RepositoryName`, `Org` in `terraform/providers.tf`
- [ ] **State backends** — set `bucket` and `key` in `terraform/backends/development.conf`, `staging.conf`, and `production.conf`
- [ ] **GitHub Environments** — create `development`, `staging`, and `production` environments with `AWS_ROLE_ARN` variables
- [ ] **Infrastructure** — replace the demo resources in `terraform/iam.tf` with your actual infrastructure

## Template Setup

Details for each checklist item above:

| File                                  | What to change                                                                                    |
| ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `terraform/variables.tf`              | Set `service` default to your service name (deployment will fail if left as `terraform-template`) |
| `terraform/providers.tf`              | Update AWS provider version and `default_tags` (see [Provider Version](#provider-version) below)  |
| `terraform/backends/development.conf` | Set `bucket` and `key` to your project's state bucket/path                                        |
| `terraform/backends/staging.conf`     | Set `bucket` and `key` to your project's state bucket/path                                        |
| `terraform/backends/production.conf`  | Set `bucket` and `key` to your project's state bucket/path                                        |
| `terraform/iam.tf`                    | Replace demo resources with your actual infrastructure                                            |

### Provider Version

The template ships with a pinned AWS provider version that may be outdated. After cloning, update `terraform/providers.tf` to the latest version:

```hcl
# terraform/providers.tf
aws = {
  source  = "hashicorp/aws"
  version = "~> 5.82.0"  # ← check registry.terraform.io for latest
}
```

The `~>` (pessimistic) constraint allows patch updates (e.g. `5.82.1`) but blocks minor/major bumps. Pin to the latest minor version at the time you create your repo, then let Dependabot propose upgrades going forward.

## Deploying

Infrastructure is deployed via CI/CD pipelines only. Manual deployments should be performed by a DevOps engineer when required.

## Project Layout

```
.github/workflows/      CI/CD pipelines (test, release, deploy)
.github/dependabot.yml  Automated GitHub Actions updates
terraform/              All Terraform configuration
CONTRIBUTING.md         Commit conventions and semver guide
```

## CI/CD

**Test** (PRs and pushes to main) — terraform fmt, TFLint, TruffleHog, Trivy

**Release** (merge to main) — semver bump from conventional commits, git tag, GitHub Release with changelog

**Deploy** — three-stage promotion tied to the git workflow:

```
PR opened/sync ──► terraform plan + deploy dev
PR closed ──────► terraform destroy dev
merge to main ──► deploy staging
manual trigger ──► deploy production (pick a tag)
```

| Stage       | Trigger                   | Workflow          | Environment   |
| ----------- | ------------------------- | ----------------- | ------------- |
| Plan        | PR opened/sync            | `dev-staging.yml` | —             |
| Development | PR opened/sync            | `dev-staging.yml` | `development` |
| Cleanup     | PR closed                 | `dev-staging.yml` | `development` |
| Staging     | Merge to main             | `dev-staging.yml` | `staging`     |
| Production  | Manual (tag + plan/apply) | `production.yml`  | `production`  |

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions.

## Local Development

```bash
terraform fmt -recursive terraform/   # format
tflint --chdir=terraform/              # lint
```

## Technology

[terraform](https://www.terraform.io/) |
[tflint](https://github.com/terraform-linters/tflint) |
[trivy](https://github.com/aquasecurity/trivy) |
[trufflehog](https://github.com/trufflesecurity/trufflehog)
