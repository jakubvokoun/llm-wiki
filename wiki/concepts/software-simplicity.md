---
title: "Software Simplicity"
tags: [sre, simplicity, software-engineering, reliability, complexity]
sources: [sre-book-simplicity.md]
updated: 2026-04-24
---

# Software Simplicity

SRE principle: **software simplicity is a prerequisite to reliability**. Boring, predictable systems are more reliable than clever, complex ones. Every engineering decision that adds complexity is also adding potential failure modes.

## Essential vs Accidental Complexity

From Fred Brooks' "No Silver Bullet":

| Type           | Definition                                                     | Can be Eliminated?            |
| -------------- | -------------------------------------------------------------- | ----------------------------- |
| **Essential**  | Inherent in the problem definition itself                      | No                            |
| **Accidental** | Introduced by implementation choices (e.g., GC pauses in Java) | Yes — with engineering effort |

SRE teams should push back on accidental complexity and strive to eliminate it from systems they operate.

## Dead Code

Dead code must be **deleted**:

- Commented-out code: creates confusion as the file evolves
- Flag-gated disabled code: a time bomb (Knight Capital example: flag-gated dead code was accidentally re-enabled, causing a $440M loss in 45 minutes)
- Source control makes deletion reversible — reverting is easier than understanding a code path that should be dead

SRE practices to prevent bloat:

- Scrutinize code against actual business goals
- Routinely remove dead code
- Build bloat detection into testing

## Minimal APIs

> Perfection is finally attained not when there is no longer more to add, but when there is no longer anything to take away.
>
> Antoine de Saint Exupery

Fewer methods + fewer arguments = more understandable API + more focused quality effort. A small, simple API is a hallmark of a well-understood problem.

Saying "no" to features keeps focus on innovation rather than maintenance of accidental complexity.

## Modularity

Loose coupling enables:

- Independent deployment of components
- Isolated bug fixes (fix one binary, deploy without touching the rest)
- API versioning for safe, gradual migration

Avoid "util" or "misc" binaries. Every component in a well-designed distributed system should have a clear, well-scoped purpose. The same principle applies to data formats: protocol buffers are backward/forward compatible by design.

## Release Simplicity

Small, single-change releases over large batches:

- Easier to measure impact of each change
- Faster to isolate regressions
- Analogous to gradient descent: small steps + assess improvement/degradation at each step

## Relationship to Reliability

Complexity and reliability are inversely related:

- Every new line of code creates potential for new defects
- Smaller projects are easier to understand and test, and have fewer defects
- SRE's experience: reliable processes increase developer agility, not reduce it (fast, reliable rollouts make bugs easier to find)

## Related Pages

- [Site Reliability Engineering](site-reliability-engineering.md)
- [Release Engineering](release-engineering.md)
- [Defense-in-Depth](defense-in-depth.md)
- [SRE Book Simplicity](../sources/sre-book-simplicity.md)
