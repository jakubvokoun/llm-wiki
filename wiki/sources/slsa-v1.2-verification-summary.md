---
title: "SLSA v1.2 — Verification Summary Attestation (VSA)"
tags: [slsa, supply-chain-security, provenance, verification]
sources: [slsa-v1.2-verification-summary.md]
updated: 2026-05-07
---

# Verification Summary Attestation (VSA)

An attestation that a trusted entity has evaluated an artifact against a policy and found it meets a certain SLSA level.

**Predicate type:** `https://slsa.dev/verification_summary/v1`

## Purpose

VSAs allow:

- **Consumers** to make trust decisions without evaluating all attestations themselves
- **Producers** to keep internal build details confidential while communicating compliance externally

## Schema

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [{ "name": "<NAME>", "digest": { "<alg>": "<hash>" } }],
  "predicateType": "https://slsa.dev/verification_summary/v1",
  "predicate": {
    "verifier": {
      "id": "<URI>",
      "version": { "<component>": "<version>" }
    },
    "timeVerified": "<Timestamp>",
    "resourceUri": "<artifact-URI>",
    "policy": {
      "uri": "<URI>",
      "digest": { "<alg>": "<hash>" }
    },
    "inputAttestations": [{ "uri": "<URI>", "digest": { "<alg>": "<hash>" } }],
    "verificationResult": "PASSED",
    "verifiedLevels": ["SLSA_BUILD_LEVEL_3"],
    "dependencyLevels": { "SLSA_BUILD_LEVEL_3": 42 },
    "slsaVersion": "1.2"
  }
}
```

## Field reference

| Field                | Required    | Description                                           |
| -------------------- | ----------- | ----------------------------------------------------- |
| `verifier.id`        | required    | URI identifying the verifier                          |
| `verifier.version`   | optional    | Platform component versions                           |
| `timeVerified`       | optional    | When verification occurred                            |
| `resourceUri`        | required    | URI identifying the artifact being verified           |
| `policy.uri`         | required    | Policy the artifact was verified against              |
| `policy.digest`      | recommended | Hash of the policy document                           |
| `inputAttestations`  | optional    | ALL attestations used — if non-empty must be complete |
| `verificationResult` | required    | `"PASSED"` or `"FAILED"`                              |
| `verifiedLevels`     | required    | Highest level per track. Max one per track            |
| `dependencyLevels`   | optional    | Count of dependencies at each SLSA level              |
| `slsaVersion`        | optional    | `"1.2"`                                               |

## How to verify a VSA

1. Verify signature on VSA envelope using roots of trust
2. Verify `subject` digest matches the artifact
3. Verify `predicateType` is `https://slsa.dev/verification_summary/v1`
4. Verify `verifier` matches the public key used in step 1
5. Verify `resourceUri` matches expected artifact URI
6. Verify `verificationResult` is `"PASSED"`
7. Verify `verifiedLevels` contains the required level

## SlsaResult values

Standard values for `verifiedLevels` and `dependencyLevels`:

- `SLSA_BUILD_LEVEL_UNEVALUATED`
- `SLSA_BUILD_LEVEL_0` through `SLSA_BUILD_LEVEL_3`
- `SLSA_SOURCE_LEVEL_0` through `SLSA_SOURCE_LEVEL_4`
- `FAILED`
- Custom values allowed (must not start with `SLSA_`)

Each level implies all lower levels in the same track.

## Security warning

A VSA does not protect against compromise of the verifier itself (malicious insider). VSA consumers SHOULD carefully consider which verifiers they add to roots of trust.

## Related pages

- [Verified Properties](slsa-v1.2-verified-properties.md) — additional properties that can appear in verifiedLevels
- [Attestation Model](slsa-v1.2-attestation-model.md) — general attestation structure
- Concept: [Verification Summary Attestation](../concepts/verification-summary-attestation.md)
