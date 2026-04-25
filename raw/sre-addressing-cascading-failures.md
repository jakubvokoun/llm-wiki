# Addressing Cascading Failures

Written by Mike Ulrich.

> If at first you don't succeed, back off exponentially.
> — Dan Sandler, Google Software Engineer

> Why do people always forget that you need to add a little jitter?
> — Ade Oshineye, Google Developer Advocate

A cascading failure is a failure that grows over time as a result of positive feedback. It can occur when a portion of an overall system fails, increasing the probability that other portions of the system fail. For example, a single replica for a service can fail due to overload, increasing load on remaining replicas and increasing their probability of failing, causing a domino effect that takes down all the replicas for a service.

## Causes of Cascading Failures and Designing to Avoid Them

### Server Overload

The most common cause of cascading failures is overload. If cluster B fails, requests to cluster A increase beyond its capacity, causing servers to run out of resources, crash, miss deadlines, or otherwise misbehave. This reduction in the rate of useful work being done can spread into other failure domains globally. The load balancer and task scheduling systems may act very quickly (on the order of a couple minutes), so this propagation can be fast.

### Resource Exhaustion

Running out of a resource results in higher latency, elevated error rates, or the substitution of lower-quality results. Different resources cause different failure modes:

**CPU exhaustion:**
- Increased number of in-flight requests (requests take longer, more concurrent)
- Excessively long queue lengths (increased latency and memory usage)
- Thread starvation (health checks fail)
- CPU or request starvation (internal watchdogs kill the server)
- Missed RPC deadlines (clients retry, causing more overload)
- Reduced CPU caching benefits (spilling onto more cores)

**Memory exhaustion:**
- Dying tasks (evicted by container manager)
- GC death spiral in Java (less CPU → slower requests → more RAM used → more GC → even less CPU)
- Reduction in cache hit rates (more RPCs to backends)

**Thread starvation:** Can directly cause errors or health check failures. Thread overhead can use too much RAM.

**File descriptor exhaustion:** Inability to initialize network connections, causing health checks to fail.

Note that many resource exhaustion scenarios feed from one another—a service experiencing overload often has a host of secondary symptoms that can look like the root cause, making debugging difficult.

### Service Unavailability

Resource exhaustion can lead to servers crashing. Once a few servers crash on overload, the load on remaining servers increases, causing them to crash as well. The problem snowballs until all servers are crash-looping. It's often difficult to escape this scenario because servers that come back online are immediately bombarded with high request rates and fail almost immediately.

If a service was healthy at 10,000 QPS but started a cascading failure at 11,000 QPS, dropping load to 9,000 QPS will almost certainly not stop the crashes. The service handles increased demand with reduced capacity—only a small fraction of servers will be healthy enough to handle requests.

## Preventing Server Overload

Strategies in rough priority order:

1. **Load test the server's capacity limits, and test the failure mode for overload** — Most important exercise to prevent server overload. Without realistic testing, it's very hard to predict which resource will be exhausted.

2. **Serve degraded results** — Serve lower-quality, cheaper-to-compute results to the user.

3. **Instrument the server to reject requests when overloaded** — Servers should protect themselves. When overloaded, fail early and cheaply.

4. **Instrument higher-level systems to reject requests** — Rate limiting can be implemented:
   - At reverse proxies (mitigate DoS/abusive clients)
   - At load balancers (drop requests during global overload)
   - At individual tasks (prevent random load balancing fluctuations)

5. **Perform capacity planning** — Coupled with performance testing to determine load at which the service fails. If each cluster's breaking point is 5,000 QPS and peak load is 19,000 QPS, approximately six clusters are needed for N+2 redundancy.

## Queue Management

Most thread-per-request servers use a queue in front of a thread pool. If the queue is full, the server rejects new requests.

Queued requests consume memory and increase latency. If queue size is 10x the thread pool size and request handling takes 100ms, a full-queue request waits 1.1 seconds.

For steady traffic, it's usually better to have small queue lengths (≤50% of thread pool size), which results in the server rejecting requests early when it can't sustain the rate. For bursty load, a larger queue sized based on current threads, processing time, and burst size may work better.

Changing queuing from FIFO to LIFO or using the CoDel (Controlled Delay) algorithm can reduce load by removing requests unlikely to be worth processing. If a user's search is slow because an RPC has been queued for 10 seconds, there's a good chance the user has already refreshed their browser—no point responding to the first request.

