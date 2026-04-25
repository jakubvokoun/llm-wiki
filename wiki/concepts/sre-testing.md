---
title: "SRE Testing for Reliability"
tags: [sre, testing, mttr, canary, production-testing, reliability]
sources: [sre-testing-reliability.md]
updated: 2026-04-24
---

# SRE Testing for Reliability

SREs quantify confidence in systems by adapting software testing to systems at scale. Testing demonstrates equivalence across changes — each passing test reduces uncertainty about whether a change degrades reliability.

## Testing and MTTR

- **Zero MTTR bugs:** System-level tests that catch bugs pre-production. The push is blocked; the bug never ships.
- More zero-MTTR bugs → higher MTBF for users.
- Better testing → higher release velocity → more bugs discovered → more testing investment — a virtuous cycle.

## Test Types

### Traditional (Offline)

| Type                 | Scope                    | Key Use                                |
| -------------------- | ------------------------ | -------------------------------------- |
| Unit                 | Function/class           | TDD, specification                     |
| Integration          | Assembled components     | Dependency injection, mock replacement |
| System (smoke)       | End-to-end, simple       | Sanity gate before expensive tests     |
| System (performance) | End-to-end, load         | Prevent latency/memory regression      |
| System (regression)  | Historical bugs as tests | Prevent re-introduction                |

### Production (Black-Box)

**Configuration test:** Compares live production config to version-controlled file. Non-hermetic. Reveals lag between engineering work and production state.

**Stress test:** Finds capacity limits (max DB writes before failure, max QPS before overload).

**Canary test:** Staged rollout to a subset of servers. Not a true test — structured user acceptance. Uses exponential rollout (0.1% → 1% → 10% → 100%).

**Canary fault order classification:**

- U=1: Scales linearly with traffic (most bugs). Regression test via failure logs.
- U=2: Randomly corrupts data a future user may see.
- U=3: Corrupted data is a valid reference to a prior request. Hardest to detect.

## Build and Test Infrastructure

- Continuous build system that triggers on every commit
- Immediate notification when build/tests break
- Engineers must fix breaks before all other work — compounding cascading cost otherwise
- Tools like Bazel build only changed code's dependency graph (faster, reproducible)

**Critical rule:** Latest version in source control must always be working.

## Testing at Scale

### SRE Tool Testing

SRE automation tools require extra care because they operate outside the mainstream API. Pattern:

1. Place barrier to mark replica unhealthy (can't serve users)
2. Risky tool only runs against unhealthy replicas
3. Standard health check tool removes barrier

### Disaster Recovery Testing

Design offline tools around three primitives:

- **Checkpoint:** equivalent to clean service stop
- **Loadable:** checkpoint can be validated by nondisaster tools
- **Clean start:** release barrier trigger

Online repair tools (operating outside mainstream API) are harder — they may race with eventual consistency. Statistical tools (Jepsen, Chaos Monkey) are non-repeatable but useful for finding edge cases.

### Configuration File Risk

Two categories:

1. **MTTR-critical files** (changed only during incidents): slow release cadence OK
2. **State files** (changed more than once per app release): must have better test coverage than the application itself

Break-glass mechanism: push live before tests complete, but make it noisy (file bug, boost test priority).

## Production Probes

Replaying known-good requests as monitoring probes catches configurations that release tests didn't — because frontends and backends have independent release cycles.

The production updater creates four running combinations (old/new app × old/new probe) and rolls back on any failure.

## See Also

- [Continuous Integration](continuous-integration.md)
- [Incident Response](incident-response.md)
- [Postmortem Culture](postmortem-culture.md)
- [Service Reliability Hierarchy](service-reliability-hierarchy.md)
