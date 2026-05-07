---
title: "SLSA v1.2 — Build Provenance Schema"
tags: [slsa, supply-chain-security, provenance, in-toto]
sources: [slsa-v1.2-build-provenance.md]
updated: 2026-05-07
---

# Build Provenance Schema

Reference for the SLSA build provenance attestation format: `predicateType: https://slsa.dev/provenance/v1`.

## Purpose

Describe how an artifact was produced so that:

- Consumers can verify the artifact was built according to expectations
- Others can rebuild the artifact if needed

## Model

A single build runs as an independent process on a multi-tenant build platform. The model:

- `builder.id` identifies the trusted build platform (trust anchor)
- `buildType` identifies the parameterized template used
- External inputs → `externalParameters` (untrusted, must be complete)
- Internal inputs → `internalParameters` (trusted, platform-controlled)
- Fetched artifacts → `resolvedDependencies`
- Output → `subject` (the produced artifacts)

## Schema

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [...],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "<URI>",
      "externalParameters": {},
      "internalParameters": {},
      "resolvedDependencies": [...]
    },
    "runDetails": {
      "builder": {
        "id": "<URI>",
        "builderDependencies": [...],
        "version": {}
      },
      "metadata": {
        "invocationId": "<string>",
        "startedOn": "<Timestamp>",
        "finishedOn": "<Timestamp>"
      },
      "byproducts": [...]
    }
  }
}
```

## Field reference

### buildDefinition (required)

| Field | Required | Description |
| --- | --- | --- |
| `buildType` | L1 | URI identifying the build template. SHOULD resolve to human-readable spec |
| `externalParameters` | L1 | All external inputs. MUST be complete at L3 |
| `internalParameters` | optional | Platform-controlled inputs (debugging, not verified by consumers) |
| `resolvedDependencies` | optional | Artifacts needed at build time (best-effort through L3) |

### runDetails (required)

| Field | Required | Description |
| --- | --- | --- |
| `builder.id` | L1 | URI identifying the build platform — the trust anchor |
| `builder.version` | optional | Component versions of build platform |
| `metadata.invocationId` | optional | Unique identifier for this build |
| `metadata.startedOn` | optional | Build start timestamp |
| `metadata.finishedOn` | optional | Build end timestamp |
| `byproducts` | optional | Additional build artifacts (logs, test results) |

## Parsing rules

- Consumers MUST ignore unrecognized fields (forwards compatibility)
- The URI includes the major version number
- Minor version changes are backwards compatible
- Unset, null, and empty values MUST be treated equivalently

## Index of build types

- GitHub Actions Workflow (community-maintained)
- Google Cloud Build (community-maintained)

## Related pages

- [Build Requirements](slsa-v1.2-build-requirements.md) — which fields are required at which level
- [Attestation Model](slsa-v1.2-attestation-model.md) — the outer envelope/statement structure
- Concept: [SLSA Provenance](../concepts/slsa-provenance.md)
