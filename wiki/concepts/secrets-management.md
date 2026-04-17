---
title: "Secrets Management"
tags: [secrets, security, credentials, vault]
sources: [owasp-docker-security.md, owasp-iac-security.md]
updated: 2026-04-15
---

# Secrets Management

Secure storage, distribution, and lifecycle management of sensitive credentials: API keys, passwords, tokens, SSH keys, TLS certificates.

## The Core Problem

Secrets are commonly leaked by:

- Committing to Git (plain text in source code or config)
- Embedding in container images (Dockerfile ENV or COPY)
- Passing via environment variables (visible in process list, logs)
- Storing in unencrypted config files

## Detection Tools

| Tool          | Scope                                         |
| ------------- | --------------------------------------------- |
| truffleHog    | Git history scanning for secrets              |
| git-secrets   | Pre-commit hook for AWS credentials           |
| GitGuardian   | CI/CD + real-time Git monitoring              |
| ggshield      | CLI + CI integration (GitGuardian)            |
| SecretScanner | Container image secret scanning (open source) |

## Docker Secrets

Docker Swarm provides native secret management:

```
docker secret create my_secret secret.txt
docker service create --secret my_secret nginx
```

Secrets are mounted as files, not env vars. Encrypted in transit and at rest in Swarm.

**Kubernetes caveat**: K8s secrets are base64-encoded, not encrypted by default. Use etcd encryption at rest + external secret stores (Vault, AWS Secrets Manager, Sealed Secrets).

## IaC Secrets

- Never commit secrets alongside IaC code
- Use external secret stores: HashiCorp Vault, AWS SSM, Azure Key Vault
- Reference secrets by ARN/path in IaC, don't inline values
- Rotate secrets as part of infrastructure lifecycle

## Kubernetes Secrets Options

K8s Secrets are base64-encoded (not encrypted) by default. Options in order of security:

| Option                                                           | Description                                                       | Notes                 |
| ---------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------- |
| K8s Secrets + encryption at rest                                 | Enable etcd encryption; RBAC to limit access                      | Minimum viable        |
| [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) | Encrypt secrets before committing to Git; decrypt in cluster      | Good for GitOps       |
| External Secrets Operator                                        | Syncs secrets from AWS Secrets Manager, GCP Secret Manager, Vault | Best for cloud-native |
| HashiCorp Vault                                                  | Full-featured: dynamic secrets, lease rotation, audit             | Most powerful         |

Best practices:

- Enable encryption at rest for etcd
- Use RBAC to restrict Secret read access per namespace
- Rotate secrets regularly; audit access

## Cryptographic Key Storage

For cryptographic keys specifically, see [Key Management](key-management.md). Key-specific requirements beyond general secrets management:

- Store in HSM (Hardware Security Module) or isolated cryptographic vault — application code must never read raw key material.
- Encrypt keys at rest with a Key Encryption Key (KEK) of equal or greater strength.
- Apply integrity protection (MAC) to stored keys.
- Plan for key escrow and compromise recovery (see NIST SP 800-57).
- Never store signing keys in escrow — non-repudiation would be broken.

## Sources

- [OWASP Docker Security Cheat Sheet](../sources/owasp-docker-security.md)
- [OWASP IaC Security Cheat Sheet](../sources/owasp-iac-security.md)
- [OWASP Key Management Cheat Sheet](../sources/owasp-key-management.md)
