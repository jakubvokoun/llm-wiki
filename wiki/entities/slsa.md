---
title: "SLSA (Project)"
tags: [slsa, supply-chain-security, linux-foundation]
type: project
updated: 2026-05-07
---

# SLSA

**SLSA** (Supply-chain Levels for Software Artifacts, pronounced "salsa") is a cross-industry collaboration for supply chain security, under the Linux Foundation.

## Overview

- **Type:** Open specification / framework
- **Governance:** Linux Foundation; SLSA Working Group
- **License:** Community Specification License 1.0
- **Website:** https://slsa.dev/
- **Spec repo:** https://github.com/slsa-framework/slsa

## History

Originally developed internally at Google (under the name "Binary Authorization for Borg"), SLSA was open-sourced in 2021 coinciding with the U.S. Executive Order on Improving the Nation's Cybersecurity (May 2021), which called for a universal framework for hardening software supply chains.

## Current version

**v1.2** (Approved) — includes both Build Track (L1–L3) and Source Track (L1–L4), plus attestation formats and Verified Properties.

## Key specifications

- Build Track requirements and levels
- Source Track requirements and levels
- Build Provenance format (`https://slsa.dev/provenance/v1`)
- Verification Summary Attestation format (`https://slsa.dev/verification_summary/v1`)
- Verified Properties extension mechanism

## Tools and ecosystem

- **slsa-verifier** — reference verifier for SLSA provenance
- **Sigstore/Rekor** — transparency log used for SLSA provenance publication
- **GitHub Actions SLSA Generator** — generates L2/L3 provenance for GitHub Actions builds
- **SLSA Framework** — GitHub Actions-based tooling for producers
- **Binary Authorization (GCP)** — policy enforcement using SLSA provenance

## Related pages

- Concept: [SLSA](../concepts/slsa.md)
- Concept: [SLSA Build Track](../concepts/slsa-build-track.md)
- Concept: [SLSA Source Track](../concepts/slsa-source-track.md)
- Entity: [OpenSSF](openssf.md)
- Entity: [in-toto](in-toto.md)