## Load Shedding and Graceful Degradation

**Load shedding** drops some proportion of load by dropping traffic as the server approaches overload conditions, keeping the server from running out of RAM, failing health checks, or serving with extremely high latency.

One straightforward approach: return HTTP 503 when there are more than a given number of in-flight requests.

**Graceful degradation** takes load shedding further by reducing the amount of work that needs to be performed. A search application might only search an in-memory cache subset rather than the full on-disk database, or use a less-accurate but faster ranking algorithm when overloaded.

Key considerations:
- Graceful degradation shouldn't trigger very often. Keep it simple and understandable.
- The code path you never use is the code path that often doesn't work. Regularly run a small subset of servers near overload to exercise this code path.
- Monitor and alert when too many servers enter these modes.
- Design a way to quickly disable complex graceful degradation if it causes problems itself.

## Retries

Naive retry logic can destabilize a system:

1. Backend has a known limit of 10,000 QPS, after which requests are rejected.
2. Frontend calls at 10,100 QPS—100 QPS are rejected.
3. Those 100 failed QPS are retried, adding to load. Backend now receives 10,200 QPS.
4. Volume of retries grows: 100 → 200 → 300 QPS of retries, fewer requests succeed.
5. Backend melts down under load of requests plus retries, crashes, redistributes to remaining backends.

This pattern has contributed to several cascading failures, whether via RPC, client JavaScript XmlHttpRequest, or offline sync protocols.

Retry guidelines:
- **Always use randomized exponential backoff** when scheduling retries. Without randomization, a small network blip can cause retry ripples to schedule simultaneously.
- **Limit retries per request.** Don't retry indefinitely.
- **Consider a server-wide retry budget.** For example, only allow 60 retries per minute—if exceeded, fail the request. The difference between a capacity planning failure with some dropped queries vs. a global cascading failure.
- **Avoid amplifying retries at multiple levels.** A single user action can create 4^3 = 64 attempts on the database if frontend, backend, and JavaScript each retry 3 times.
- **Use clear response codes.** Separate retriable vs. non-retriable errors. Don't retry permanent errors or overload indicators that signal to back off.

## Latency and Deadlines

### Picking a Deadline

Setting either no deadline or an extremely high deadline may cause short-term problems to consume server resources until the server restarts. High deadlines cause resource consumption in higher stack levels when lower levels have problems. Short deadlines cause expensive requests to fail consistently.

### Missing Deadlines

A common theme in many cascading outages: servers spend resources handling requests that will exceed their deadlines on the client. As a result, resources are spent while no progress is made. If a request sits on a queue for 11 seconds against a 10-second deadline, the client has already given up—the server should not attempt to handle it.

Servers should check the deadline left at each processing stage before attempting more work on the request.

### Deadline Propagation

With **deadline propagation**, a deadline is set high in the stack (e.g., in the frontend). The tree of RPCs emanating from an initial request will all have the same absolute deadline. If server A selects a 30-second deadline and processes for 7 seconds before sending an RPC to server B, the RPC will have a 23-second deadline. Each server in the request tree implements deadline propagation.

Without deadline propagation, a server deep in the stack may process a request thinking it has 15 seconds to spare, while the top-level deadline was already exceeded.

Consider reducing outgoing deadlines slightly (a few hundred ms) to account for network transit and post-processing.

### Cancellation Propagation

Propagating cancellations reduces unneeded work by advising servers in an RPC call stack that their efforts are no longer necessary. Used with "hedged requests"—once the client receives a response from any server, it sends cancellations to others. Cancellations should propagate throughout the entire stack to prevent leakage from long-deadline initial calls.

### Bimodal Latency

If 5% of requests never complete and the deadline is 100 seconds, those requests consume many threads continuously, potentially causing the frontend to only handle 19.6% of requests—resulting in an 80.4% error rate despite only 5% of requests being inherently unfulfillable.

Guidelines:
- Look at the distribution of latencies, not just mean latency.
- Return errors early for unavailable backends rather than consuming resources until the deadline.
- Avoid deadlines several orders of magnitude larger than mean request latency.
- For shared resources that can be exhausted by one keyspace, consider limiting in-flight requests per client (e.g., no more than 25% of threads per client).

## Slow Startup and Cold Caching

Processes are often slower immediately after starting due to:
- Required initialization (setting up connections on first request)
- Runtime performance improvements in some languages (JIT compilation, hotspot optimization, deferred class loading in Java)

