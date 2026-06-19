---
title: "Data Integrity"
tags: [sre, reliability, data-integrity, backups, soft-deletion]
sources: [sre-data-integrity.md]
updated: 2026-04-25
---

# Data Integrity

Data integrity is a measure of the accessibility and accuracy of datastores needed to provide users with adequate service. From users' perspectives, data loss, corruption, and extended unavailability are typically indistinguishable.

**Data integrity is the means; data availability is the goal.**

## Key Insight: Stricter Than Uptime

99.99% uptime = ~1 hour downtime/year (high but understood). 99.99% good bytes in a 2 GB artifact = ~200 KB garbled = catastrophic for executables, databases, and documents.

**The secret:** Proactive detection + rapid repair. Detecting and fixing corruption within 30 minutes before users are affected yields effective 99.99% availability _and_ 100% data integrity.

## 24 Failure Mode Combinations

Three factors in any combination:

- **Root cause:** User action, operator error, application bugs, infrastructure defects, faulty hardware, site catastrophes
- **Scope:** Widespread (many users) or narrow (small subset)
- **Rate:** Big bang (sudden mass deletion) or creeping (slow, undetected over weeks/months)

Most common at Google: data deletion or loss of referential integrity from software bugs—especially creeping bugs discovered weeks to months later. Require **point-in-time recovery**.

## Three-Layer Defense in Depth

### Layer 1: Soft Deletion

**Principle:** Never permanently delete immediately. Mark data as deleted, destroy after a delay.

| Mechanism                     | Defense Against          | Notes                                                                       |
| ----------------------------- | ------------------------ | --------------------------------------------------------------------------- |
| Trash folder (user-visible)   | User error               | Primary defense                                                             |
| Soft deletion (API-level)     | Developer error          | Primary; also secondary user error defense                                  |
| Lazy deletion (cloud storage) | Internal developer error | Behind-the-scenes; not appropriate when privacy requires prompt destruction |

Common delays: 15–60 days. At Google, majority of account hijacking/integrity issues reported within 60 days.

Design APIs to make soft deletion the default and hard to bypass. Apply soft deletion semantics to revision history as well.

### Layer 2: Backups and Recovery

**Principle:** Focus on recovery, not backups. Recovery requirements drive backup decisions.

**Backups vs archives:**

- Archives: long-term retention for compliance; slow recovery is acceptable
- Real backups: must restore within service uptime SLO; daily/hourly/continuous

**Tiered strategy:** | Tier | Storage | Retention | Restore time | Protects against | |------|---------|-----------|-------------|-----------------| | 1 | Same/similar tech as live data | Hours–days | Minutes | Software bugs, developer error | | 2 | Distributed filesystem, local site | Days–2 weeks | Hours | Bugs detected too late for Tier 1; specific storage tech failures | | 3+ | Nearline/offline (tape, offsite) | Weeks–months | Hours–days | Site-level failures |

**Critical principle: Replication ≠ recoverability.** Corrupt database rows are immediately synced to all replicas. Need diversity at every stack layer. Media isolation: a disk device driver bug is unlikely to affect tape drives.

**At scale (petabytes+):**

- Full backups may be infeasible (700 PB = 8 decades to verify in a single task)
- Use "trust points" (verified immutable data portions) + incremental backups
- Horizontal sharding of backup and verification jobs
- Focus on restores (care about data freshness from the point of recovery)

### Layer 3: Early Detection (Out-of-Band Validation)

Bad data propagates. The sooner you know, the easier the recovery.

**Implementation:** MapReduce/Hadoop jobs checking invariants within and between datastores.

**Guidelines:**

- Only validate invariants that cause devastation if violated (not too strict, not too lenient)
- Automate fixes when possible (transforms emergencies into business as usual)
- Daily validators for the most disastrous scenarios; less frequent for scale-intensive checks
- Provide playbooks, dashboards, investigation tools, rate-limiting controls for on-call engineers

**Organizational model:** Central infrastructure team owns the validation framework; product teams own the business logic validators. Small teams operating at high velocity cannot maintain all components independently.

**Overarching layer: Replication.** Stagger backups across different sites; use redundancy coding (RAID, Reed-Solomon, GFS-style) to protect backups themselves.

## Knowing Recovery Works

**You only know that you can recover your recent state if you actually do so.**

Automate recovery tests and run them continuously. Set up heartbeat alerts for recovery job success.

Check: backup validity, machine resource sufficiency, wall time, monitoring capability, dependency availability.

Regular DiRT (Disaster Recovery Testing) exercises enabled Google to execute the Gmail and Google Music recoveries effectively—teams had already rehearsed the process.

## SRE Principles for Data Integrity

- **Beginner's Mind:** Never assume complex systems can't fail in unexpected ways
- **Trust but Verify:** Out-of-band validators even when APIs claim to guarantee consistency
- **Hope Is Not a Strategy:** Automate recovery tests; don't rely on discipline
- **Defense in Depth:** Multiple tiered strategies, each independently effective
- **Revisit and Reexamine:** Systems change; prove assumptions remain relevant

## Sources

- [SRE Book Ch. 26: Data Integrity](../sources/sre-data-integrity.md)
