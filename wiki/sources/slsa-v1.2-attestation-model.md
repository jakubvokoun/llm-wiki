---
title: "SLSA v1.2 — Software Attestation Model"
tags: [slsa, supply-chain-security, provenance, in-toto]
sources: [slsa-v1.2-attestation-model.md]
updated: 2026-05-07
---

# Software Attestation Model

The model underlying SLSA attestations, based on the in-toto attestation framework.

## What is an attestation?

An attestation is **authenticated, machine-readable metadata** about one or more software artifacts. Unlike raw signatures (which only prove who signed), attestations include explicit, structured metadata about what the signer is claiming.

## Components

| Component | Purpose |
| --- | --- |
| **Artifact** | Immutable blob identified by content hash |
| **Envelope** | Authenticates the message (signature + content) |
| **Statement** | Binds attestation to specific artifacts (subject + predicate) |
| **Predicate** | Arbitrary metadata in a predicate-specific schema |
| **Bundle** | Collection of attestations for an artifact |

The **subject** identifies which artifact(s) the predicate applies to. The **predicate type** URI identifies the schema and semantics of the metadata.

## Recommended suite

| Layer | Recommendation |
| --- | --- |
| Envelope | DSSE (Dead Simple Signing Envelope) with ECDSA over NIST P-256+ |
| Statement | in-toto attestation format |
| Predicate | SLSA Provenance (`https://slsa.dev/provenance/v1`), SPDX, or other |
| Bundle | JSON Lines (one attestation per line) |

## Format guidance by use case

**First-party (internal):** Any format is acceptable for internal use. To make an external SLSA claim, use SLSA Provenance format.

**Open source:** Use SLSA Provenance format to promote ecosystem interoperability and enable verification with the generic slsa-verifier tool.

**Closed source / third-party:** Use [Verification Summary Attestations (VSAs)](slsa-v1.2-verification-summary.md) to communicate compliance externally without exposing internal build details.

## Storage and lookup

Where attestations are stored and how verifiers find them for a given artifact:

- OCI registries: OCI referrers API attaches attestations to images
- Package registries: sidecar files with well-known naming convention
- Transparency logs: Sigstore/Rekor for public accountability
- Dedicated attestation stores: keyed by artifact digest

SLSA v1.2 leaves storage/lookup conventions as TBD.

## Related pages

- [Build Provenance Schema](slsa-v1.2-build-provenance.md) — the SLSA provenance predicate
- [Verification Summary Attestation](slsa-v1.2-verification-summary.md) — the VSA predicate
- [Distributing Provenance](slsa-v1.2-distributing-provenance.md) — how attestations are distributed
- Concept: [Software Attestation](../concepts/software-attestation.md)
