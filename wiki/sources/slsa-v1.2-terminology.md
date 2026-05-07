---
title: "SLSA v1.2 — Terminology"
tags: [slsa, supply-chain-security, provenance]
sources: [slsa-v1.2-terminology.md]
updated: 2026-05-07
---

# SLSA Terminology

Core terms and concepts used throughout the SLSA specification.

## Artifacts

- **Artifact**: Immutable blob of data identified by cryptographic hash. The fundamental unit in SLSA.
- **Source**: Human-readable version of the artifact, written by a human, stored in a VCS.
- **Package**: Artifact that is distributed to consumers. One package may contain multiple artifacts.
- **Build**: Process that transforms a set of input artifacts into a set of output artifacts.

## Attestations

- **Attestation**: Authenticated, machine-readable metadata about one or more artifacts. Contains envelope + statement + predicate.
- **Provenance**: Attestation describing how an artifact was produced — the key attestation type in SLSA.
- **Bundle**: Collection of attestations associated with an artifact.
- **Verification Summary Attestation (VSA)**: Attestation that a verifier evaluated an artifact and found it met a certain SLSA level.

## Roles

- **Producer**: Entity that creates and distributes software artifacts (org, project, team).
- **Consumer**: Entity that uses software artifacts.
- **Verifier**: Entity that evaluates whether an artifact meets SLSA requirements and issues VSAs.
- **Infrastructure provider**: Entity providing build platforms, package registries, CI/CD — the bridge between producers and consumers.

## Build model

- **Builder**: Platform that runs the build process. The `builder.id` is the trust anchor for the Build Track.
- **Build platform**: Multi-tenant infrastructure that runs builds. The trusted control plane generates provenance.
- **Build environment**: The isolated environment where a single build runs.
- **Source Control System (SCS)**: Platform that manages source code and enforces access controls. The trust anchor for the Source Track.

## Trust model

- **Roots of trust**: Public keys or other anchors used to verify provenance signatures. Consumers configure roots of trust for build platforms they trust.
- **Expectations**: Policy describing what provenance values are acceptable for a given package. Verified at consumption time.
- **SLSA level**: A shorthand for a set of security properties verified for a given artifact on a given track.

## Distribution model

- **Release**: Combination of one or more artifacts and their associated attestations.
- **Registry**: Repository where packages and their attestations are published.

## Related pages

- [SLSA Build Track Basics](slsa-v1.2-build-track-basics.md) — how levels are defined
- [Attestation Model](slsa-v1.2-attestation-model.md) — detailed attestation structure
- Concept: [SLSA](../concepts/slsa.md)
