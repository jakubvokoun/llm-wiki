---
title: "SLSA v1.2 — Provenance Overview"
tags: [slsa, supply-chain-security, provenance]
sources: [slsa-v1.2-provenance.md]
updated: 2026-05-07
---

# Provenance Overview

In SLSA, "provenance" refers to verifiable information that can track an artifact back through the supply chain to its origin — where, when, and how something was produced.

## Types of provenance

### Build provenance

Tracks the output of a build process back to the source code used to produce it.

- Format: `predicateType: https://slsa.dev/provenance/v1`
- Records: what source was used, which build platform ran the build, what parameters were used, when it ran
- Trust anchor: the build platform (`builder.id`)

See: [Build Provenance Schema](slsa-v1.2-build-provenance.md)

### Source provenance

Tracks the creation of source code revisions and the change management processes that were in place during their creation.

- Issued by the Source Control System (SCS)
- Records: how the revision was created, who reviewed it, what branch controls were enforced
- Trust anchor: the Source Control System

See: [Source Requirements](slsa-v1.2-source-requirements.md)

## Key distinction

Both types of provenance are attestations — signed, authenticated statements about software artifacts. They differ in:

|                   | Build provenance  | Source provenance         |
| ----------------- | ----------------- | ------------------------- |
| Tracks            | Artifact ← source | Source revision ← process |
| Issued by         | Build platform    | Source Control System     |
| Trust anchor      | `builder.id`      | SCS identity              |
| Addresses threats | D, E, F, G        | A, B, C                   |

## Related pages

- [Build Provenance Schema](slsa-v1.2-build-provenance.md) — full schema reference
- [Source Requirements](slsa-v1.2-source-requirements.md) — source provenance details
- Concept: [SLSA Provenance](../concepts/slsa-provenance.md)
