# Chapter 10 — Practical Alerting from Time-Series Data

Written by Jamie Wilkinson  
Edited by Kavita Guliani

> May the queries flow, and the pager stay silent.
>
> Traditional SRE blessing

Monitoring, the bottom layer of the Hierarchy of Production Needs, is fundamental to running a stable service. Monitoring enables service owners to make rational decisions about the impact of changes to the service, apply the scientific method to incident response, and of course ensure their reason for existence: to measure the service's alignment with business goals.

Monitoring a very large system is challenging for a couple of reasons:

- The sheer number of components being analyzed
- The need to maintain a reasonably low maintenance burden on the engineers responsible for the system

Google's monitoring systems don't just measure simple metrics, such as the average response time of an unladen European web server; we also need to understand the distribution of those response times across all web servers in that region. This knowledge enables us to identify the factors contributing to the latency tail.

At the scale our systems operate, being alerted for single-machine failures is unacceptable because such data is too noisy to be actionable. Instead we try to build systems that are robust against failures in the systems they depend on. Rather than requiring management of many individual components, a large system should be designed to aggregate signals and prune outliers. We need monitoring systems that allow us to alert for high-level service objectives, but retain the granularity to inspect individual components as needed.

Google's monitoring systems evolved over the course of 10 years from the traditional model of custom scripts that check responses and alert, wholly separated from visual display of trends, to a new paradigm. This new model made the collection of time-series a first-class role of the monitoring system, and replaced those check scripts with a rich language for manipulating time-series into charts and alerts.

## The Rise of Borgmon

Shortly after the job scheduling infrastructure Borg was created in 2003, a new monitoring system—Borgmon—was built to complement it.

In recent years, monitoring has undergone a Cambrian Explosion: Riemann, Heka, Bosun, and Prometheus have emerged as open source tools that are very similar to Borgmon's time-series-based alerting. In particular, Prometheus shares many similarities with Borgmon, especially when you compare the two rule languages.

Instead of executing custom scripts to detect system failures, Borgmon relies on a common data exposition format; this enables mass data collection with low overheads. We call this *white-box monitoring*.

The data is used both for rendering charts and creating alerts, which are accomplished using simple arithmetic. Because collection is no longer in a short-lived process, the history of the collected data can be used for that alert computation as well.

To facilitate mass collection, the metrics format had to be standardized. An older method of exporting the internal state (known as *varz*) was formalized to allow the collection of all metrics from a single target in one HTTP fetch:

```
% curl https://webserver:80/varz

http_requests 37
errors_total 12
```

A Borgmon can collect from other Borgmon, so we can build hierarchies that follow the topology of the service, aggregating and summarizing information and discarding some strategically at each level. Typically, a team runs a single Borgmon per cluster, and a pair at the global level.

## Instrumentation of Applications

The `/varz` HTTP handler simply lists all the exported variables in plain text, as space-separated keys and values, one per line. A later extension added a mapped variable, which allows the exporter to define several labels on a variable name, and then export a table of values or a histogram. An example map-valued variable:

```
http_responses map:code 200:25 404:0 500:12
```

Adding a metric to a program only requires a single declaration in the code where the metric is needed. The schemaless textual interface makes the barrier to adding new instrumentation very low.

## Collection of Exported Data

To find its targets, a Borgmon instance is configured with a list of targets using one of many name resolution methods. The target list is often dynamic, so using service discovery reduces the cost of maintaining it and allows the monitoring to scale.

At predefined intervals, Borgmon fetches the `/varz` URI on each target, decodes the results, and stores the values in memory.

Borgmon also records "synthetic" variables for each target:

- If the name was resolved to a host and port
- If the target responded to a collection
- If the target responded to a health check
- What time the collection finished

## Storage in the Time-Series Arena

Borgmon stores all the data in an in-memory database, regularly checkpointed to disk. The data points have the form `(timestamp, value)`, and are stored in chronological lists called *time-series*, and each time-series is named by a unique set of *labels*, of the form `name=value`.

The structure is a fixed-sized block of memory, known as the *time-series arena*, with a garbage collector that expires the oldest entries once the arena is full. The time interval between the most recent and oldest entries in the arena is the *horizon*. Typically, datacenter and global Borgmon are sized to hold about 12 hours of data for rendering consoles. The memory requirement for a single data point is about 24 bytes, so we can fit 1 million unique time-series for 12 hours at 1-minute intervals in under 17 GB of RAM.

Periodically, the in-memory state is archived to an external system known as the Time-Series Database (TSDB). Borgmon can query TSDB for older data and, while slower, TSDB is cheaper and larger than a Borgmon's RAM.

### Labels and Vectors

Time-series are stored as sequences of numbers and timestamps, referred to as *vectors*. The name of a time-series is a *labelset*, because it's implemented as a set of labels expressed as `key=value` pairs.

A few label names are declared as important:

- `var` — The name of the variable
- `job` — The name given to the type of server being monitored
- `service` — A loosely defined collection of jobs that provide a service to users
- `zone` — A Google convention that refers to the location (typically the datacenter) of the Borgmon

A query for a time-series does not require specification of all these labels; a search for a labelset returns all matching time-series in a vector.

