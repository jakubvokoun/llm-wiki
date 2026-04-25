# Data Processing Pipelines

Written by Dan Dennison. Edited by Tim Harvey.

This chapter focuses on the real-life challenges of managing data processing pipelines of depth and complexity. It considers the frequency continuum between periodic pipelines that run very infrequently through to continuous pipelines that never stop running, and discusses the discontinuities that can produce significant operational problems. A fresh take on the leader-follower model is presented as a more reliable and better-scaling alternative to the periodic pipeline for processing Big Data.

## Origin of the Pipeline Design Pattern

The classic approach to data processing is to write a program that reads in data, transforms it in some desired way, and outputs new data. Typically, the program is scheduled to run under the control of a periodic scheduling program such as cron. This design pattern is called a *data pipeline*. Data pipelines go as far back as co-routines, the DTSS communication files, the UNIX pipe, and later, ETL pipelines, but such pipelines have gained increased attention with the rise of "Big Data," or "datasets that are so large and so complex that traditional data processing applications are inadequate."

## Initial Effect of Big Data on the Simple Pipeline Pattern

Programs that perform periodic or continuous transformations on Big Data are usually referred to as "simple, one-phase pipelines."

Given the scale and processing complexity inherent to Big Data, programs are typically organized into a chained series, with the output of one program becoming the input to the next. Programs organized this way are called *multiphase pipelines*, because each program in the chain acts as a discrete data processing phase.

The number of programs chained together in series is a measurement known as the *depth* of a pipeline.

## Challenges with the Periodic Pipeline Pattern

Periodic pipelines are generally stable when there are sufficient workers for the volume of data and execution demand is within computational capacity. However, the collective SRE experience has been that the periodic pipeline model is fragile. When a periodic pipeline is first installed with worker sizing, periodicity, chunking technique, and other parameters carefully tuned, performance is initially reliable. However, organic growth and change inevitably begin to stress the system, and problems arise: jobs that exceed their run deadline, resource exhaustion, and hanging processing chunks that entail corresponding operational load.

## Trouble Caused By Uneven Work Distribution

The key breakthrough of Big Data is the widespread application of "embarrassingly parallel" algorithms to cut a large workload into chunks small enough to fit onto individual machines. Sometimes chunks require an uneven amount of resources relative to one another. For example, in a workload that is partitioned by customer, data chunks for some customers may be much larger than others. Because the customer is the point of indivisibility, end-to-end runtime is thus capped to the runtime of the largest customer.

The "hanging chunk" problem can result when resources are assigned due to differences between machines in a cluster or overallocation to a job. The pattern of typical user code is to wait for the total computation to complete before progressing to the next pipeline stage. That can significantly delay pipeline completion time, because completion is blocked on the worst-case performance as dictated by the chunking methodology in use.

If this problem is detected, the "sensible" response of killing and restarting the job can make matters worse: because pipeline implementations by design usually don't include checkpointing, work on all chunks is restarted from the beginning, wasting the time, CPU cycles, and human effort invested in the previous cycle.

## Drawbacks of Periodic Pipelines in Distributed Environments

Periodic pipelines typically run as lower-priority batch jobs. Jobs scheduled in the gaps left by user-facing web service jobs might be impacted in terms of availability of low-latency resources, pricing, and stability of access to resources. Excessive use of the batch scheduler places jobs at risk of preemptions when cluster load is high.

Delays of up to a few hours might be acceptable for pipelines that run daily. However, as the scheduled execution frequency increases, the minimum time between executions can quickly reach the minimum average delay point, placing a lower bound on the latency that a periodic pipeline can expect to attain. Reducing the job execution interval below this effective lower bound simply results in undesirable behavior: each new run might stack up on the cluster scheduler because the previous run is not complete, or the currently executing run could be killed when the next execution is scheduled to begin.

## Monitoring Problems in Periodic Pipelines

The standard monitoring model involves collecting metrics during job execution, and reporting metrics only upon completion. If the job fails during execution, no statistics are provided. Continuous pipelines do not share these problems because their tasks are constantly running and their telemetry is routinely designed so that real-time metrics are available.

