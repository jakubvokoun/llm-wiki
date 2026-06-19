---
title: "GitLab CI Pipeline Security"
tags: [gitlab, ci-cd, security, supply-chain, secrets, pipeline-integrity]
sources: [gitlab-ci-pipeline-security.md]
updated: 2026-04-23
---

# GitLab CI Pipeline Security

Security practices specific to GitLab CI/CD pipelines, covering secrets storage, parameter passing, and supply chain integrity for pipeline assets.

## Secrets storage hierarchy

Use the most secure option available for the sensitivity level:

1. **External secrets manager** (Vault, Azure Key Vault, GCP Secret Manager) — stored outside GitLab
2. **CI/CD variables (masked + hidden + protected)** — fallback when no secrets manager available
3. **CI/CD variables (unmasked)** — non-sensitive config only

## Inputs vs variables for parameters

Prefer `inputs` over CI/CD variables for pipeline parameterization:

- Inputs are type-safe, required-enforced, explicit
- Variables lack type validation and silently default to empty string
- Consider disabling pipeline variables when using inputs to prevent override attacks

## Pipeline integrity

### Image SHA pinning

Always reference Docker images by SHA digest, never floating tags:

```yaml
# Safe
image: node@sha256:abc123...

# Dangerous
image: node:latest
image: node:${VERSION}  # variable can be overridden
```

### Dependency lockfiles

| Ecosystem | Command                                            |
| --------- | -------------------------------------------------- |
| npm       | `npm ci`                                           |
| yarn      | `yarn install --frozen-lockfile`                   |
| pip       | `pip install -r requirements.txt --require-hashes` |
| Go        | `go mod verify && go mod download`                 |

### Tool installation: pin + verify

```bash
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
echo "c0ed7bc32... terraform_1.5.7_linux_amd64.zip" | sha256sum -c
```

### Include ref pinning

Pin `include` refs to commit SHAs (strongest) or protected tags:

```yaml
include:
  - project: "my-group/my-project"
    ref: 8b0c8b318857c8211c15c6643b0894345a238c4e
    file: "/templates/build.yml"
```

Never use versionless includes. For remote files: download, commit, use `include:local`.

## Related

- [CI/CD Security](./cicd-security.md)
- [Supply Chain Security](./supply-chain-security.md)
- [Secrets Management](./secrets-management.md)
- [GitLab CI/CD Variables](./gitlab-ci-variables.md)
- [GitLab CI/CD Components](./gitlab-ci-components.md)
