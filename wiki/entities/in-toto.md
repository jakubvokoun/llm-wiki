---
title: "in-toto"
tags: [in-toto, supply-chain-security, provenance, attestation]
sources: [slsa-v1.2-attestation-model.md, slsa-v1.2-build-provenance.md]
type: project
updated: 2026-05-07
---

# in-toto

**in-toto** is an open-source framework for securing software supply chains through cryptographically verifiable attestations about each step in a software's creation and distribution process.

## Overview

- **Type:** Open specification + reference implementation
- **Organization:** in-toto project (academic origin: NYU Tandon School of Engineering / Ludivig Maximilian University)
- **CNCF status:** CNCF graduated project
- **Website:** https://in-toto.io/
- **Repo:** https://github.com/in-toto

## Role in SLSA

SLSA builds on in-toto's attestation framework. Specifically:

- SLSA uses the in-toto **Statement** format as the outer wrapper for all attestations
- SLSA Provenance and VSA are both in-toto predicates (specific payload types)
- The in-toto `_type` field (`https://in-toto.io/Statement/v1`) appears in all SLSA attestations

## Key concepts from in-toto

| Concept         | Description                                                   |
| --------------- | ------------------------------------------------------------- |
| **Step**        | A stage in the software supply chain                          |
| **Link**        | Metadata about a completed step (inputs, outputs, who ran it) |
| **Layout**      | Policy defining required steps and authorized functionaries   |
| **Attestation** | Authenticated metadata about an artifact or supply chain step |
| **Predicate**   | The payload of an attestation — what is being claimed         |

## in-toto Attestation Framework (ITE-6)

The attestation framework (ITE-6) defines a generic Statement format:

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [{ "name": "<name>", "digest": { "sha256": "<hash>" } }],
  "predicateType": "<URI>",
  "predicate": {}
}
```

SLSA, SPDX, CycloneDX, and other frameworks define specific `predicateType` URIs and `predicate` schemas on top of this.

## Related pages

- Concept: [Software Attestation](../concepts/software-attestation.md)
- Concept: [SLSA Provenance](../concepts/slsa-provenance.md)
- Entity: [SLSA](slsa.md)
