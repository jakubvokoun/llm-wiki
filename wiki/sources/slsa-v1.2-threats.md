---
title: "SLSA v1.2 — Threats & Mitigations"
tags: [slsa, supply-chain-security, threat-modeling]
sources: [slsa-v1.2-threats.md]
updated: 2026-05-07
---

# Threats & Mitigations

Comprehensive technical analysis of supply chain threats and SLSA mitigations. For a high-level overview see [Supply Chain Threats Overview](slsa-v1.2-threats-overview.md).

## Source threats

### (A) Producer: malicious intent

Intentional producer malice cannot be directly mitigated by SLSA. Consumers must independently establish trust in producers (open-source user base, legal/reputational incentives).

### (B) Modifying the source

**B1 — Submit without review (→ Source L4):** Two-party review required. Bot accounts cannot substitute for human reviewers. Rule exceptions (e.g., "documentation only") create exploitable loopholes.

**B2 — Evade change management (→ Source L2+):** History must be immutable (no force push). Protected tags cannot be updated. Approvals invalidated when proposed change is modified.

**B3 — Render review ineffective:** Collusion, "bugdoors", rubber-stamping — not currently addressed by SLSA.

**B4 — Forge change metadata (→ Source L2+):** SCS attributes changes to authenticated identities; records signed source provenance.

### (C) SCM compromise

Admin abuse and SCM vulnerabilities are addressed through verification (consumers only trust SCS with documented admin controls, audit logging) but not fully by SLSA per se.

## Build threats

### (D) External build parameters

Mitigated by verifying provenance against expectations (needs L1 provenance):

- Wrong fork → source location check fails
- Wrong branch → branch reachability check fails
- Injected build parameters → externalParameters check fails

### (E) Build process tampering

- **Forge provenance values (L2+):** Control plane generates provenance, not worker
- **Compromise build (L3):** Strong isolation; signing keys inaccessible to build workers
- **Cache poisoning (L3):** Cache isolated per build or has L3 provenance

### (F) Artifact publication

- **No provenance (L1):** Verifier rejects
- **Tampered artifact (L1):** Subject digest mismatch
- **Tampered provenance (L2):** Signature invalid

### (G) Distribution channel

Same mitigations as F, but applied by the consumer (or via VSA verification from a trusted intermediary).

## Usage threats

- **Dependency confusion (H):** Verify provenance showing expected internal builder
- **Typosquatting (H):** Not addressed by SLSA
- **Improper usage (I):** Not addressed by SLSA (see Secure by Design)

## Dependency threats

Recursive — every dependency has its own A–I threat profile. Apply SLSA recursively to build-time dependencies. Full dependency tracking expected in a future SLSA version.

Build-time dependency risks:

- Vulnerable library statically linked at build → output inherits vulnerability
- Compromised build tool (compiler, tar) → backdoor injected into output
- Runtime dependency loaded during testing → can influence build output

## Availability threats

Not currently addressed by SLSA: code deletion, unavailable dependencies, de-listed artifacts/provenance.

## Verification threats

- **Tampered expectations:** Changes to verifier's policy require two-party review
- **Hash collisions:** Use strong algorithms (SHA-256); MD5 and SHA-1 insufficient

## Related pages

- [Supply Chain Threats Overview](slsa-v1.2-threats-overview.md) — high-level category map
- [Build Requirements](slsa-v1.2-build-requirements.md) — how requirements address these threats
- [Source Requirements](slsa-v1.2-source-requirements.md) — how source controls address threats A–C
