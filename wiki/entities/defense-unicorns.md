---
title: "Defense Unicorns"
tags: [org, defense-tech, kubernetes, airgap, zarf, uds-core]
sources: [uds-core-concepts-overview.md]
updated: 2026-05-07
---

# Defense Unicorns

Defense Unicorns is a defense-tech company building open-source tools for secure,
air-gapped Kubernetes deployments. Their primary products are:

- **[Zarf](zarf.md)** — airgap packaging tool for Kubernetes; bundles images, charts,
  and manifests into OCI artifacts deployable in disconnected environments
- **[UDS Core](uds-core.md)** — opinionated Kubernetes platform built on top of Zarf;
  provides service mesh, identity, monitoring, logging, runtime security, and policy
  enforcement as a single deployable baseline
- **[Pepr](pepr.md)** — Kubernetes admission controller framework (TypeScript-based);
  used as UDS Core's policy engine

Their products target regulated and defense environments (DoD, FedRAMP/ATO) but are
open-source and usable in any air-gapped or security-sensitive context.
