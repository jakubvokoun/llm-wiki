---
title: "SLSA v1.2 — Use Cases"
tags: [slsa, supply-chain-security]
sources: [slsa-v1.2-use-cases.md]
updated: 2026-05-07
---

# SLSA Use Cases

Three main use cases for applying SLSA:

## 1. First party

**Goal:** Reduce risk within an organization from insiders and compromised accounts.

Easiest to apply — no cross-organizational trust transfer needed.

Examples:

- Small company: ensure binaries deployed to production match source reviewed and tested
- Large company: enforce two-person review for every production change, scalably across thousands of employees
- Open source project: ensure compromised credentials cannot release unofficial packages

**Case study:** Google Binary Authorization for Borg

## 2. Open source

**Goal:** Reduce risk from consuming open source software.

Map built packages back to canonical sources and dependencies. Consumers trust a small number of secure build platforms rather than thousands of individual developers.

Examples:

- Upload-time: registry rejects packages not built from canonical source
- Download-time: packaging client rejects packages not built by trusted builder

**Case study:** SUSE (using SLSA for RPM build provenance)

## 3. Vendors

**Goal:** Reduce risk from consuming vendor-provided software and services.

No canonical source to map to — focus is on trustworthiness of vendor claims. Vendors can use [VSAs](../concepts/verification-summary-attestation.md) to share compliance claims without exposing internal build details.

Examples:

- Prefer vendors who make SLSA claims backed by credible evidence
- Require SLSA compliance in vendor contracts
- Require SLSA certification by trusted third-party auditor

## Key insight

The "trust perimeter" shrinks significantly with SLSA:

- Without SLSA: must trust every developer with upload permissions across all packages consumed
- With SLSA: need only trust the small number of audited, SLSA-compliant build platforms

## Related pages

- Concept: [SLSA](../concepts/slsa.md)
- [Verification Summary Attestation](slsa-v1.2-verification-summary.md) — mechanism vendors use to share compliance claims
