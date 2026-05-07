# Verification Summary Attestation (VSA)

Status: Approved

This document defines the following predicate type within the in-toto attestation framework:

```
"predicateType": "https://slsa.dev/verification_summary/v1"
```

## Purpose

Describe what SLSA level an artifact or set of artifacts was verified at and other details about the verification process including what SLSA level the dependencies were verified at.

VSAs allow software consumers to make a decision about the validity of an artifact without needing to have access to all of the attestations about the artifact or all of its transitive dependencies. They allow software producers to keep the details of their build pipeline confidential while still communicating that some verification has taken place.

## Model

A VSA is an attestation that some entity (`verifier`) verified one or more software artifacts by evaluating the artifact and a `bundle` of attestations against some `policy`. Users who trust the `verifier` may assume that the artifacts met the indicated SLSA level without themselves needing to evaluate the artifact.

## Schema

```json
{
    "_type": "https://in-toto.io/Statement/v1",
    "subject": [{
        "name": "<NAME>",
        "digest": { "<digest-in-request>" }
    }],
    "predicateType": "https://slsa.dev/verification_summary/v1",
    "predicate": {
        "verifier": {
            "id": "<URI>",
            "version": { "<COMPONENT>": "<VERSION>" }
        },
        "timeVerified": "<TIMESTAMP>",
        "resourceUri": "<artifact-URI-in-request>",
        "policy": {
            "uri": "<URI>",
            "digest": { "<digest-of-policy-data>" }
        },
        "inputAttestations": [
            { "uri": "<URI>", "digest": { "<digest-of-attestation-data>" } }
        ],
        "verificationResult": "<PASSED|FAILED>",
        "verifiedLevels": ["<SlsaResult>"],
        "dependencyLevels": {
            "<SlsaResult>": "<Int>"
        },
        "slsaVersion": "<MAJOR>.<MINOR>"
    }
}
```

### Fields

- `verifier.id` (required): URI indicating the verifier's identity.
- `verifier.version` (optional): Map of verification platform component names to their version.
- `timeVerified` (optional): Timestamp indicating when verification occurred.
- `resourceUri` (required): URI that identifies the resource associated with the artifact being verified.
- `policy` (required): Describes the policy the subject was verified against. MUST contain `uri`, SHOULD contain `digest`.
- `inputAttestations` (optional): Collection of attestations used to perform verification. If non-empty, MUST contain information on ALL attestations used.
- `verificationResult` (required): Either "PASSED" or "FAILED".
- `verifiedLevels` (required): Highest level of each track verified for the artifact. Users MUST NOT include more than one level per SLSA track.
- `dependencyLevels` (optional): Count of dependencies at each SLSA level. Map from SlsaResult to number of transitive dependencies verified at that level.
- `slsaVersion` (optional): Version of the SLSA specification used, in the form `<MAJOR>.<MINOR>`.

## How to verify

Verification MUST include:
1. Verify the signature on the VSA envelope using preconfigured roots of trust.
2. Verify the statement's `subject` matches the digest of the artifact.
3. Verify that the `predicateType` is `https://slsa.dev/verification_summary/v1`.
4. Verify that the `verifier` matches the public key used in step 1.
5. Verify that the value for `resourceUri` matches the expected value.
6. Verify that `verificationResult` is "PASSED".
7. Verify that `verifiedLevels` contains the expected value.

**IMPORTANT:** A VSA does not protect against compromise of the verifier, such as by a malicious insider. VSA consumers SHOULD carefully consider which verifiers they add to their roots of trust.

## SlsaResult values

Examples:
- `SLSA_BUILD_LEVEL_UNEVALUATED`
- `SLSA_BUILD_LEVEL_0` through `SLSA_BUILD_LEVEL_3`
- `SLSA_SOURCE_LEVEL_0` through `SLSA_SOURCE_LEVEL_4`
- `FAILED`

Note that each SLSA level implies all levels below it in the same track (e.g. `SLSA_BUILD_LEVEL_3` means L1 + L2 + L3).

Users MAY use custom values but MUST NOT use custom values starting with `SLSA_`.