## "Thundering Herd" Problems

For each cycle of a large enough periodic pipeline, potentially thousands of workers immediately start work. If there are too many workers or if the workers are misconfigured or invoked by faulty retry logic, the servers on which they run will be overwhelmed, as will the underlying shared cluster services and any networking infrastructure in use.

Engineers with limited experience managing pipelines tend to amplify this problem by adding more workers to their pipeline when the job fails to complete within a desired period of time. Nothing is harder on cluster infrastructure than a buggy 10,000-worker pipeline job.

## Moiré Load Pattern

A related problem called "Moiré load pattern" occurs when two or more pipelines run simultaneously and their execution sequences occasionally overlap, causing them to simultaneously consume a common shared resource. This problem can occur even in continuous pipelines, although it is less common when load arrives more evenly.

## Introduction to Google Workflow

Faced with the need for continuous processing at scale, Google developed a system in 2003 called "Workflow" that makes continuous processing available at scale. Workflow uses the leader-follower (workers) distributed systems design pattern and the system prevalence design pattern. This combination enables very large-scale transactional data pipelines, ensuring correctness with exactly-once semantics.

### Workflow as Model-View-Controller Pattern

Workflow can be thought of as the distributed systems equivalent of the model-view-controller pattern:

- **Model (Task Master):** Uses the system prevalence pattern to hold all job states in memory for fast availability while synchronously journaling mutations to persistent disk. Workers are completely stateless and can be discarded at any time.
- **View (Workers):** Continually update the system state transactionally with the master. Best performance is achieved when only pointers to work are stored in the Task Master, and actual input/output data is stored in a common filesystem or other storage.
- **Controller (optional):** Supports auxiliary system activities such as runtime scaling of the pipeline, snapshotting, workcycle state control, rolling back pipeline state, or global interdiction for business continuity.

## Stages of Execution in Workflow

Pipeline depth can be increased to any level inside Workflow by subdividing processing into task groups held in the Task Master. Each task group holds the work corresponding to a pipeline stage that can perform arbitrary operations on some piece of data. A stage usually has some worker type associated with it, with multiple concurrent instances possible. Workers can be self-scheduled, looking for different types of work and choosing which type to perform.

## Workflow Correctness Guarantees

Workflow provides a four-layer correctness guarantee:

1. **Worker output through configuration tasks** creates barriers on which to predicate work.
2. **All work committed requires a currently valid lease** held by the worker.
3. **Output files are uniquely named** by the workers (preventing orphaned workers from destroying work).
4. **Server token validation:** The client and server validate the Task Master itself by checking a server token on every operation, preventing rogue or misconfigured Task Masters from corrupting the pipeline.

Because each task is unique and immutable, and all tasks are versioned, if the configuration changed while a work unit was in flight, all workers of that type will be unable to commit despite owning current leases. This ensures all work performed after a configuration change is consistent with the new configuration.

## Ensuring Business Continuity

Workflow resolves datacenter failure scenarios conclusively for continuous processing pipelines. To obtain global consistency, the Task Master stores journals on Spanner (a globally available, globally consistent, but low-throughput filesystem). Each Task Master uses the distributed lock service Chubby to elect the writer, and clients look up the current Task Master using internal naming services.

For globally distributed Workflows, two or more local Workflows run in distinct clusters. As units of work are consumed through a pipeline, equivalent reference tasks are inserted into a global Workflow. If tasks cannot be removed from the global Workflow, the local Workflow blocks until the global Workflow becomes available again, ensuring transactional correctness.

A heartbeat mechanism automates failover: if the heartbeat task is not updated within the timeout period, the remote Workflow's helper binary seizes the work in progress as documented by the reference tasks and the pipeline continues.

## Summary

Periodic pipelines are valuable. However, if a data processing problem is continuous or will organically grow to become continuous, don't use a periodic pipeline. Instead, use a technology with characteristics similar to Workflow.

Continuous data processing with strong guarantees, as provided by Workflow, performs and scales well on distributed cluster infrastructure, routinely produces results that users can rely upon, and is a stable and reliable system for the SRE team to manage and maintain.
