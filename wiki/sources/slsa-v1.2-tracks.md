---
title: "SLSA v1.2 — Tracks"
tags: [slsa, supply-chain-security]
sources: [slsa-v1.2-tracks.md]
updated: 2026-05-07
---

# SLSA Tracks

SLSA organizes requirements into **tracks**, each addressing a distinct aspect of supply chain security. Each track has its own levels.

## Build Track

Focuses on the build process — how source code is transformed into a deployable artifact.

- Levels: L1, L2, L3
- Core mechanism: [build provenance](slsa-v1.2-build-provenance.md) — a signed attestation describing how the artifact was produced
- Trust anchor: the build platform (`builder.id`)
- Producer requirement: generate provenance
- Consumer requirement: verify provenance against expectations

See: [Build Track Basics](slsa-v1.2-build-track-basics.md), [Build Requirements](slsa-v1.2-build-requirements.md)

## Source Track

Focuses on the source code management process — how changes are made, reviewed, and recorded.

- Levels: L1, L2, L3, L4
- Core mechanism: source provenance — attestation from a Source Control System (SCS) about revision creation and review process
- Trust anchor: the Source Control System
- Producer/SCS requirement: enforce contribution controls, generate source attestations
- Consumer requirement: verify source provenance against expectations

See: [Source Requirements](slsa-v1.2-source-requirements.md), [Verifying Source](slsa-v1.2-verifying-source.md)

## Relationship between tracks

Tracks are independent — you can achieve Build L3 without any Source Track compliance. However, combining both tracks provides defense-in-depth:

- Source Track protects against source tampering (threats A–C)
- Build Track protects against build-time tampering (threats D–G)

## Future tracks

The specification anticipates additional tracks, such as:

- **Dependency track** — for transitive dependency integrity (currently under development)
- **Build environment track** — for build tooling and OS image integrity
- **Platform operations track** — for securing the platforms themselves

## Related pages

- Concept: [SLSA](../concepts/slsa.md)
- Concept: [SLSA Build Track](../concepts/slsa-build-track.md)
- Concept: [SLSA Source Track](../concepts/slsa-source-track.md)
