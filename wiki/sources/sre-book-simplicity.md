---
title: "SRE Book — Chapter 9: Simplicity"
tags: [sre, simplicity, software-engineering, reliability, google]
sources: [sre-book-simplicity.md]
updated: 2026-04-24
---

# SRE Book — Chapter 9: Simplicity

Written by Max Luebbe, edited by Tim Harvey. Closing chapter of Part II (Principles).

> The price of reliability is the pursuit of the utmost simplicity.
>
> C.A.R. Hoare

## Core Thesis

Software simplicity is a **prerequisite to reliability**. The SRE job is to keep agility and stability in balance. Reliability requires boring, predictable systems.

## Essential vs Accidental Complexity

From Fred Brooks' "No Silver Bullet":

- **Essential complexity**: Inherent in the problem definition; cannot be removed.
- **Accidental complexity**: Fluid; can be resolved with engineering effort.

SRE teams should push back on accidental complexity and constantly strive to eliminate it from systems they operate.

## Key Principles

### Boring is Good

"Surprises in production are the nemeses of SRE." Code should behave predictably; any interesting behavior at runtime is a defect.

### Every Line of Code is a Liability

- Dead code should be **deleted**, not commented out, not flag-gated.
- Knight Capital example: flag-gated dead code was a literal time bomb.
- Source control makes deletion safe — reverting is easy.
- SRE promotes: bloat detection in testing, scrutinizing code against business goals, routinely removing dead code.

### Minimal APIs

> Perfection is finally attained not when there is no longer more to add, but when there is no longer anything to take away.
>
> Antoine de Saint Exupery

Fewer methods + fewer arguments → easier API → more effort focused on quality. A small, simple API is a hallmark of a well-understood problem.

### Modularity

- Loose coupling between binaries promotes both developer agility and system stability
- API versioning allows gradual migration — different parts of a system can release independently
- Avoid "util" or "misc" binaries — every component should have a clear, well-scoped purpose
- Protocol buffers: backward and forward compatible wire format as an example of modular data design

### Release Simplicity

Small, independent batches > large simultaneous releases:

- Easier to understand the impact of a single change
- Faster to find and fix regressions
- Analogous to gradient descent: small steps, assess improvement at each step

## Related Pages

- [Software Simplicity](../concepts/software-simplicity.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Release Engineering](../concepts/release-engineering.md)
- [SRE Book Introduction](sre-book-introduction.md)
