---
title: "Data Pipelines"
tags: [sre, data-processing, distributed-systems, reliability]
sources: [sre-data-processing-pipelines.md]
updated: 2026-04-25
---

# Data Pipelines

A data pipeline is a program that reads data, transforms it, and outputs new data. Typically scheduled by cron or a similar periodic scheduling system. The classic pattern is called **ETL (Extract, Transform, Load)**.

## Terminology

- **Simple pipeline:** One-phase program performing a transformation
- **Multiphase pipeline:** Programs chained in series; output of one becomes input to the next
- **Pipeline depth:** Number of chained programs (shallow = 1, deep = tens or hundreds)
- **Periodic pipeline:** Runs on a schedule (cron-based)
- **Continuous pipeline:** Never stops running; tasks are always running

## Operational Challenges of Periodic Pipelines

Periodic pipelines are initially stable when tuned, but organic growth inevitably causes problems.

### Uneven Work Distribution

"Embarrassingly parallel" algorithms cut work into chunks. When chunks are unequal (e.g., partitioned by customer, where some customers have far more data), end-to-end runtime is capped to the largest chunk.

**Hanging chunk problem:** Resources assigned due to machine differences or overallocation. Work requires all data before proceeding (e.g., sorting). Default response (kill and restart) wastes all prior work because pipelines typically don't checkpoint.

### Batch Scheduling Risks

- Lower-priority batch jobs compete with user-facing work for resources
- Jobs stack up when execution interval is lower than minimum achievable scheduling delay
- Preemption risk when cluster load is high
- Execution cost inversely proportional to requested startup delay

### Monitoring Gaps

Standard monitoring: collect metrics during execution, report only on completion. If a job fails mid-run, no statistics are provided. Continuous pipelines don't have this problem—their tasks are always running with real-time telemetry.

### Thundering Herd

Large periodic pipelines: thousands of workers start simultaneously. If workers are misconfigured or retry naively, servers and cluster infrastructure are overwhelmed. Engineers amplify the problem by adding more workers when jobs are slow. "Nothing is harder on cluster infrastructure than a buggy 10,000-worker pipeline job."

### Moiré Load Pattern

When two or more pipelines run simultaneously and their execution sequences occasionally overlap, they simultaneously consume shared resources—visible as spikes in stacked resource usage graphs.

## Choosing Periodic vs. Continuous

| Scenario                                              | Recommendation                                             |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| Batch work, infrequent, not latency-sensitive         | Periodic pipeline (simpler)                                |
| Growing usage, increasing frequency requirements      | Plan for continuous from the start                         |
| Already continuous or organically becoming continuous | Use continuous pipeline technology (e.g., Google Workflow) |

**Key advice:** If a data processing problem is continuous or will organically grow to become continuous, don't use a periodic pipeline. Starting with a periodic pipeline and migrating later is very costly—business demands for new features usually coincide with the worst time to refactor.

## Google Workflow

Google developed Workflow in 2003 to enable continuous processing at scale with **exactly-once semantics**. Uses leader-follower pattern and system prevalence (journaled in-memory state).

**Architecture (MVC analogy):**

- **Task Master (Model):** Holds all job states in memory; journals mutations to Spanner synchronously; workers are completely stateless
- **Workers (View):** Acquire work with a lease; update Task Master transactionally; unique output filenames prevent orphaned workers from corrupting valid work
- **Controller (optional):** Runtime scaling, snapshotting, global interdiction

**Four correctness guarantees:**

1. Configuration barriers predicate work
2. Valid lease required to commit
3. Unique output filenames per worker
4. Server token validated on every operation

**Business continuity:** Task Masters use Chubby for leader election; journals stored in Spanner; heartbeat mechanism allows remote Workflow to seize work if local Workflow goes down.

## Sources

- [SRE Book Ch. 25: Data Processing Pipelines](../sources/sre-data-processing-pipelines.md)
