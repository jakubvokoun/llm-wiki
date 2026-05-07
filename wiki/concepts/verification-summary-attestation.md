---
title: "Verification Summary Attestation (VSA)"
tags: [slsa, supply-chain-security, provenance, verification]
sources: [slsa-v1.2-verification-summary.md, slsa-v1.2-verified-properties.md]
updated: 2026-05-07
---

# Verification Summary Attestation (VSA)

A VSA is a signed statement that a trusted **verifier** has evaluated a software artifact against a policy and found it to meet specified SLSA levels.

**Predicate type:** `https://slsa.dev/verification_summary/v1`

## Why VSAs exist

- **Consumers** don't need to evaluate all raw attestations themselves
- **Producers** can share compliance claims without exposing internal build infrastructure
- **Verifiers** (e.g., package registries, third-party auditors) can issue VSAs consumers already trust

## Structure

```json
{
  "verifier": {"id": "<URI>"},
  "timeVerified": "<Timestamp>",
  "resourceUri": "<artifact-URI>",
  "policy": {"uri": "<URI>", "digest": {"sha256": "<hash>"}},
  "inputAttestations": [...],
  "verificationResult": "PASSED",
  "verifiedLevels": ["SLSA_BUILD_LEVEL_3", "SLSA_SOURCE_TWO_PARTY_REVIEWED"],
  "dependencyLevels": {"SLSA_BUILD_LEVEL_3": 42},
  "slsaVersion": "1.2"
}
```

## Key fields

| Field | Role |
| --- | --- |
| `verifier.id` | Who issued the VSA — the trust anchor for consumers |
| `resourceUri` | Identifies the artifact (must match what consumer requested) |
| `policy.uri` | The policy evaluated against |
| `verificationResult` | `PASSED` or `FAILED` |
| `verifiedLevels` | Which SLSA levels were achieved; max one per track |
| `dependencyLevels` | SLSA level distribution across dependencies |

## `verifiedLevels` values

Standard levels: `SLSA_BUILD_LEVEL_1` through `_3`, `SLSA_SOURCE_LEVEL_1` through `_4`

Extended properties:

- `SLSA_SOURCE_TWO_PARTY_REVIEWED` — source reviewed by two trusted persons
- `SLSA_BUILD_REPRODUCED` — artifact reproduced by 2+ independent builders
- Custom values allowed (must not start with `SLSA_`)

## Consumer verification (7 steps)

1. Verify envelope signature using trusted roots
2. Verify `subject` digest matches the artifact
3. Verify `predicateType` is correct
4. Verify `verifier.id` matches public key used in step 1
5. Verify `resourceUri` matches expected artifact URI
6. Verify `verificationResult` is `PASSED`
7. Verify `verifiedLevels` contains the required level

## Use cases

| Use case | Description |
| --- | --- |
| **Package registry** | Registry evaluates provenance at upload; issues VSA; consumers verify VSA |
| **Closed-source vendor** | Vendor proves compliance without exposing build details |
| **Internal policy enforcement** | Internal verifier issues VSAs for all internal artifacts |
| **Third-party audit** | Auditor issues VSAs for certified vendors |

## Security caveat

VSAs do not protect against compromise of the verifier itself (insider threat). Consumers must carefully vet which verifiers they add to their roots of trust.

## Key sources

- [VSA Specification](../sources/slsa-v1.2-verification-summary.md)
- [Verified Properties](../sources/slsa-v1.2-verified-properties.md)
- Related: [SLSA](slsa.md), [SLSA Provenance](slsa-provenance.md), [Software Attestation](software-attestation.md)