Scenarios causing cold cache:
- Turning up a new cluster
- Returning a cluster to service after maintenance
- Restarts

Strategies:
- Overprovision the service to handle expected load with an empty cache.
- Distinguish between **latency caches** (service survives expected load without cache) vs. **capacity caches** (service cannot survive expected load without cache). Be vigilant about which type caches are.
- Slowly increase load when adding load to a cluster—initial small request rate warms the cache.
- Keep all clusters carrying nominal load so caches stay warm.

## Always Go Downward in the Stack

Avoid intra-layer communication (cycles in the communication path) in the user request path. Problems:
- Susceptible to distributed deadlock (backends waiting on each other's thread pools)
- Intra-layer communication can increase under high load conditions, amplifying the problem
- Bootstrapping the system becomes more complex

Instead of a backend proxying to another backend when it guesses wrong, it should tell the frontend to retry on the correct backend.

## Triggering Conditions for Cascading Failures

- **Process Death:** Tasks dying due to Query of Death, cluster issues, assertion failures.
- **Process Updates:** Pushing new binary/config simultaneously affects many tasks.
- **New Rollouts:** Changed request profiles, resource usage, backends can trigger cascades.
- **Organic Growth:** Usage growth not accompanied by capacity adjustment.
- **Planned Changes, Drains, or Turndowns:** Maintenance in one cluster, drained dependencies.
- **Request Profile Changes:** Frontend shifts traffic due to load balancing config changes or changed payload size.
- **Resource Limits:** Cluster overcommitment slack CPU can suddenly disappear (e.g., a MapReduce job starts on many machines).

## Testing for Cascading Failures

### Test Until Failure and Beyond

Load test components until they break. A better-designed component rejects some requests and survives; a highly susceptible component crashes or serves very high error rates when overloaded.

Load testing also reveals the breaking point for capacity planning: enables regression testing, worst-case threshold provisioning, and utilization vs. safety margin trade-offs.

Test both gradual ramp-up and impulse load patterns (cold vs. warm cache effects). After pushing well beyond nominal load, test whether the component can exit degraded mode without human intervention, and how much load needs to drop for the system to stabilize.

Consider production failure tests in a small slice of real traffic:
- Reducing task counts quickly or slowly
- Rapidly losing a cluster's worth of capacity
- Blackholing various backends

### Test Popular Clients

Understand how large clients behave:
- Can they queue work while the service is down?
- Do they use randomized exponential backoff on errors?
- Are they vulnerable to external triggers creating large load (e.g., software updates clearing caches)?

### Test Noncritical Backends

Make sure unavailability of noncritical backends doesn't interfere with critical components. Test also when noncritical backends blackhole (never respond)—the frontend should not start rejecting requests, running out of resources, or serving with very high latency.

## Immediate Steps to Address Cascading Failures

1. **Increase Resources** — If running at degraded capacity and idle resources exist, adding tasks can be the most expedient fix. Won't work if the service is in a death spiral.

2. **Stop Health Check Failures/Deaths** — If health-checking itself makes the service unhealthy (killing servers that are overloaded, preventing recovery), temporarily disable health checks to permit stabilization. Distinguish process health checks (cluster scheduler) from service health checks (load balancer).

3. **Restart Servers** — If servers are wedged (GC death spiral, threadlocked, unbounded in-flight requests). Identify the source first; canary the change slowly. Restarting may amplify a cold-cache cascading failure.

4. **Drop Traffic** — Big hammer, reserved for true cascading failure when other means fail:
   1. Address the initial triggering condition (add capacity)
   2. Reduce load aggressively (allow only 1% of traffic through if crash-looping)
   3. Allow majority of servers to become healthy
   4. Gradually ramp up load
   - Fix the root cause before using this strategy—the cascading failure may re-trigger immediately after traffic returns.

5. **Enter Degraded Modes** — Serve degraded results; requires engineering into the service in advance.

6. **Eliminate Batch Load** — Turn off non-critical background operations (index updates, data copies, statistics gathering) during an outage.

7. **Eliminate Bad Traffic** — Block queries of death or other heavy/crashing queries.

## Closing Remarks

Without proper care, changes meant to improve steady state can expose services to greater risk of full outages: retrying on failures, shifting load from unhealthy servers, killing unhealthy servers, adding caches—all can improve the normal case but increase the chance of large-scale failure. Understand your system's breaking points and how it behaves beyond them.
