---
title: "SLSA Build Track"
tags: [slsa, supply-chain-security, provenance, build]
sources:
  [
    slsa-v1.2-build-track-basics.md,
    slsa-v1.2-build-requirements.md,
    slsa-v1.2-verifying-artifacts.md,
    slsa-v1.2-assessing-build-platforms.md,
  ]
updated: 2026-05-07
---

# SLSA Build Track

The Build Track addresses how source code is transformed into deployable artifacts and how that transformation can be verified. It is the primary SLSA track for protecting against build-time supply chain attacks.

## Trust model

The trust anchor is the **build platform** (`builder.id`). Consumers configure which build platforms they trust and at what level. Provenance from those platforms, signed by their trusted control plane, can then be verified.

## Levels

### Level 1 — Provenance exists

- Build platform generates provenance for every artifact
- Fields: `buildType`, `externalParameters`, `builder.id` (all required)
- Signature may be absent or self-signed
- Benefit: artifact traceability — can identify source, builder, process

### Level 2 — Provenance authentic

- Provenance generated and signed by trusted control plane (not the build worker)
- Build platform is "hosted" (not user-run)
- Protects against: tenant tampering with provenance
- Verifying the signature confirms the provenance came from the trusted platform

### Level 3 — Provenance unforgeable

- Strong isolation between build environment and control plane
- Control plane has exclusive signing key access
- Build environments isolated from one another (separate VMs or equivalent)
- Build caches isolated or have SLSA L3 provenance
- Protects against: compromised build workers, cross-build contamination, cache poisoning

## Producer responsibilities

- Use a build platform that meets the required level
- Ensure all build inputs are captured in provenance
- At L3: `externalParameters` must be complete — no hidden inputs

## Consumer verification (3 steps)

1. **Check level:** Retrieve provenance, verify signature, determine SLSA level of builder
2. **Check expectations:** Verify source location, builder ID, build configuration, parameters match expected values
3. **Check dependencies (optional):** Apply verification recursively to build-time dependencies

## Adversary profiles (who L1–L3 protects against)

| Adversary            | L1  | L2      | L3           |
| -------------------- | --- | ------- | ------------ |
| External attacker    | ✓   | ✓       | ✓            |
| Build tenant         | –   | ✓       | ✓            |
| Project maintainer   | –   | partial | ✓            |
| Build platform admin | –   | –       | verification |

## Platform assessment checklist

Platforms must be assessed against 5 components:

1. External parameters — all captured in provenance?
2. Control plane — isolated from tenant code?
3. Build environment — isolated between builds?
4. Build cache — isolated or has provenance?
5. Output storage — protected from post-generation tampering?

## Key sources

- [Build Track Basics](../sources/slsa-v1.2-build-track-basics.md)
- [Build Requirements](../sources/slsa-v1.2-build-requirements.md)
- [Verifying Artifacts](../sources/slsa-v1.2-verifying-artifacts.md)
- [Assessing Build Platforms](../sources/slsa-v1.2-assessing-build-platforms.md)
- Related: [SLSA](slsa.md), [SLSA Provenance](slsa-provenance.md)
