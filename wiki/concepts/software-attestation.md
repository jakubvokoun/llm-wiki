---
title: "Software Attestation"
tags: [slsa, supply-chain-security, provenance, in-toto]
sources: [slsa-v1.2-attestation-model.md]
updated: 2026-05-07
---

# Software Attestation

An attestation is **authenticated, machine-readable metadata** about one or more software artifacts. It is the fundamental communication mechanism for supply chain security claims.

## Attestation vs. raw signature

|               | Raw signature                          | Attestation                                 |
| ------------- | -------------------------------------- | ------------------------------------------- |
| What's signed | The artifact directly                  | A statement about the artifact              |
| Metadata      | Implicit (single bit: "I signed this") | Explicit, structured (who, what, when, why) |
| Flexibility   | One claim per key                      | Arbitrary claims per key                    |

## Components

```
Attestation
├── Envelope     — authenticates the message (signature + content)
│   └── Signature — identifies the attester
├── Statement    — binds attestation to specific artifacts
│   ├── Subject  — which artifact(s) this applies to (by content hash)
│   └── Predicate — the actual metadata
└── Predicate    — arbitrary metadata in predicate-specific schema
    └── MAY contain links to related artifacts
```

**Bundle** = a collection of attestations for a set of artifacts.

## SLSA recommended suite

| Layer         | Technology                                                                  |
| ------------- | --------------------------------------------------------------------------- |
| **Envelope**  | DSSE (Dead Simple Signing Envelope) with ECDSA over NIST P-256+ and SHA-256 |
| **Statement** | in-toto attestation format                                                  |
| **Predicate** | SLSA Provenance, SPDX, CycloneDX, or other formats                          |
| **Bundle**    | JSON Lines (one attestation per line)                                       |

## Common predicate types

| Predicate       | URI                                        | Used for                     |
| --------------- | ------------------------------------------ | ---------------------------- |
| SLSA Provenance | `https://slsa.dev/provenance/v1`           | How an artifact was built    |
| SLSA VSA        | `https://slsa.dev/verification_summary/v1` | Verification result summary  |
| SPDX            | `https://spdx.dev/Document`                | Software bill of materials   |
| CycloneDX       | (various)                                  | SBOM alternative             |
| VEX             | (various)                                  | Vulnerability exploitability |

## Format guidance

| Context                | Recommendation                                          |
| ---------------------- | ------------------------------------------------------- |
| First-party / internal | Any format; use SLSA Provenance to make external claims |
| Open source            | SLSA Provenance (ecosystem interoperability)            |
| Closed source / vendor | VSA (communicate compliance without exposing internals) |

## Storage and lookup

- **OCI registries**: OCI referrers API (attestations attached to image manifests)
- **Package registries**: Sidecar files with well-known naming
- **Transparency logs**: Sigstore/Rekor (public, append-only)
- **Dedicated stores**: Keyed by artifact digest

## Related pages

- [SLSA Provenance](slsa-provenance.md) — the primary SLSA predicate type
- [Verification Summary Attestation](verification-summary-attestation.md) — derivative attestation
- [Attestation Model](../sources/slsa-v1.2-attestation-model.md)
- Entity: [in-toto](../entities/in-toto.md)
