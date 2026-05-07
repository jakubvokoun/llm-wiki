---
title: "UDS Core — Platform Overview"
tags: [uds-core, kubernetes, platform, airgap, versioning, flavors]
sources: [uds-core-platform-overview.md]
updated: 2026-05-07
---

# UDS Core — Platform Overview

UDS Core turns a Kubernetes cluster into a secure, observable platform. It provides
shared services (networking, identity, observability, security, and backup) so
application teams focus on mission logic instead of infrastructure plumbing.

## Platform section topics

- **[Functional Layers](uds-core-platform-functional-layers.md)** — how UDS Core splits
  into discrete capability packages; layer selection, dependency ordering, when to use
  individual layers
- **Supported Distributions** — Kubernetes distributions tested in CI
- **Environments** — how Core adapts configuration across dev, staging, production
- **Platform vs Application Layer** — responsibility boundary between shared platform
  and mission workloads
- **Flavors (Core Variants)** — upstream, registry1, and unicorn image variants and
  their CVE posture
- **[Security](uds-core-platform-security.md)** — layered defense model across supply
  chain, airgap, identity, networking, admission control, runtime, observability, compliance
- **Versioning & Releases** — release cadence, semantic versioning, support window

## Related pages

- [UDS Core](../entities/uds-core.md)
- [UDS Core Platform Security](uds-core-platform-security.md)
- [UDS Core Platform Functional Layers](uds-core-platform-functional-layers.md)
