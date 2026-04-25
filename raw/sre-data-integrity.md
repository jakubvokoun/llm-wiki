# Data Integrity: What You Read Is What You Wrote

Written by Raymond Blum and Rhandeev Singh. Edited by Betsy Beyer.

**Data integrity is a measure of the accessibility and accuracy of the datastores needed to provide users with an adequate level of service.**

From the user's perspective, data loss, data corruption, and extended unavailability are typically indistinguishable. A Gmail UI bug that displayed an empty mailbox for too long could be perceived as data loss even if no data was actually lost. 24 hours is a good starting point for establishing "too long" for Google Apps-class services.

## Data Integrity's Strict Requirements

Data integrity requirements are often *stricter* than uptime requirements despite seeming otherwise. An SLO of 99.99% good bytes in a 2 GB artifact would allow ~200 KB to be garbled—catastrophic for executables, databases, and documents. A 99.99% uptime SLO (allowing ~1 hour downtime/year) is actually a less strict requirement.

**The secret to superior data integrity: proactive detection coupled with rapid repair and recovery.** If corruption is detected before users are affected and the artifact is removed, fixed, and returned to service within 30 minutes, the object is effectively 99.99% available that year while data integrity remains 100%.

## Types of Failures That Lead to Data Loss

24 distinct failure types arise from combinations of three factors:

- **Root cause:** User action, operator error, application bugs, infrastructure defects, faulty hardware, site catastrophes
- **Scope:** Widespread (many users) or narrow (small subset of users)
- **Rate:** Big bang (1M rows deleted in 1 minute) or creeping (10 rows deleted per minute over weeks)

A study of 19 data recovery efforts at Google found the most common user-visible data loss scenarios involved data deletion or loss of referential integrity caused by software bugs—especially low-grade corruption or deletion discovered weeks to months after the bugs were first released into production. This scenario requires **point-in-time recovery** (called "time-travel" internally).

## Three-Layer Defense in Depth

### First Layer: Soft Deletion

When velocity is high and privacy matters, bugs in applications account for the vast majority of data loss and corruption events.

**Soft deletion:** Deleted data is immediately marked as such but preserved, accessible only via administrative code paths. Hard-deleted only after a delay (commonly 15, 30, 45, or 60 days). Google's experience: majority of account hijacking and data integrity issues are reported within 60 days.

- **Trash folder** — primary defense against user error
- **Soft deletion** — primary defense against developer error, secondary against user error
- **Lazy deletion** (in cloud/developer offerings) — behind-the-scenes purging by the storage system. Data deleted by a cloud application becomes immediately inaccessible to the application but preserved by the cloud provider for up to a few weeks. Not advisable when privacy guarantees require prompt destruction of deleted data.
- **Revision history** — useful for some corruption scenarios, but needs its own soft/lazy deletion applied to it

Design interfaces to hinder developers unfamiliar with code from circumventing soft deletion. Even the best armor is useless if you don't put it on.

### Second Layer: Backups and Recovery

**Key principle: Backups don't matter; what matters is recovery.** The factors supporting successful recovery should drive backup decisions.

Recovery drives these decisions:
- **Which backup/recovery methods to use**
- **Backup frequency** (how much recent data you can afford to lose)
- **Where you store backups** (locally for fast restore; offsite/offline for site-level failures)
- **How long you retain backups**

**Backups vs archives:**
- **Archives:** Safekeep data for auditing/compliance; recovery doesn't need to complete within service uptime requirements
- **Real backups:** Must be quickly loadable back into an application; daily, hourly, or continuous incremental; must complete well within uptime needs

**Tiered backup strategy:**
1. **Tier 1:** Many frequent, quickly-restored backups stored closest to live datastores (same or similar storage tech). Retained hours to single-digit days; can restore in minutes. Protects against software bugs and developer error.
2. **Tier 2:** Fewer backups retained single-digit to low double-digit days on random-access distributed filesystems local to the site. Hours to restore. Protects against bugs detected too late for Tier 1, and mishaps affecting specific storage technologies.
3. **Tier 3+:** Nearline/offline storage (dedicated tape libraries, offsite media). Protects against site-level issues. Less frequent but retained longer.

**Replication is not recoverability.** Datastores that automatically sync multiple replicas guarantee that a corrupt row or errant delete is pushed to all copies before you can isolate the problem. Diversity is key: protecting against a failure at layer X requires storing data on diverse components at that layer. Media isolation protects against media flaws.

**The competing forces at scale:** Freshness and restore completion compete against comprehensive protection. At 700 petabytes, a single-task full verification takes 8 decades. Solutions: "trust points" (verified immutable data portions), incremental backups, horizontal sharding of backup jobs.

### Third Layer: Early Detection (Out-of-Band Validation)

"Bad" data doesn't sit idly—it propagates. References to missing or corrupt data are copied, links fan out. The sooner you know about a loss, the easier and more complete your recovery can be.

