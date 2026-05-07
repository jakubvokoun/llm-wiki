---
title: "SLSA v1.2 — Assessing Build Platforms"
tags: [slsa, supply-chain-security, build, threat-modeling]
sources: [slsa-v1.2-assessing-build-platforms.md]
updated: 2026-05-07
---

# Assessing Build Platforms

How to evaluate whether a build platform satisfies SLSA Build Level requirements.

## Adversary profiles

Understanding who you're defending against:

| Adversary | Capabilities | Mitigated by |
| --- | --- | --- |
| **External attacker** | No access to build infrastructure | L1+ provenance reveals if source/builder unexpected |
| **Build tenant (contributor)** | Can run arbitrary code in build environment | L2+ (control plane generates provenance, not worker) |
| **Project maintainer** | Can configure CI/CD settings, workflows | L3 (complete externalParameters prevent hidden injection) |
| **Build platform admin** | Can access internal platform controls | Verification: platform must have admin abuse controls |
| **Platform insider** | Can modify platform infrastructure | Verification: platform must have insider threat controls |

## Five platform components to assess

### 1. External parameters

What can callers of the build inject into the build?

- At L3: ALL external parameters must appear in provenance
- Assessment: Are there any parameters that affect the build but aren't captured?
- Risk: hidden injection vectors (custom compiler flags, env vars, etc.)

### 2. Control plane

The trusted component that manages builds and generates provenance.

- Assessment: Who can access the control plane? Can it be modified by build tenants?
- Risk: A compromised control plane can issue forged provenance

### 3. Build environment

The execution environment for each build.

- Assessment: How are environments isolated? Can one build affect another?
- At L3: strong isolation required (separate VMs or equivalent)
- Risk: malicious builds poisoning subsequent builds' state or cache

### 4. Build cache

Cached artifacts reused across builds.

- Assessment: Who can write to the cache? Is the cache keyed by transitive inputs?
- At L3: cache must be isolated or cache entries must have SLSA L3 provenance
- Risk: cache poisoning — attacker injects malicious artifact into shared cache

### 5. Output storage

Where build outputs (artifacts + provenance) are stored before publishing.

- Assessment: Can build workers modify their own provenance after it's generated?
- Risk: post-generation provenance tampering

## Assessment process

The SLSA spec recommends:

1. Identify all components of the build platform
2. Model threats against each component from each adversary class
3. Document what controls are in place
4. Determine which SLSA level the controls satisfy
5. Document the assessment as part of the platform's SLSA compliance claim

## Related pages

- [Build Requirements](slsa-v1.2-build-requirements.md) — formal requirements per level
- [Threats & Mitigations](slsa-v1.2-threats.md) — threat E (build process) and F (artifact publication)
- Concept: [SLSA Build Track](../concepts/slsa-build-track.md)
