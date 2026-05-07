# Build: Requirements for producing artifacts

Status: Approved

This page covers the detailed technical requirements for producing artifacts at
each SLSA level. The intended audience is platform implementers and security
engineers.

## Overview

### Build levels

In order to produce artifacts with a specific build level, responsibility is
split between the Producer and Build platform.

| Implementer | Requirement | L1 | L2 | L3 |
|---|---|---|---|---|
| Producer | Choose an appropriate build platform | ✓ | ✓ | ✓ |
| Producer | Follow a consistent build process | ✓ | ✓ | ✓ |
| Producer | Distribute provenance | ✓ | ✓ | ✓ |
| Build platform | Provenance exists | ✓ | ✓ | ✓ |
| Build platform | Provenance authentic | | ✓ | ✓ |
| Build platform | Provenance unforgeable | | | ✓ |
| Build platform | Hosted isolation | ✓ | ✓ | |
| Build platform | Build isolation | | ✓ | ✓ |

### Security Best Practices

All implementations MUST use industry security best practices including proper access controls, securing communications, implementing proper management of cryptographic secrets, doing frequent updates, and promptly fixing known vulnerabilities. Reference: CIS Critical Security Controls.

## Producer

### Choose an appropriate build platform

The producer MUST select a build platform that is capable of reaching their
desired SLSA Build Level.

### Follow a consistent build process

The producer MUST build their artifact in a consistent
manner such that verifiers can form expectations about the build process.

### Distribute provenance

The producer MUST distribute provenance to artifact consumers. The producer
MAY delegate this responsibility to the package ecosystem.

## Build Platform

### Provenance generation

#### Provenance Exists (L1, L2, L3)

Platforms must generate cryptographically-identified provenance describing artifact production. Recommended to use SLSA Provenance format.

At Level 1, completeness is best-effort; provenance should contain sufficient detail to catch errors.

#### Provenance is Authentic (L2, L3)

Consumers must validate provenance authenticity through digital signatures from private keys accessible only to the build platform. Provenance must be generated within the control plane, not by tenants.

Accuracy requirements:
- The data in the provenance MUST be obtained from the build platform.
- The build platform MUST have some security control to prevent tenants from tampering with the provenance.
- Exceptions: tenant may generate artifact digests (`subject`) and non-required fields.

#### Provenance is Unforgeable (L3)

Provenance MUST be strongly resistant to forgery by tenants.
- Secret material for authentication MUST be stored in a secure management system accessible only to the build service account.
- Such secret material MUST NOT be accessible to the environment running user-defined build steps.
- Every field in the provenance MUST be generated or verified by the build platform in a trusted control plane.
- External parameters MUST be fully enumerated.

### Isolation Strength

#### Hosted (L1, L2)

All build steps must execute on hosted platforms using shared or dedicated infrastructure, not on individual workstations. Examples: GitHub Actions, Google Cloud Build, Travis CI.

#### Isolated (L2, L3)

Build platforms must ensure isolated environments free from unintended external influence:
- Builds cannot access platform secrets like provenance signing keys.
- Concurrent builds cannot influence each other's memory or state.
- Subsequent builds cannot inherit previous build environments (ephemeral environments).
- Cache systems prevent poisoning attacks.
- Remote services are captured as external parameters.

Note: This does not mandate hermetic (network-isolated) builds.
