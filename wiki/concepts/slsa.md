---
title: "SLSA (Supply-chain Levels for Software Artifacts)"
tags: [slsa, supply-chain-security, provenance]
sources:
  [
    slsa-v1.2-about.md,
    slsa-v1.2-tracks.md,
    slsa-v1.2-terminology.md,
    slsa-v1.2-principles.md,
  ]
updated: 2026-05-07
---

# SLSA

**SLSA** ("salsa") — Supply-chain Levels for Software Artifacts — is an industry-consensus framework for incrementally improving software supply chain security. Developed initially by Google, now maintained under the Linux Foundation as a cross-industry collaboration.

## Core idea

Artifacts should come with **cryptographically verifiable provenance** — a signed statement about where the artifact came from, how it was built, and by what platform. Consumers verify this provenance before using an artifact.

This shifts trust from "do I trust every developer who can push to this registry?" to "do I trust this build platform?"

## Tracks and levels

SLSA is organized into **tracks** (aspects of the supply chain) each with **levels** (increasingly hardened security within that track):

| Track            | Levels | What it covers                         |
| ---------------- | ------ | -------------------------------------- |
| **Build Track**  | L1–L3  | How source becomes artifact            |
| **Source Track** | L1–L4  | How source code is managed and changed |

Higher levels = stronger guarantees = higher implementation cost. Levels are designed to be incrementally adoptable.

## Build Track levels at a glance

| Level | Key property                                                    |
| ----- | --------------------------------------------------------------- |
| L1    | Provenance exists (unsigned OK)                                 |
| L2    | Provenance authentic (signed by trusted hosted platform)        |
| L3    | Provenance unforgeable (isolated build, hardened control plane) |

## Source Track levels at a glance

| Level | Key property                                          |
| ----- | ----------------------------------------------------- |
| L1    | Source in version control with retained history       |
| L2    | Branch history immutable; source provenance available |
| L3    | Development process enforced by machine controls      |
| L4    | Two-party review required for all changes             |

## Five guiding principles

1. **Simple levels** — easy to understand and apply
2. **Trust platforms, verify artifacts** — trust the build platform, not individual developers
3. **Trust code, not individuals** — identity can be spoofed; signed provenance is harder to fake
4. **Prefer attestations over inferences** — explicit signed metadata vs. implicit location-based trust
5. **Support anonymous contributions** — security from process, not from identity

## What SLSA doesn't cover

- Code quality or secure coding practices
- Intentionally malicious producers
- Transitive dependency trust (SLSA applies per-artifact, not recursively by default)

## Key artifacts

- [Build provenance](slsa-provenance.md) — `predicateType: https://slsa.dev/provenance/v1`
- [VSA](verification-summary-attestation.md) — `predicateType: https://slsa.dev/verification_summary/v1`
- [Software attestation](software-attestation.md) — the general attestation model

## Supply chain threats SLSA addresses

| Threats      | Addressed by           |
| ------------ | ---------------------- |
| A–C (source) | Source Track           |
| D–G (build)  | Build Track            |
| H–I (usage)  | Complementary measures |

## Related sources

- [About SLSA](../sources/slsa-v1.2-about.md)
- [SLSA Tracks](../sources/slsa-v1.2-tracks.md)
- [Guiding Principles](../sources/slsa-v1.2-principles.md)
- [Use Cases](../sources/slsa-v1.2-use-cases.md)
- [Supply Chain Security](supply-chain-security.md) — broader context
- Entity: [SLSA](../entities/slsa.md)
