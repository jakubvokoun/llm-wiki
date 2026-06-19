---
title: "SLSA Provenance"
tags: [slsa, supply-chain-security, provenance, in-toto]
sources:
  [
    slsa-v1.2-provenance.md,
    slsa-v1.2-build-provenance.md,
    slsa-v1.2-distributing-provenance.md,
  ]
updated: 2026-05-07
---

# SLSA Provenance

SLSA provenance is a signed, machine-readable attestation describing how a software artifact was produced — where, when, and by what process.

## Types

| Type              | predicateType                    | Trust anchor                  |
| ----------------- | -------------------------------- | ----------------------------- |
| Build provenance  | `https://slsa.dev/provenance/v1` | Build platform (`builder.id`) |
| Source provenance | (SCS-specific)                   | Source Control System         |

## Build provenance structure

Build provenance is an in-toto statement with SLSA predicate, wrapped in a DSSE envelope:

```
DSSE envelope
└── in-toto statement
    ├── subject: [{name, digest}]   ← the produced artifacts
    ├── predicateType: https://slsa.dev/provenance/v1
    └── predicate
        ├── buildDefinition
        │   ├── buildType           ← identifies the build template
        │   ├── externalParameters  ← ALL external inputs (required complete at L3)
        │   ├── internalParameters  ← platform-controlled inputs
        │   └── resolvedDependencies ← artifacts fetched during build
        └── runDetails
            ├── builder.id          ← trust anchor URI
            ├── builder.version
            ├── metadata (invocationId, startedOn, finishedOn)
            └── byproducts
```

## Key fields explained

**`buildType`** — URI identifying the build template (e.g., `https://slsa.dev/github-actions-workflow/v1`). Tells consumers how to interpret the other fields.

**`externalParameters`** — All inputs under caller control. This is where injection attacks would appear. Must be complete at L3; consumers verify these against expectations.

**`builder.id`** — The trust anchor. Consumers check this against their configured trusted builders.

**`resolvedDependencies`** — The actual versions of dependencies fetched during build (addresses reproducibility and dependency pinning).

## Verification

Consumers verify build provenance by:

1. Verifying DSSE signature (using trusted builder's public key)
2. Checking `subject` digest matches the artifact
3. Verifying `predicateType` is the expected value
4. Checking all fields against expectations (source, builder, parameters)

## Distribution

Provenance is distributed as a bundle alongside the artifact:

- OCI registries: via OCI referrers API
- Package registries: as sidecar files
- Transparency logs: Rekor/Sigstore for public accountability

## Relationship to VSAs

A [VSA](verification-summary-attestation.md) is a derivative: a verifier evaluates provenance and issues a summary. Consumers verify the VSA instead of raw provenance — useful for hiding internal details or simplifying consumer tooling.

## Key sources

- [Build Provenance Schema](../sources/slsa-v1.2-build-provenance.md) — full field reference
- [Provenance Overview](../sources/slsa-v1.2-provenance.md)
- [Distributing Provenance](../sources/slsa-v1.2-distributing-provenance.md)
- Related: [SLSA](slsa.md), [Software Attestation](software-attestation.md)
