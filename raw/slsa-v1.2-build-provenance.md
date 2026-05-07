# Build: Provenance

Status: Approved

This document defines the following predicate type within the in-toto
attestation framework:

```
"predicateType": "https://slsa.dev/provenance/v1"
```

## Purpose

Describe how an artifact or set of artifacts was produced so that:
* Consumers of the provenance can verify that the artifact was built according to expectations.
* Others can rebuild the artifact, if desired.

## Model

Provenance is an attestation that a particular build platform produced a set of
software artifacts through execution of the `buildDefinition`.

The model is as follows:
* Each build runs as an independent process on a multi-tenant build platform. The `builder.id` identifies this platform.
* The build process is defined by a parameterized template, identified by `buildType`.
* All top-level, independent inputs are captured by the parameters to the template:
  + `externalParameters`: the external interface to the build. Untrusted; MUST be included and verified downstream.
  + `internalParameters`: set internally by the platform. Trusted; OPTIONAL.
* All artifacts fetched during initialization or execution are considered dependencies, captured in `resolvedDependencies`.
* Finally, the build process outputs one or more artifacts, identified by `subject`.

## Schema

```json
{
    "_type": "https://in-toto.io/Statement/v1",
    "subject": [...],
    "predicateType": "https://slsa.dev/provenance/v1",
    "predicate": {
        "buildDefinition": {
            "buildType": string,
            "externalParameters": object,
            "internalParameters": object,
            "resolvedDependencies": [ ...ResourceDescriptor ]
        },
        "runDetails": {
            "builder": {
                "id": string,
                "builderDependencies": [ ...ResourceDescriptor ],
                "version": { ...string }
            },
            "metadata": {
                "invocationId": string,
                "startedOn": Timestamp,
                "finishedOn": Timestamp
            },
            "byproducts": [ ...ResourceDescriptor ]
        }
    }
}
```

### Key fields

**BuildDefinition** (REQUIRED for L1: `buildType`, `externalParameters`):
- `buildType`: Identifies the template for how to perform the build. URI that SHOULD resolve to a human-readable specification.
- `externalParameters`: Parameters that are under external control. MUST be complete at SLSA Build L3.
- `internalParameters`: Parameters under control of the entity represented by `builder.id`. Primary for debugging/incident response.
- `resolvedDependencies`: Unordered collection of artifacts needed at build time. Completeness is best effort through SLSA Build L3.

**RunDetails** (REQUIRED for L1: `builder`):
- `builder.id`: URI indicating the transitive closure of the trusted build platform. Sole determiner of SLSA Build level.
- `builder.version`: Map of names of build platform components to their version.
- `metadata.invocationId`: Identifies this particular build invocation.
- `metadata.startedOn` / `metadata.finishedOn`: Timestamps.
- `byproducts`: Additional artifacts generated during build, not considered the primary output.

## Index of build types

* GitHub Actions Workflow (community-maintained)
* Google Cloud Build (community-maintained)

## Parsing rules

* Consumers MUST ignore unrecognized fields.
* The `predicateType` URI includes the major version number and changes whenever there is a backwards incompatible change.
* Minor version changes are always backwards compatible.
* Unset, null, and empty field values MUST be interpreted equivalently.
