---
title: "SLSA v1.2 — Verifying Artifacts"
tags: [slsa, supply-chain-security, provenance, verification]
sources: [slsa-v1.2-verifying-artifacts.md]
updated: 2026-05-07
---

# Verifying Artifacts

How consumers verify that an artifact meets SLSA requirements.

## 3-step verification process

### Step 1: Check the artifact's SLSA level

1. Retrieve the provenance for the artifact
2. Verify the provenance signature using preconfigured roots of trust (the set of trusted build platforms)
3. Determine the SLSA level: which requirements does the build platform's `builder.id` satisfy?
4. Check that the level meets the required minimum

Alternatively: verify a [VSA](slsa-v1.2-verification-summary.md) from a trusted verifier instead of raw provenance.

### Step 2: Check the artifact against expectations

Verify provenance fields match known-good values for this package:

| Field                | What to check                                     |
| -------------------- | ------------------------------------------------- |
| `subject` digest     | Matches the artifact you downloaded               |
| Source location      | Expected repository (e.g., `github.com/org/repo`) |
| `builder.id`         | Expected build platform                           |
| Branch/tag           | Expected branch (e.g., `main`, `release/1.2`)     |
| Build config         | Expected workflow or build steps                  |
| `externalParameters` | No unexpected parameters injected                 |

**Expectations must be defined before verification.** They can be stored in a policy file, package registry metadata, or a verifier configuration.

### Step 3 (optional): Check dependencies recursively

Apply SLSA verification recursively to the artifact's build-time dependencies listed in `resolvedDependencies`. This addresses dependency threats.

This step is optional in SLSA v1.2 but is expected to become required in future versions.

## Architecture options

| Architecture          | Who verifies                                            | Notes                                                        |
| --------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| **Package ecosystem** | Registry/package manager enforces at upload or download | Most scalable; shifts burden to ecosystem infrastructure     |
| **Consumer**          | Consumer's pipeline verifies before use                 | Gives consumer full control; requires tooling                |
| **Monitor**           | Third-party continuously audits published artifacts     | Retrospective; can alert on policy violations after the fact |

## Tools

- `slsa-verifier` — reference implementation for verifying SLSA provenance
- `cosign verify-attestation` — Sigstore-based verification
- Binary Authorization (GCP) — policy enforcement at deploy time

## Relationship to VSAs

[Verification Summary Attestations](slsa-v1.2-verification-summary.md) allow consumers to skip raw provenance verification by trusting a verifier who has already done it. Useful when:

- Consumers lack the tooling to verify complex provenance
- Producers want to hide internal build details

## Related pages

- [Build Track Basics](slsa-v1.2-build-track-basics.md) — what the levels mean
- [Verifying Source](slsa-v1.2-verifying-source.md) — analogous process for the Source Track
- Concept: [SLSA Build Track](../concepts/slsa-build-track.md)