Labels can be added to a time-series from:

- The target's name (e.g., the job and instance)
- The target itself (e.g., via map-valued variables)
- The Borgmon configuration (e.g., annotations about location or relabeling)
- The Borgmon rules being evaluated

## Rule Evaluation

Borgmon is really just a programmable calculator, with some syntactic sugar that enables it to generate alerts. The Borgmon program code, also known as *Borgmon rules*, consists of simple algebraic expressions that compute time-series from other time-series. These rules can be quite powerful because they can query the history of a single time-series (i.e., the time axis), query different subsets of labels from many time-series at once (i.e., the space axis), and apply many mathematical operations.

Aggregation is the cornerstone of rule evaluation in a distributed environment. Aggregation entails taking the sum of a set of time-series from the tasks in a job in order to treat the job as a whole.

**Counter vs Gauge**: A counter is any monotonically non-decreasing variable. Gauges may take any value they like. Counters measure increasing values, such as the total number of kilometers driven, while gauges show current state, such as the amount of fuel remaining. When collecting Borgmon-style data, it's better to use counters, because they don't lose meaning when events occur between sampling intervals.

Example rule to compute request rate:

```
rules <<<
  # Compute the rate of requests for each task from the count of requests
  {var=task:http_requests:rate10m,job=webserver} =
    rate({var=http_requests,job=webserver}[10m]);

  # Sum the rates to get the aggregate rate of queries for the cluster
  {var=dc:http_requests:rate10m,job=webserver} =
    sum without instance({var=task:http_requests:rate10m,job=webserver})
>>>
```

The Google convention uses a colon-separated triplet in variable names indicating the aggregation level, the variable name, and the operation that created that name (e.g., `task:http_requests:rate10m` = "task HTTP requests 10-minute rate").

## Alerting

When an alerting rule is evaluated by a Borgmon, the result is either true (alert triggered) or false. Experience shows that alerts can "flap" (toggle their state quickly); therefore, the rules allow a minimum duration for which the alerting rule must be true before the alert is sent. Typically, this duration is set to at least two rule evaluation cycles.

Example alert:

```
rules <<<
  {var=dc:http_errors:ratio_rate10m,job=webserver} > 0.01
    and by job, error
  {var=dc:http_errors:rate10m,job=webserver} > 1
    for 2m
    => ErrorRatioTooHigh
      details "webserver error ratio at %trigger_value%"
      labels { severity=page };
>>>
```

Borgmon is connected to a centrally run service, known as the Alertmanager, which receives Alert RPCs when the rule first triggers, and then again when the alert is considered to be "firing." The Alertmanager is responsible for routing the alert notification to the correct destination. Alertmanager can:

- Inhibit certain alerts when others are active
- Deduplicate alerts from multiple Borgmon that have the same labelsets
- Fan-in or fan-out alerts based on their labelsets when multiple alerts with similar labelsets fire

## Sharding the Monitoring Topology

A Borgmon can import time-series data from other Borgmon, as well. A typical deployment uses two or more global Borgmon for top-level aggregation and one Borgmon in each datacenter to monitor all the jobs running at that location. More complicated deployments shard the datacenter Borgmon further into a purely scraping-only layer and a DC aggregation layer that performs mostly rule evaluation.

Upper-tier Borgmon can filter the data they want to stream from the lower-tier Borgmon, so that the global Borgmon does not fill its arena with all the per-task time-series from the lower tiers.

## Black-Box Monitoring

Borgmon is a white-box monitoring system—it inspects the internal state of the target service. However, white-box monitoring does not provide a full picture: you aren't aware of what the users see. Queries lost due to DNS errors or server crashes are invisible.

Teams at Google solve this coverage issue with Prober, which runs a protocol check against a target and reports success or failure. Prober can validate the response payload (e.g., HTML contents of an HTTP response) and extract and export values as time-series. Prober is a hybrid of the check-and-test model with some richer variable extraction.

## Maintaining the Configuration

Borgmon configuration separates the definition of the rules from the targets being monitored. This means the same sets of rules can be applied to many targets at once, instead of writing nearly identical configuration over and over.

Borgmon also supports language templates (macro-like system) enabling engineers to construct libraries of rules that can be reused. The Production Monitoring team runs a continuous integration service that executes a suite of tests, packages the configuration, and ships the configuration to all the Borgmon in production.

Two classes of monitoring configuration libraries have emerged:

1. **Variable schema libraries**: Codify the emergent schema of variables exported from a given library of code (e.g., HTTP server library, memory allocation, RPC services)
2. **Aggregation topology libraries**: Templates to manage aggregation of data from a single-server task to the global service footprint

## Ten Years On

Borgmon transposed the model of check-and-alert per target into mass variable collection and a centralized rule evaluation across the time-series for alerting and diagnostics.

This decoupling allows the size of the system being monitored to scale independently of the size of alerting rules. Ensuring that the cost of maintenance scales sublinearly with the size of the service is key to making monitoring maintainable.

Even though Borgmon remains internal to Google, the idea of treating time-series data as a data source for generating alerts is now accessible to everyone through open source tools like Prometheus, Riemann, Heka, and Bosun.
