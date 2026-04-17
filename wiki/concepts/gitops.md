---
title: "GitOps"
tags: [gitops, kubernetes, cd, deployment, argo-cd, flux]
sources: [k8s-best-practices-readme.md]
updated: 2026-04-16
---

# GitOps

GitOps is a Continuous Deployment pattern where Git is the single source of truth for all declarative infrastructure and application configuration. Changes are made via pull requests; automation syncs cluster state to match Git state.

## Core Principles

1. **Declarative**: All desired state described in Git as manifests
2. **Versioned**: Full history and audit trail of every change
3. **Automated sync**: Reconciliation loop keeps cluster state ≡ Git state
4. **Self-healing**: Drift from desired state is auto-corrected

## Tools

| Tool                                      | Description                                                 |
| ----------------------------------------- | ----------------------------------------------------------- |
| [Argo CD](https://argoproj.github.io/cd/) | Declarative GitOps CD for Kubernetes; web UI, multi-cluster |
| [Flux](https://fluxcd.io/)                | CNCF project; GitOps toolkit; Helm + Kustomize support      |

Both support: automated sync, drift detection, multi-environment, notifications.

## Benefits

- **Rollback**: `git revert` reverts cluster state
- **Audit trail**: every change has a PR, author, timestamp
- **Self-healing**: accidental manual changes are auto-reverted
- **Consistency**: Dev/staging/prod envs diverge only where explicitly branched

## Security Considerations

- Separate Git repos for app code vs. manifests (limits blast radius)
- Use signed commits or tag-based promotion to prevent unauthorized deployments
- Restrict who can merge to the manifests repo
- Argo CD / Flux run in-cluster with minimal RBAC — audit their service account permissions
- Avoid storing secrets in manifests — use [Sealed Secrets](secrets-management.md) or External Secrets Operator

## Related Concepts

- [CI/CD Security](cicd-security.md)
- [Kubernetes Security](kubernetes-security.md)
- [Secrets Management](secrets-management.md)
- [Supply Chain Security](supply-chain-security.md)

## Sources

- [Kubernetes Best Practices 101](../sources/k8s-best-practices-readme.md)
