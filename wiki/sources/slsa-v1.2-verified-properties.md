---
title: "SLSA v1.2 — Verified Properties"
tags: [slsa, supply-chain-security, provenance, verification]
sources: [slsa-v1.2-verified-properties.md]
updated: 2026-05-07
---

# SLSA Verified Properties

An extension mechanism for expressing security properties that don't fit neatly within SLSA track levels.

## Purpose

Some supply chain controls don't map cleanly to existing SLSA levels. Verified Properties provide a standard way to express these properties in a [VSA's](slsa-v1.2-verification-summary.md) `verifiedLevels` field without introducing new tracks or levels.

Properties MAY be included in `verifiedLevels` when the VSA issuer has verified they are met.

## Defined Properties

### SLSA_SOURCE_TWO_PARTY_REVIEWED

Indicates the source code associated with the artifact has been reviewed by two trusted persons.

- **MUST** only be issued in accordance with the Source Track's two-party-review requirements
- MAY be added at any source level (L1+) in which an SCS can make this claim
- Useful for expressing two-party review independently of other Source Track level requirements

### SLSA_BUILD_REPRODUCED

Indicates the artifact has been reproduced by two or more independent builders.

- **MUST** only be issued if the artifact has build provenance from **two or more independently operated Build Platforms** both trusted by the VSA issuer
- Addresses reproducible builds as a separate concern from build platform integrity
- Provides stronger assurance that the build output is deterministic and hasn't been tampered with

## Custom properties

Users MAY define custom property values but **MUST NOT** use values starting with `SLSA_` — that namespace is reserved for official SLSA properties.

## Usage in VSAs

Properties appear as additional entries in the `verifiedLevels` array alongside standard SLSA level values:

```json
"verifiedLevels": [
  "SLSA_BUILD_LEVEL_3",
  "SLSA_SOURCE_LEVEL_2",
  "SLSA_SOURCE_TWO_PARTY_REVIEWED",
  "SLSA_BUILD_REPRODUCED"
]
```

## Related pages

- [Verification Summary Attestation](slsa-v1.2-verification-summary.md) — how verifiedLevels is used
- [Source Requirements](slsa-v1.2-source-requirements.md) — two-party review in Source Track
- Concept: [Verification Summary Attestation](../concepts/verification-summary-attestation.md)
