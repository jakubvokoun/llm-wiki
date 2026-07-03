---
title: "OpenBao"
tags: [openbao, secrets-management, vault, security, key-management, kubernetes]
sources:
  [
    openbao-what-is-openbao.md,
    openbao-install.md,
    openbao-internals-architecture.md,
    openbao-internals-security.md,
  ]
updated: 2026-07-03
---

# OpenBao

**OpenBao** is an open-source, identity-based **secrets and encryption management** system — a community fork of HashiCorp Vault, now an [OpenSSF](openssf.md) Sandbox project under the Linux Foundation (LF Projects, LLC). It stores, controls access to, and audits secrets (API keys, passwords, certificates, encryption keys) behind authentication and authorization, and offers encryption-as-a-service. The CLI binary is `bao`; many environment variables retain the `VAULT_` prefix for compatibility.

## What it does

- **Secure secret storage** — arbitrary K/V secrets encrypted before hitting persistent storage.
- **Dynamic secrets** — generated on demand (e.g. Kubernetes, SQL) with an automatic lease + revocation.
- **Data encryption (transit)** — encrypt/decrypt without storing the data ("encryption as a service").
- **Leasing & renewal / revocation** — every secret has a lease; supports revoking whole trees of secrets.

## Core workflow

Authenticate → Validate → Authorize (policy match) → Access. A client authenticates via an [auth method](../concepts/openbao-auth-methods.md), receives a [token](../concepts/openbao-tokens.md) bound to one or more [policies](../concepts/openbao-policies.md), and uses that token for subsequent requests. See [What is OpenBao?](../sources/openbao-what-is-openbao.md).

## Architecture at a glance

- The **barrier** is the encryption layer: all data is AES-256-GCM encrypted before it leaves OpenBao for the (untrusted) storage backend.
- OpenBao starts **sealed**; it must be [unsealed](../concepts/openbao-seal-unseal.md) (Shamir shares by default, or auto-unseal via KMS/HSM) to obtain the encryption key.
- The **core** routes requests, enforces ACLs, and drives audit logging; secrets engines, auth methods, and audit devices are mounted inside the barrier.
- See [Architecture](../sources/openbao-internals-architecture.md) and the [Security model](../sources/openbao-internals-security.md).

## Deployment

Runs as a single binary; production uses [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md) in a [highly available](../concepts/openbao-high-availability.md) cluster (recommended 5 nodes). On [Kubernetes](kubernetes.md) it is deployed via the [official Helm chart](../sources/openbao-k8s-helm.md), with an [Agent Injector](../sources/openbao-k8s.md) or [CSI provider](../sources/openbao-k8s-csi.md) for delivering secrets to pods.

## Lineage & governance

- Fork of HashiCorp Vault (created after Vault's move to the BUSL license); OpenBao is MPL-2.0.
- Governed as a Linux Foundation / OpenSSF Sandbox project.
- Source: [github.com/openbao/openbao](https://github.com/openbao/openbao); Helm chart: [openbao/openbao-helm](https://github.com/openbao/openbao-helm).

## Documentation map

- **Basics:**
  - [What is OpenBao?](../sources/openbao-what-is-openbao.md)
  - [Installing](../sources/openbao-install.md)
  - [Developer quick start](../sources/openbao-get-started.md)
- **Internals:**
  - [Architecture](../sources/openbao-internals-architecture.md)
  - [High Availability](../sources/openbao-internals-high-availability.md)
  - [Integrated Storage](../sources/openbao-internals-integrated-storage.md)
  - [Security model](../sources/openbao-internals-security.md)
- **Concepts:**
  - [Seal / Unseal](../concepts/openbao-seal-unseal.md)
  - [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
  - [High Availability](../concepts/openbao-high-availability.md)
  - [Policies](../concepts/openbao-policies.md)
  - [Tokens](../concepts/openbao-tokens.md)
  - [Auth methods](../concepts/openbao-auth-methods.md)
  - [Identity](../concepts/openbao-identity.md)
  - [Leases](../concepts/openbao-leases.md)
  - [Namespaces](../concepts/openbao-namespaces.md)
  - [Storage & backups](../sources/openbao-concept-storage.md)
- **Configuration:**
  - [Overview](../sources/openbao-config.md)
  - [TCP listener](../sources/openbao-config-listener-tcp.md)
  - [Seal](../sources/openbao-config-seal.md) / [Transit seal](../sources/openbao-config-seal-transit.md)
  - [Raft storage](../sources/openbao-config-storage-raft.md)
  - [PostgreSQL storage](../sources/openbao-config-storage-postgresql.md)
  - [K8s service registration](../sources/openbao-config-service-registration-kubernetes.md)
  - [Audit](../sources/openbao-config-audit.md)
  - [Self-initialization](../sources/openbao-config-self-init.md)
  - [Plugins (OCI)](../sources/openbao-config-plugins.md)
  - [Telemetry](../sources/openbao-config-telemetry.md)
  - [UI](../sources/openbao-config-ui.md)
- **Kubernetes:**
  - [Overview](../sources/openbao-k8s.md)
  - [Helm chart](../sources/openbao-k8s-helm.md)
  - [Run on K8s](../sources/openbao-k8s-helm-run.md)
  - [Helm configuration](../sources/openbao-k8s-helm-configuration.md)
  - [OpenTofu / Terraform](../sources/openbao-k8s-helm-terraform.md)
  - [Examples](../sources/openbao-k8s-helm-examples.md)
  - [CSI provider](../sources/openbao-k8s-csi.md)

## Related

- Concepts:
  - [Secrets Management](../concepts/secrets-management.md)
  - [Key Management](../concepts/key-management.md)
- Runs on:
  - [Kubernetes](kubernetes.md)
  - [Docker](docker.md)
- Upstream docs: <https://openbao.org/docs/>
