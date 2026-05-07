---
title: "SLSA v1.2 — Guiding Principles"
tags: [slsa, supply-chain-security]
sources: [slsa-v1.2-principles.md]
updated: 2026-05-07
---

# SLSA Guiding Principles

Five principles that shape SLSA's design decisions:

## 1. Simple levels

Levels should be easy to understand and apply. SLSA uses a small number of clearly defined, incrementally adoptable levels rather than a complex scoring matrix. Each level is a meaningful step-up in security guarantees.

## 2. Trust platforms, verify artifacts

Rather than trusting every individual developer and their machine, trust the **build platform** as a whole. The platform is responsible for generating trustworthy provenance; consumers verify that provenance against expectations.

This is the key insight that makes SLSA scalable: instead of auditing thousands of developers, audit a handful of build platforms.

## 3. Trust code, not individuals

The security model is based on what code was produced through what process, not on who wrote or approved it. Identity of individuals can be spoofed; the code itself, with cryptographic provenance, is harder to fake.

## 4. Prefer attestations over inferences

Explicit, machine-readable, signed attestations are preferred over inferences from metadata or convention. For example, provenance is a signed statement that says "this artifact was built from this source" rather than merely placing the artifact in a trusted location.

## 5. Support anonymous contributions

SLSA should not require contributors to be identified — it must support anonymous and pseudonymous open source contribution. Security guarantees come from the process (two-party review, build platform), not from knowing who wrote the code.

## Design implications

These principles explain why SLSA:

- Uses cryptographically signed attestations (principle 4) rather than access-control-only approaches
- Focuses on the build platform (principle 2) as the trust anchor rather than individual contributor identity (principle 5)
- Defines levels (principle 1) rather than a compliance checklist
- Evaluates artifacts (principle 3) rather than individuals or organizations

## Related pages

- Concept: [SLSA](../concepts/slsa.md)
- [Attestation Model](slsa-v1.2-attestation-model.md) — how attestations implement principle 4
