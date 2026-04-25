---
title: "SRE Book — Chapter 26: Data Integrity: What You Read Is What You Wrote"
tags: [sre, data-integrity, reliability, backups, soft-deletion]
sources: [sre-data-integrity.md]
updated: 2026-04-25
---

# SRE Book — Chapter 26: Data Integrity

Written by Raymond Blum and Rhandeev Singh.

Data integrity is a measure of the accessibility and accuracy of datastores needed to provide users with adequate service. From the user's perspective, data loss, corruption, and extended unavailability are typically indistinguishable.

## Key Takeaways

### Strict Requirements

Data integrity requirements are often stricter than uptime requirements. An SLO of 99.99% good bytes in a 2 GB artifact allows ~200 KB to be garbled—catastrophic for executables and databases. Meanwhile, 99.99% uptime only requires 1 hour downtime/year.

**The secret:** Proactive detection coupled with rapid repair and recovery. If corruption is detected and fixed within 30 minutes before users are affected, data integrity is effectively 100% for the year.

### 24 Failure Mode Combinations

Three factors, each with multiple variants:

- **Root cause:** User action, operator error, application bugs, infrastructure defects, faulty hardware, site catastrophes
- **Scope:** Widespread or narrow
- **Rate:** Big bang or creeping

Creeping bugs (10 rows deleted/minute over weeks) are hardest—discovered weeks or months after starting. Require **point-in-time recovery** ("time-travel" internally).

### Three-Layer Defense in Depth

**Layer 1: Soft Deletion**

- Trash folder → primary defense against user error
- Soft deletion (immediate inaccessibility, delayed destruction) → primary defense against developer error
- Lazy deletion (in cloud APIs) → cloud provider preserves data for weeks before destroying
- Common delays: 15, 30, 45, or 60 days; majority of issues reported within 60 days at Google

Design interfaces to prevent developers from accidentally bypassing soft deletion. Even the best armor is useless if you don't put it on.

**Layer 2: Backups and Recovery**

- Backups don't matter; what matters is **recovery**
- Distinguish archives (compliance/audit; recovery time isn't critical) from real backups (must restore within uptime SLO)
- **Tiered strategy:**
  - Tier 1: Frequent, quickly-restored backups close to live data; retained hours to days; minutes to restore
  - Tier 2: Less frequent; local to site; retained days to ~2 weeks; hours to restore
  - Tier 3+: Nearline/offline/tape; offsite; protects against site-level disasters
- **Replication ≠ recoverability:** A corrupt database row is immediately synced to all replicas. Need diversity at every layer.
- At petabyte scale, full backups are infeasible (700 PB = 8 decades to verify). Use "trust points" (verified immutable data) + incremental backups + horizontal sharding of backup jobs.

**Layer 3: Early Detection (Out-of-Band Validation)**

- Bad data propagates; detect early for easier recovery
- Implement as MapReduce/Hadoop pipelines checking invariants within and between datastores
- Only validate invariants whose failure is devastating—too strict = engineers abandon it; too lenient = corruption slips through
- Auto-fix when possible (transforms emergency into business as usual)
- Gmail uses daily validators; one validator runs in 10–14 daily shards due to scale
- **Organizational structure:** Central infrastructure team owns the framework; product teams own the business logic

**Overarching Layer: Replication**
Not for recoverability, but stagger backups across sites and use redundancy coding (RAID, Reed-Solomon, GFS-style replication) to protect the backups themselves.

### Knowing Recovery Works

**You only know that you can recover your recent state if you actually do so.** Automate recovery tests and run them continuously. Set up heartbeat alerts for recovery job success.

Test aspects: backup validity, machine resource sufficiency, wall time, monitoring capability, dependency availability (e.g., 24/7 offsite vault access).

### Google SRE Data Integrity Principles

- **Beginner's Mind:** Never assume you understand a complex system well enough to rule out failure
- **Trust but Verify:** Check data correctness out-of-band even when APIs guarantee consistency
- **Hope Is Not a Strategy:** Components not continually exercised fail when needed
- **Defense in Depth:** Multiple tiered strategies that fall back to one another
- **Revisit and Reexamine:** "Was safe yesterday" doesn't guarantee safety today

### Case Studies

**Gmail February 2011:** First large-scale GTape restore. Series of failures exceeded internal recovery mechanisms. Used tape backups for defense in depth. ~99%+ of data recovered within hours of estimate. Required coordination of many teams via regular dress rehearsals.

**Google Music March 2012:** Refactored deletion pipeline introduced race condition (probabilistic; occurred more regularly as data volume grew). 600,000 audio references deleted incorrectly. Discovery delayed >1 month. Recovery: 5,475 restore jobs from ~5,000 tapes (1.5 PB); enabled by recent DiRT exercises. 436,223 tracks recovered from tape; ~161,000 reinstated from original store copies or re-uploaded by users.

## Related Concepts

- [Data Integrity](../concepts/data-integrity.md) — full concept page
- [Distributed Consensus](../concepts/distributed-consensus.md) — Spanner and Chubby used in data integrity infrastructure
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
