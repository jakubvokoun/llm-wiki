---
title: "SLSA v1.2 — About SLSA"
tags: [slsa, supply-chain-security, provenance]
sources: [slsa-v1.2-about.md]
updated: 2026-05-07
---

# About SLSA

SLSA ("salsa") — Supply-chain Levels for Software Artifacts — is an industry-consensus framework for incrementally improving software supply chain security. It serves both **producers** (follow guidelines to harden your supply chain) and **consumers** (evaluate trustworthiness of artifacts you depend on).

## What SLSA offers

- Common vocabulary for supply chain security discussions
- Actionable checklist for producers to improve security
- A way to evaluate incoming supply chain trustworthiness
- Measurable progress toward SSDF (Secure Software Development Framework) compliance

## Why it exists

High-profile attacks (SolarWinds, Codecov) exposed supply chain weaknesses: even well-reviewed code can be tampered with at any of multiple points between source and binary. The U.S. Executive Order on Cybersecurity (May 2021) affirmed the need for a universal framework. SLSA supports automation to track code from source to binary, protecting against tampering regardless of pipeline complexity.

## Analogy: food safety

SBOMs are "ingredient labels" for software. SLSA is "food safety handling guidelines" that make ingredient labels credible — tamper-proof seals, clean factory environments, etc. SLSA provides tamper-resistant evidence for every step of software production.

## Audience

- **Software producers** — open source projects, vendors, first-party teams: protection against tampering along the supply chain
- **Software consumers** — dev teams, government agencies, CISOs: a way to judge security practices of software you rely on
- **Infrastructure providers** — package managers, build platforms, CI/CD: your adoption enables secure supply chain between producers and consumers

## How SLSA works

SLSA is organized into **tracks** (aspects of supply chain) and **levels** (increasingly hardened security practices within each track). Higher levels = better guarantees = higher implementation cost. Currently: Build Track (L1-L3) and Source Track (L1-L4).

## What SLSA does NOT cover

- Code quality or secure coding practices
- Intentionally malicious producers (but reduces insider risk)
- Transitive dependency trust (SLSA level of artifact ≠ SLSA level of its dependencies — though SLSA can be applied recursively)

## Key links

- Concept: [SLSA](../concepts/slsa.md)
- Build Track overview: [SLSA Build Track Basics](slsa-v1.2-build-track-basics.md)
- Source Track overview: [SLSA Source Requirements](slsa-v1.2-source-requirements.md)
