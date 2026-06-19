---
title: "SLSA v1.2 — Build Track Basics"
tags: [slsa, supply-chain-security, provenance, build]
sources: [slsa-v1.2-build-track-basics.md]
updated: 2026-05-07
---

# SLSA Build Track Basics

The Build Track focuses on the process of transforming source code into deployable artifacts and ensuring that process is trustworthy.

## Levels overview

| Level | Name                   | Key property                                            | Who benefits                                         |
| ----- | ---------------------- | ------------------------------------------------------- | ---------------------------------------------------- |
| L1    | Provenance exists      | Artifact has provenance (possibly unsigned)             | Consumers who want basic traceability                |
| L2    | Provenance authentic   | Provenance is signed by a trusted hosted build platform | Consumers who need to verify build platform identity |
| L3    | Provenance unforgeable | Even the build itself cannot forge its own provenance   | High-security environments                           |

## Level 0 (no SLSA)

No guarantees. No provenance. Starting point for improvement.

## Level 1

**Provenance exists.** The build platform generates provenance for every artifact.

- Provenance may be unsigned or self-signed
- Consumers can trace artifacts back to their source
- Primary benefit: visibility — can identify what was built, from where, by what process
- Does not protect against a determined attacker who can modify provenance

Required provenance fields: `buildType`, `externalParameters`, `builder.id`

## Level 2

**Provenance authentic.** Provenance is signed by a trusted build platform's control plane, not the build worker.

- Build platform is "hosted" (not something a developer runs locally)
- Provenance is generated and signed by the trusted control plane, not by the tenant build process
- Protects against: tampering with provenance by the build tenant
- Implies: verifying the signature validates the provenance came from a trusted build platform

## Level 3

**Provenance unforgeable.** Even a determined adversary who controls the build environment cannot forge provenance.

- Strong isolation between build environment and control plane
- Control plane has exclusive access to signing keys
- Build workers cannot influence provenance beyond their output artifacts
- Build environments are isolated from one another
- Protects against: compromised build workers, cross-build contamination, cache poisoning

## Adoption path

L1 → L2 → L3 is the intended path. Each level raises the bar for what an attacker must compromise:

- L1: compromise the provenance format and the consumer's verification
- L2: also compromise the build platform's signature key or control plane
- L3: also break the isolation between build environment and control plane

## Related pages

- [Build Requirements](slsa-v1.2-build-requirements.md) — detailed requirements per level
- [Verifying Artifacts](slsa-v1.2-verifying-artifacts.md) — consumer verification process
- Concept: [SLSA Build Track](../concepts/slsa-build-track.md)
