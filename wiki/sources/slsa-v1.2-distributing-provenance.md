---
title: "SLSA v1.2 — Distributing Provenance"
tags: [slsa, supply-chain-security, provenance]
sources: [slsa-v1.2-distributing-provenance.md]
updated: 2026-05-07
---

# Distributing Provenance

How provenance attestations are packaged and distributed alongside artifacts.

## Release model

A **release** = artifact(s) + associated attestation bundle. Provenance must be distributed as a unit with the artifact it covers so consumers can verify it at download/install time.

## Publication venues

Producers can publish provenance in multiple places:

| Venue                           | Description                                         | Use case                                       |
| ------------------------------- | --------------------------------------------------- | ---------------------------------------------- |
| **Source repository**           | Attestation stored alongside source in VCS          | Internal use, traceability                     |
| **Registry sidecars**           | Attestation attached to the package in the registry | Package ecosystems (npm, PyPI, OCI registries) |
| **Transparency logs**           | Append-only public log (e.g., Rekor/Sigstore)       | Public accountability, audit trail             |
| **Dedicated attestation store** | Separate storage keyed by artifact digest           | Large-scale deployments                        |

## Format requirements

- Provenance is encoded in a DSSE (Dead Simple Signing Envelope)
- The DSSE contains a signed in-toto statement
- The statement contains the SLSA provenance predicate
- Bundle: JSON Lines format (one attestation per line)

## Immutability

Published provenance MUST be treated as immutable. An artifact's provenance describes a specific build event that cannot be retroactively changed. Consumers should cache provenance keyed by artifact digest.

## Registry-native distribution

Modern OCI registries (Docker Hub, GitHub Container Registry, AWS ECR) support attaching attestations to images via OCI referrers API. This allows provenance to be co-located with the image in the same registry.

For non-OCI registries, provenance is often stored as a parallel artifact with a well-known naming convention.

## Verification Summary Attestations (VSAs) as proxies

Instead of distributing full build provenance, a verifier can evaluate the provenance and issue a [VSA](../concepts/verification-summary-attestation.md). Consumers verify the VSA instead of the raw provenance — useful for:

- Hiding internal build details (closed-source vendors)
- Simplifying verification in consumer pipelines

## Related pages

- [Build Provenance Schema](slsa-v1.2-build-provenance.md) — the provenance format
- [Verification Summary Attestation](slsa-v1.2-verification-summary.md) — VSA as a distribution mechanism
- [Verifying Artifacts](slsa-v1.2-verifying-artifacts.md) — consumer-side verification
- Concept: [Software Attestation](../concepts/software-attestation.md)
