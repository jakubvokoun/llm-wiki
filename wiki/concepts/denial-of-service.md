---
title: "Denial of Service (DoS)"
tags: [dos, availability, resource-exhaustion, security]
sources: [owasp-xml-security.md]
updated: 2026-06-14
---

# Denial of Service (DoS)

An attack on **availability** — making a system unresponsive or unavailable to legitimate users, usually by exhausting a finite resource (CPU, memory, file descriptors, threads, bandwidth, or storage). Distinct from confidentiality/integrity attacks; the goal is disruption.

## Common application-layer vectors

- **Entity/recursion expansion** — XML "Billion Laughs" / quadratic blowup, where recursive entity definitions expand to gigabytes from a tiny payload. See [XXE](xxe.md) and [XML Security](xml-security.md). Defense: disable DTDs, cap entity expansion.
- **[ReDoS](redos.md)** — catastrophic backtracking in a regular expression turns a small input into exponential CPU.
- **Decompression bombs** (zip/gzip), oversized uploads, unbounded pagination/result sets.
- **Algorithmic complexity** — hash-collision flooding, pathological sort/parse inputs.

## Defenses

- **Input limits** — max body/entity/recursion depth, request size caps, timeouts ([input validation](input-validation.md), [file upload security](file-upload-security.md)).
- **Resource quotas & rate limiting** — per-client throttles; bounded thread/connection pools.
- **Graceful degradation** under load — load shedding and [overload protection](overload-protection.md); avoid retry storms that trigger [cascading failures](cascading-failures.md).
- Network-layer scrubbing / CDN for volumetric (L3/L4) floods.

## Related

- [Overload Protection](overload-protection.md)
- [Cascading Failures](cascading-failures.md)
- [ReDoS](redos.md)
- [XXE](xxe.md)
- [Denial of Wallet](denial-of-wallet.md)

## Sources

- [OWASP XML Security Cheat Sheet](../sources/owasp-xml-security.md)
