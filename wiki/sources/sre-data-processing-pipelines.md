---
title: "SRE Book — Chapter 25: Data Processing Pipelines"
tags: [sre, data-pipelines, distributed-systems, reliability, workflow]
sources: [sre-data-processing-pipelines.md]
updated: 2026-04-25
---

# SRE Book — Chapter 25: Data Processing Pipelines

Written by Dan Dennison.

This chapter covers the operational challenges of periodic vs. continuous data processing pipelines, and introduces Google's Workflow system as a more reliable alternative.

## Key Takeaways

### Pipeline Terminology

- **Data pipeline:** A program that reads data, transforms it, and outputs new data; typically scheduled by cron
- **Multiphase pipeline:** Programs chained in series; output of one becomes input to the next
- **Pipeline depth:** Number of programs chained together (shallow = 1, deep = tens or hundreds)

### Fragility of Periodic Pipelines

Periodic pipelines are initially stable when tuned, but organic growth inevitably causes problems:

- Jobs exceeding run deadlines
- Resource exhaustion
- Hanging processing chunks (operational load)

**Root causes:**

- **Hanging chunks:** Uneven work distribution (e.g., by customer size). Sorting requires all data before proceeding. Default response (kill + restart) wastes all work because pipelines don't checkpoint.
- **Batch scheduling risks:** Lower-priority batch jobs compete with user-facing work. Jobs can stack up if the execution interval is lower than the minimum achievable delay. Risk of preemption when cluster load is high.
- **Monitoring gaps:** Metrics typically reported only on completion—no real-time visibility. If the job fails, no statistics are provided.
- **Thundering herd:** Thousands of workers start simultaneously. Naive retry-on-failure amplifies the problem. Engineers add more workers when jobs are slow, making it worse. "Nothing is harder on cluster infrastructure than a buggy 10,000-worker pipeline job."
- **Moiré load pattern:** Two or more pipelines overlap periodically, simultaneously consuming a shared resource—visible in stacked resource usage graphs.

### Google Workflow

Google developed Workflow in 2003 to provide continuous processing at scale with **exactly-once semantics**.

**Model-View-Controller analogy:**

- **Model (Task Master):** Holds all job states in memory (fast access) + synchronous journal to disk (persistence). Workers are completely stateless and can be discarded at any time.
- **View (Workers):** Stateless; acquire work with a lease; update Task Master state transactionally.
- **Controller (optional):** Runtime scaling, snapshotting, global interdiction for business continuity.

**Pipeline depth:** Increased to any level by subdividing processing into task groups in the Task Master. Supports mapping, shuffling, sorting, splitting, merging in any stage.

### Workflow Correctness Guarantees (Four Layers)

1. **Configuration barriers:** Worker output through configuration tasks creates barriers on which to predicate work
2. **Lease ownership:** All work committed requires a currently valid lease held by the worker
3. **Unique output filenames:** Workers write to uniquely named output files—orphaned workers cannot destroy valid work
4. **Server token validation:** Client and server validate the Task Master on every operation—prevents rogue/misconfigured Task Masters

Additionally, all tasks are versioned—if configuration changes mid-flight, all workers lose their leases and must re-execute with the new configuration.

### Business Continuity

Global consistency via Spanner (globally available, globally consistent, low-throughput filesystem). Task Masters use Chubby for distributed lock/leader election.

For globally distributed pipelines: two or more local Workflows in distinct clusters + reference tasks in a global Workflow. If local Workflow can't remove reference tasks from global Workflow, it blocks until global Workflow recovers. **Heartbeat mechanism:** if heartbeat is not updated within timeout, remote Workflow seizes work in progress from reference tasks.

### Bottom Line

- Periodic pipelines are valuable but fragile
- If a data processing problem is continuous or will organically grow to become continuous: **don't use a periodic pipeline**
- Use a technology with characteristics similar to Workflow

## Related Concepts

- [Data Pipelines](../concepts/data-pipelines.md) — full concept page
- [Distributed Consensus](../concepts/distributed-consensus.md) — Task Master uses Chubby/consensus for leader election
- [Overload Protection](../concepts/overload-protection.md) — thundering herd is an overload problem
