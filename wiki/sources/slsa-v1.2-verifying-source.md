---
title: "SLSA v1.2 — Verifying Source"
tags: [slsa, supply-chain-security, source-control, verification]
sources: [slsa-v1.2-verifying-source.md]
updated: 2026-05-07
---

# Verifying Source

How consumers verify that source code meets SLSA Source Track requirements.

## 3-step verification process

### Step 1: Check the SCS

Evaluate whether the Source Control System (SCS) satisfies the required Source Track level:

- Does the SCS have documented and enforced controls?
- Which controls match which SLSA source levels?
- Has a trusted verifier already evaluated the SCS and issued a [Source VSA](slsa-v1.2-source-requirements.md)?

This step is typically done once per SCS, not per revision.

### Step 2: Check expectations

Verify that the source revision comes from the expected location and through the expected process:

| Expectation | What to check                                            |
| ----------- | -------------------------------------------------------- |
| Repository  | Source comes from the canonical repository               |
| Branch      | Revision is reachable from the expected protected branch |
| Review      | Change followed the expected review process              |
| Identity    | Reviewers are the expected individuals/roles (optional)  |

Expectations should be defined before verification and stored in a policy configuration.

### Step 3: Verify source provenance

Verify the source provenance attestation from the SCS:

1. Retrieve source provenance for the revision
2. Verify signature using preconfigured roots of trust for the SCS
3. Confirm the revision digest matches the source you received
4. Confirm provenance fields match expectations (repository, branch, review status)

## Architecture options

| Architecture | Description |
| --- | --- |
| **Package ecosystem** | Registry verifies source provenance at upload time; consumers trust the registry |
| **Consumer** | Consumer's pipeline verifies source provenance before building from source |
| **Build platform** | Build platform verifies source provenance before pulling source for a build |
| **Monitor** | Retrospective monitoring for policy violations |

## Relationship to Build Track

Source verification complements Build Track verification:

- Build Track: artifact was built from a specific source revision on a trusted platform
- Source Track: that source revision was created through an appropriate process

Combining both gives end-to-end supply chain integrity from source commit to deployed binary.

## Related pages

- [Source Requirements](slsa-v1.2-source-requirements.md) — what SCS and organizations must provide
- [Verifying Artifacts](slsa-v1.2-verifying-artifacts.md) — analogous process for Build Track
- Concept: [SLSA Source Track](../concepts/slsa-source-track.md)
