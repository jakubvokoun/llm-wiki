# Software attestations

Status: Approved

A software attestation is an authenticated statement (metadata) about a
software artifact or collection of software artifacts.
The primary intended use case is to feed into automated policy engines, such as
in-toto and Binary Authorization.

## Overview

With raw signing, a signature is directly over the artifact and implies a single bit of metadata. With an attestation, the metadata is **explicit** and the signature only denotes who created the attestation (authenticity). A single keyset can express an arbitrary amount of information.

## Formats

### First party

Organizations using SLSA internally can choose any format for internal use. To make an external claim of meeting a SLSA level, SLSA recommends using the SLSA Provenance format, verifiable using the Generic SLSA Verifier.

### Open source

Use the SLSA Provenance format. This promotes interoperability across the open source ecosystem and enables verification through the Generic SLSA Verifier.

### Closed source, third party

Consider using Verification Summary Attestations (VSAs) to summarize provenance information in a sanitized way that's safe for external consumption without revealing internal details.

## Model and Terminology

Components:

* **Artifact:** Immutable blob of data described by an attestation, usually identified by cryptographic content hash. MAY also include a mutable locator such as a package name or URI.
* **Attestation:** Authenticated, machine-readable metadata about one or more software artifacts. MUST contain at least:
  + **Envelope:** Authenticates the message. Contains the Message (content/statement) and Signature (denotes the attester).
  + **Statement:** Binds the attestation to a particular set of artifacts. Contains the Subject (identifies which artifacts the predicate applies to) and Predicate (metadata about the subject).
  + **Predicate:** Arbitrary metadata in a predicate-specific schema. MAY contain Links to related artifacts.
* **Bundle:** A collection of Attestations.
* **Storage/Lookup:** Convention for where attesters place attestations and how verifiers find attestations for a given artifact.

## Recommended Suite

| Component | Recommendation |
| --- | --- |
| Envelope | DSSE (ECDSA over NIST P-256+ and SHA-256) |
| Statement | in-toto attestations |
| Predicate | Provenance, SPDX, or other appropriate formats |
| Bundle | JSON Lines |
| Storage/Lookup | TBD |
