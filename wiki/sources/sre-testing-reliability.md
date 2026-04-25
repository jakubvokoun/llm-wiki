---
title: "SRE Book — Chapter 17: Testing for Reliability"
tags: [sre, testing, reliability, mttr, production-testing]
sources: [sre-testing-reliability.md]
updated: 2026-04-24
---

# SRE Book — Chapter 17: Testing for Reliability

Written by Alex Perry and Max Luebbe.

> If you haven't tried it, assume it's broken.

## Core Idea

SREs quantify confidence in systems by adapting software testing techniques to systems at scale. Confidence has two dimensions:

- **Past reliability:** historical monitoring data
- **Future reliability:** predictions from past behavior

Testing demonstrates equivalence across changes. More test coverage → less uncertainty per change → higher sustainable change velocity.

## Testing and MTTR

- A system-level test that catches bugs before production achieves **zero MTTR** — the push is blocked so the bug never ships.
- More zero-MTTR bugs → higher MTBF for users.
- As MTBF improves from better testing, developers can release faster, which introduces new bugs, which need more testing — a virtuous cycle.

## Types of Software Testing

### Traditional Tests

| Type        | Scope                 | Cost | Notes                                     |
| ----------- | --------------------- | ---- | ----------------------------------------- |
| Unit        | Single function/class | Low  | Milliseconds; test-driven development     |
| Integration | Assembled components  | Med  | Dependency injection; lightweight mocks   |
| System      | End-to-end undeployed | High | Smoke / performance / regression variants |

**Smoke tests** — simple critical behavior; short-circuit expensive tests.

**Performance tests** — prevent gradual degradation (latency creep, memory growth).

**Regression tests** — document historical bugs; ensure they don't return.

### Production Tests (Black-Box)

**Configuration test:** Examines live production to detect discrepancies between running config and the version-controlled config file. Non-hermetic by design.

**Stress test:** Finds system limits — max DB writes before failure, max QPS before overload. Essential for capacity planning.

**Canary test:** Subset of servers upgraded; observed during incubation period. Not a true test — structured user acceptance. Exposes code to unpredictable live traffic. Uses exponential rollout (0.1% → 1% → 10% → 100%).

**Canary fault orders:**

- U=1: Linear with traffic (most bugs). Fix: convert failure logs to regression tests.
- U=2: Random data damage a future user may encounter.
- U=3: Randomly damaged data is valid reference to prior request.

## Creating a Test Environment

Start where impact is highest:

1. Identify mission-critical or revenue-critical code (billing, auth APIs).
2. Convert every reported bug into a test case (test-first-fail → fix → pass).
3. Set up a continuous build system that notifies on failures immediately.

**Key rule:** The latest version in source control must always be working. Broken code must be fixed before anything else — it causes compounding cascading cost.

Stability drives agility: when builds are predictably solid, developers iterate faster.

## Testing at Scale

### Testing SRE Tools

SRE tools (DB metrics, capacity prediction, file changes) share characteristics:

- Side effects remain within mainstream API
- Isolated from user-facing production by validation/release barrier

Automation tools (load balancing, container shuffling) require even more care — their side effects are invisible discontinuities to another API client.

**Barrier defense pattern:**

1. Mark replica unhealthy so it can't serve users.
2. Configure risky tool to only run against unhealthy replicas.
3. Remove barrier with the same health-checking tool used for monitoring.

### Disaster Recovery Testing

Design offline repair tools around checkpoints:

- Compute checkpoint state = clean service stop
- Push checkpoint to be loadable by nondisaster validation tools
- Support release barrier → clean start procedure

Online repair tools are harder: they operate outside mainstream API and may race with eventual consistency.

### Statistical Testing

Fuzzing (Lemon), chaos tools (Chaos Monkey, Jepsen) are not deterministic tests. They:

- Log random seeds for reproducibility
- Help pinpoint suspicious areas even when not repeatable
- Sometimes reveal more severe failure modes than the original run

### Test Speed and Feedback

For 21,000 tests, to keep false-rejection rate below 1% per 100 patches, each individual test must pass correctly > 99.9999% of the time.

**Interactive tests** (seconds): Give feedback before context switch.

**Batch tests** (minutes): "Not ready for review" signal to code reviewer.

## Configuration Files and Production Risk

Two-category rule for configuration files:

1. Files that change only during incidents (MTTR-critical) — one set of release semantics.
2. Files that change more than once per app release (state files) — must have better test coverage than the application.

**Break-glass mechanism:** Push config live before testing completes. Should be noisy (file a bug), boost test priority, not skip tests entirely.

## Production Probes

Replaying known-good requests as monitoring probes provides a configuration that release tests didn't test — because frontends and backends have independent release cycles.

The production updater gradually replaces both the application and the probes, creating four running combinations (old/new × app/probe). The updater can detect any failing combination and roll back.

Protocol buffers as configuration format: schema checked at load time, bounded runtime, automatic schema fault detection.

## See Also

- [Continuous Integration](../concepts/continuous-integration.md)
- [SRE Testing Concepts](../concepts/sre-testing.md)
- [Incident Response](../concepts/incident-response.md)
- [Postmortem Culture](../concepts/postmortem-culture.md)
- [Service Reliability Hierarchy](../concepts/service-reliability-hierarchy.md)