**Out-of-band data validation pipelines** (usually MapReduce/Hadoop jobs) check invariants both within and between datastores. Key guidelines:
- Only validate invariants whose failure causes devastation to users (too strict → engineers abandon validation; not strict enough → corruption slips through)
- Daily validators for the most disastrous scenarios; less frequent but more rigorous validation for scale control
- Auto-fix inconsistencies when possible (transforms "all-hands-on-deck emergency" into "business as usual")
- Provide comprehensive troubleshooting tools, dashboards, playbooks, and rate-limiting features for on-call engineers

Google Drive's validator auto-fixed a file-contents-vs-folder-listing inconsistency in 2013, turning a potential emergency data loss situation into business as usual. Gmail runs daily validators across a significant portion of its compute footprint.

**Organizational structure:** Central infrastructure team maintains the validation framework; product engineering teams maintain custom business logic at the heart of validators.

### Overarching Layer: Replication

In an ideal world, every storage instance including backups would be replicated. When volume makes full replication infeasible, stagger backups across different sites and use redundancy methods (RAID, Reed-Solomon erasure codes, GFS-style replication).

## Knowing That Data Recovery Will Work

**You only know that you can recover your recent state if you actually do so.**

If recovery tests are a manual, staged event, testing becomes drudgery that isn't performed deeply or frequently enough. **Automate recovery tests and run them continuously.** Set up alerts that fire when a recovery process fails to provide a heartbeat indication of success.

Confirm:
- Are backups valid and complete (not empty)?
- Sufficient machine resources for setup, restore, and post-processing?
- Does recovery complete in reasonable wall time?
- Can you monitor the recovery process as it progresses?
- Free of critical dependencies outside your control (e.g., 24/7 offsite storage vault access)?

## Google SRE Data Integrity Principles

**Delivering a recovery system, rather than a backup system:** Teams define SLOs for data availability in various failure modes and practice demonstrating their ability to meet those SLOs. Backups are a tax paid for the municipal service of guaranteed data availability.

**Data integrity is the means; data availability is the goal.** User data preserved but inaccessible is effectively the same as having no data at all.

## Case Studies

### Gmail — February 2011: Restore from GTape

A series of failures caused Gmail to lose a significant amount of user data—the first large-scale use of GTape (Google's offline tape backup system) to restore live customer data.

**Outcome:** Google was able to:
- Deliver an estimate of restoration time
- Restore all affected accounts within several hours of the initial estimate
- Recover 99%+ of data before the estimated completion time

**Why it worked:** Regular dress rehearsals and dry runs of tape restoration. Defense in depth: tape backups provided protection against internal Gmail redundancy failures AND potential zero-day vulnerabilities in disk storage layers. Many teams unrelated to Gmail pitched in due to a central recovery plan.

**Key lesson:** The tape backup surprised the public ("Doesn't Google have lots of disks and fast networking?"). The principle of defense in depth dictates multiple layers of protection against breakdown of any single mechanism.

### Google Music — March 2012: Runaway Deletion Detection

A refactored data deletion pipeline introduced a race condition that deleted approximately 600,000 audio references that shouldn't have been removed, affecting files for 21,000 users. The bug had been running for over a month before discovery.

**Recovery process:** 5,475 separate restore jobs from ~5,000 backup tapes trucked in from offsite storage. 1.5 petabytes of audio data recovered in ~5 days of actual recovery effort (7 days total). Enabled by DiRT (Disaster Recovery Testing) exercises held weeks earlier.

**Only 436,223 of ~600,000 tracks** had tape backups; ~161,000 were deleted before they could be backed up. These were mostly store-bought tracks (reinstated from original store copies) or user-uploaded files (re-requested from clients).

**Root cause:** A data deletion pipeline designed with coordination and large margins was optimized for performance as data volume grew. Performance optimizations increased the probability of race conditions until they occurred regularly. A refactoring of the pipeline further increased the probability.

**Fix:** Redesigned pipeline to eliminate the race condition; enhanced production monitoring and alerting to detect large-scale runaway deletion bugs before users notice.

## General Principles

- **Beginner's Mind:** Never think you understand enough of a complex system to say it won't fail in a certain way. Trust but verify; apply defense in depth.
- **Trust but Verify:** Check correctness of critical data using out-of-band validators even if API semantics suggest you need not. Perfect algorithms may not have perfect implementations.
- **Hope Is Not a Strategy:** System components that aren't continually exercised fail when you need them most. Automate recovery tests.
- **Defense in Depth:** Even bulletproof systems are susceptible to bugs and operator error. Multitiered strategies that fall back to one another address a broad swath of scenarios at reasonable cost.
- **Revisit and Reexamine:** "Was safe yesterday" doesn't help tomorrow. Systems and infrastructure change; prove assumptions remain relevant.

## Conclusion

As you get better at recovering from any breakage in reasonable time N, find ways to whittle down N through more rapid and finer-grained loss detection. Switch from planning recovery to planning prevention, with the aim of achieving *all the data, all the time*.
