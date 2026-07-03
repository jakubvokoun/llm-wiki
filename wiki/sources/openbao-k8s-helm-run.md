---
title: "OpenBao — Run on Kubernetes"
tags: [openbao, kubernetes, helm, operations, upgrade, auto-unseal]
sources: [openbao-k8s-helm-run.md]
updated: 2026-07-03
---

# OpenBao — Run on Kubernetes

Operating an [OpenBao](../entities/openbao.md) cluster deployed by the [Helm chart](openbao-k8s-helm.md) — install modes, init/unseal, upgrades, and the production checklist.

## Key Takeaways

- **Modes** via `--set`: `server.dev.enabled=true` (dev), default standalone, `server.ha.enabled=true` (HA, 3 servers on Integrated Storage), `injector.externalVaultAddr=...` (external). Override values inline or via `--values file.yml`. The chart configures resources but **does not operate** OpenBao (you own monitoring/backup/upgrade).
- **Init & unseal (standalone/HA):** `kubectl exec -ti openbao-0 -- bao operator init` prints the unseal key shares + root token; run `bao operator unseal` until the threshold is met, per pod. Pods report `1/1` once unsealed.
- **[Auto-unseal](../concepts/openbao-seal-unseal.md):** mount cloud KMS creds so rescheduled pods self-unseal — e.g. GCP KMS (`credentials.json` secret at `/openbao/userconfig/kms-creds/` + `seal "gcpckms"`) or AWS KMS (`AWS_ACCESS_KEY_ID`/`SECRET` env from a secret + `seal "awskms"`), configured in `server.ha.config`.
- **Probes:** readiness/liveness are configurable against `/v1/sys/health` (e.g. `standbyok=true&sealedcode=204&uninitcode=204`).
- **Upgrades:** StatefulSet uses **`OnDelete`** (never `RollingUpdate`) — standbys must be updated before the active node to avoid failing over to an older version. Set `server.image.tag`, `helm upgrade --dry-run`, then **manually delete pods** (standbys first via `-l openbao-active=false`, active last), unsealing each if not auto-unsealing. **Always back up data first** (no downgrade guarantee).
- **Protect sensitive config:** put storage credentials in a Kubernetes secret mounted as an extra `-config` file rather than the plaintext configmap the chart renders.
- **Production checklist:** end-to-end TLS (don't terminate at the LB), single tenancy (`affinity`), enable auditing (`auditStorage` PV), immutable upgrades, upgrade frequently, restrict storage-backend access.

## Related

- [Helm chart](openbao-k8s-helm.md)
- [Seal / Unseal](../concepts/openbao-seal-unseal.md)
- [K8s service registration](openbao-config-service-registration-kubernetes.md)
- [OpenTofu deployment](openbao-k8s-helm-terraform.md)
- [High Availability](../concepts/openbao-high-availability.md)
