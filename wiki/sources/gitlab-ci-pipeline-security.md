---
title: "GitLab CI Pipeline Security"
tags: [gitlab, ci-cd, security, supply-chain, secrets]
sources: [gitlab-ci-pipeline-security.md]
updated: 2026-04-23
---

# GitLab CI Pipeline Security

Covers secrets management, CI/CD variable security, and pipeline integrity practices
from the official GitLab CI pipeline security documentation.

## Secrets storage hierarchy

From most to least secure:

1. **External secrets managers** — HashiCorp Vault, Azure Key Vault, Google Cloud Secret Manager.
   Stored outside GitLab; use GitLab native integrations to retrieve in pipelines.

2. **CI/CD variables (masked + hidden + protected)** — Stored in GitLab settings.
   Less secure: visible to users with settings access, overridable, exposure-prone on misconfiguration.

3. **CI/CD variables (unprotected)** — Only for non-sensitive data.

### Guidance

- Sensitive data → secrets manager
- Non-sensitive config → CI/CD variables
- If forced to use variables for secrets: mask + hide + protect all three

## Pass parameters via inputs, not variables

Use [CI/CD inputs](../concepts/gitlab-ci-components.md) for parameterizing pipelines:

|                      | Inputs   | Variables           |
| -------------------- | -------- | ------------------- |
| Type validation      | Yes      | No                  |
| Required enforcement | Yes      | No                  |
| Override risk        | Low      | High                |
| Scope                | Explicit | Shared with secrets |

Consider disabling pipeline variables entirely when using inputs.

## Pipeline integrity

Four principles:

1. **Supply chain security** — Assets from trusted sources, integrity verified.
2. **Reproducibility** — Same inputs → same outputs.
3. **Auditability** — All dependencies traceable.
4. **Version control** — Changes to dependencies tracked.

### Docker image integrity

Always use SHA digests, not floating tags:

```yaml
# Preferred
image: node@sha256:0123456789abcdef...

# Dangerous
image: node:latest
image: node:${VERSION}
```

Find digest: `docker pull node:18.17.1 && docker images --digests node:18.17.1`

Use protected container repositories and protected tags to restrict who can push/overwrite images.
Avoid variables in image references — they can be overridden to point to malicious images.

### Dependency pinning

| Tool | Preferred                                          | Avoid                             |
| ---- | -------------------------------------------------- | --------------------------------- |
| npm  | `npm ci`                                           | `npm install`                     |
| yarn | `yarn install --frozen-lockfile`                   | `yarn install`                    |
| pip  | `pip install -r requirements.txt --require-hashes` | `pip install -r requirements.txt` |
| Go   | `go mod verify && go mod download`                 | `go get ./...`                    |

### Shell scripts and tools

Always pin + verify checksums when installing tools in jobs:

```yaml
terraform_job:
  script:
    - |
      wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
      echo "c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c  terraform_1.5.7_linux_amd64.zip" | sha256sum -c
      unzip terraform_1.5.7_linux_amd64.zip
      mv terraform /usr/local/bin/
    - terraform init && terraform plan
```

### Include ref pinning

Pin `include` references to specific commits or protected tags:

```yaml
include:
  - project: 'my-group/my-project'
    ref: 8b0c8b318857c8211c15c6643b0894345a238c4e  # commit SHA preferred
    file: '/templates/build.yml'
  - component: 'my-group/security-scans'
    version: '1.2.3'                                # exact semver

# Unsafe — never do this
include:
  - project: 'my-group/my-project'  # no ref = uses default branch, mutable
    file: '/templates/build.yml'
  - remote: 'https://example.com/security-scan.yml'  # external + mutable
```

For remote files: download and commit locally, then use `include: local`.

## Related

- [GitLab CI/CD Variables](../concepts/gitlab-ci-variables.md)
- [GitLab CI/CD Components](../concepts/gitlab-ci-components.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Secrets Management](../concepts/secrets-management.md)
- [GitLab entity](../entities/gitlab.md)
