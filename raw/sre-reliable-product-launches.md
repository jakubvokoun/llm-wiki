# Reliable Product Launches at Scale

Written by Rhandeev Singh and Sebastian Kirsch with Vivek Rau. Edited by Betsy Beyer.

Google defines a **launch** as any new code that introduces an externally visible change to an application. Google performs up to 70 launches per week. Site Reliability's role in this process is to enable a rapid pace of change without compromising site stability.

**Example:** On Christmas Eve 2011, the NORAD Tracks Santa website (using Google's satellite imagery) received 25× its normal peak traffic—over one million requests per second. All the characteristics of a difficult, risky launch: hard deadline (Santa can't come a week late), massive publicity, an audience of millions, and a very steep traffic ramp-up.

## Launch Coordination Engineering

Google created a dedicated consulting team within SRE: **Launch Coordination Engineers (LCEs)**. LCEs are software/systems engineers with strong communication and leadership skills. They:

- Audit products for compliance with Google's reliability standards and best practices
- Act as liaison between multiple teams involved in a launch
- Drive technical aspects of a launch
- Act as gatekeepers and sign off on launches determined to be "safe"
- Educate developers on best practices and how to integrate with Google's services

LCE team advantages:
- **Breadth of experience:** Active across almost all of Google's product areas; excellent vehicles for knowledge transfer
- **Cross-functional perspective:** Holistic view of the launch, coordinating SRE, development, product management across dozens of teams
- **Objectivity:** Nonpartisan advisor balancing SRE, product developers, product managers, and marketing

## Setting Up a Launch Process

Criteria for a good launch process:
- **Lightweight:** Easy on developers
- **Robust:** Catches obvious errors
- **Thorough:** Addresses important details consistently and reproducibly
- **Scalable:** Accommodates many simple launches and fewer complex ones
- **Adaptable:** Works for common types and new types of launches

These requirements conflict (especially lightweight vs. thorough). Tactics used to balance them:
- **Simplicity:** Get the basics right; don't plan for every eventuality
- **High touch approach:** Experienced engineers customize the process for each launch
- **Fast common paths:** Identify launch classes that always follow a common pattern (e.g., launching a product in a new country) and provide simplified processes for them

Engineers will sidestep processes they consider burdensome or of insufficient value—especially in crunch mode. LCE must continuously optimize the launch experience.

## The Launch Checklist

The launch checklist helps LCEs assess launches and provides action items. Example items:

- **New domain name?** → Coordinate with marketing; here's the form
- **Storing persistent data?** → Implement backups; here are instructions
- **Could users abuse the service?** → Implement rate limiting and quotas; use this shared service

**Checklist management guidelines:**
- Every question's importance must be substantiated, ideally by a previous launch disaster
- Every instruction must be concrete, practical, and reasonable for developers to accomplish
- Curate continuously; review the entire checklist once or twice a year

The checklist is a vehicle for **driving convergence on common infrastructure**: rather than implementing custom solutions, recommend existing hardened infrastructure. This radically simplified the checklist (e.g., long sections about rate limiting replaced with "Use system X").

## Developing a Launch Checklist: Themes

### Architecture and Dependencies

- What is the request flow from user to frontend to backend?
- Are there different request types with different latency requirements?
- Actions: Isolate user-facing from non-user-facing requests; validate request volume assumptions (one page view → many requests)

### Integration

- Set up DNS, load balancers, monitoring for the new service

### Capacity Planning

New features may exhibit launch spikes up to 15× initial estimates. Public interest is notoriously hard to predict.

- Is this launch tied to a press release or promotion?
- How much traffic do you expect during and after launch?
- Have you obtained all compute resources needed?
- Action: For N replicas to serve peak traffic, maintain N+1 or N+2 replicas for redundancy during maintenance and failures

### Failure Modes

Systematically examine each component and dependency:
- Single points of failure?
- How does the service handle dependency unavailability at startup and runtime?
- Actions: Implement request deadlines (avoid running out of resources); implement load shedding (reject requests early in overload situations)

### Client Behavior

Unlike traditional websites where request rates are limited by human click speed, clients initiating actions without user input (cell phone sync, periodic refresh) can threaten service stability with abusive behavior.

- Do you have auto-save/auto-complete/heartbeat functionality?
- Actions: Implement exponential backoff on failure; jitter automatic requests

### Processes and Automation

Minimize single points of failure, including human single points:
- Document all manual processes before launch while knowledge is fresh
- Document the process for moving to a new datacenter
- Automate build and release

### External Dependencies

Identify factors beyond company control:
- What third-party code, data, or services does the service depend on?
- What if the vendor has an outage or scalability limit?
- Actions: Use filtering/rewriting proxies, data transcoding pipelines, and caches to mitigate vendor risks

### Rollout Planning

Complicated launches may require enabling features on multiple subsystems, each taking hours. Having a working config in test doesn't guarantee it can be rolled out to production. Identify contingency measures (backup slide deck: "We will be launching this feature over the next days").

## Selected Techniques for Reliable Launches

### Gradual and Staged Rollouts

Very few Google launches are push-button. Almost all updates proceed gradually with verification steps:

1. Install on a few machines in one datacenter; observe for a defined period
2. If healthy, install on all machines in one datacenter; observe again
3. Install globally

The first stages are **"canaries"** (from miners' canary in coal mines to detect dangerous gases). Canary testing is embedded in many Google tools. If the canary doesn't pass validation, automatically roll back.

Even mobile app updates use gradual rollout: the updated version is offered to a subset of installs, gradually increasing to 100%. This allows detecting problems early as backend traffic increases.

### Feature Flag Frameworks

Mechanisms to roll out changes slowly, enabling observation of real-workload behavior before full rollout. Especially useful when realistic test environments are impractical.

Requirements for feature flag frameworks:
- Roll out many changes in parallel, each to a few servers/users/entities/datacenters
- Gradually increase to a larger but limited group (usually 1–10%)
- Direct traffic based on users, sessions, objects, and/or locations
- Automatically handle failure of new code paths without affecting users
- Independently revert each change immediately in the event of serious bugs
- Measure the extent to which each change improves user experience

Two classes of feature flag frameworks:
1. **UI improvement:** HTTP payload rewriter at frontend application servers, limited to a subset of cookies or HTTP request/response attributes
2. **Server-side and business logic changes:** Proxy or reroute requests to different servers

Having dormant functionality in clients makes aborting launches easier: simply switch the feature off, iterate, and release. Without this, you'd need to provide a new app version without the feature and update all users' phones.

### Dealing with Abusive Client Behavior

- **Update rate misjudgment:** A client syncing every 60 seconds vs. every 600 seconds causes 10× the load
- **Thundering herd:** A phone app set to download updates at 2 a.m. creates a barrage at exactly 2 a.m. every night—instead, randomize timing
- **Retry loops without backoff/jitter:** A brief request spike → retries after 1s, then 2s, then 4s, synchronized → repeated spikes amplify overload

**Server-side client control:** Instruct clients to periodically download a configuration file that enables/disables features and sets parameters (sync frequency, retry rates). This also enables completely new user-facing functionality without maintaining parallel release tracks.

### Overload Behavior and Load Tests

Services rarely scale linearly with load. Many services are slower when unloaded (cold caches, JIT caches). As load increases, there's usually a linear window, then a point of nonlinearity:
- **Benign case:** Response times increase (degraded user experience)
- **Drastic case:** Service locks up completely

Example: A service logged debugging information in response to backend errors. Logging was more expensive than handling a normal backend response. As the service became overloaded, it spent increasing CPU time logging errors, timing out more requests in a death spiral until grinding to a halt. (Similar: Java GC thrashing.)

**Load tests are required for most launches.** They enable:
- Understanding failure modes and breaking points
- Capacity planning
- Regression testing against previous performance baselines

## Evolution and Problems LCE Didn't Solve

LCE was staffed full-time in 2004. Over 3.5 years, the team averaged 5 engineers and ran ~1,500 launches through the LCE checklist. By 2009, launching a small new service at Google had become notoriously difficult.

Problems LCE couldn't solve:
- **Scalability changes:** When usage increases by 2 orders of magnitude, products need complete rearchitecting, slowing feature development during migration
- **Growing operational load:** Noisiness of automated notifications, complexity of deployment procedures, and overhead of manual maintenance tend to increase over time; SRE goal is to keep operational work below 50% of time
- **Infrastructure churn:** Underlying infrastructure (cluster management, storage, monitoring, load balancing) changes due to active infrastructure team development; service owners must constantly modify configurations—"running fast just to stay in the same place." Solution: prohibit infrastructure engineers from releasing backward-incompatible features until they automate migration of their clients

## Conclusion

Companies undergoing rapid growth with a high rate of change may benefit from a Launch Coordination Engineering equivalent. Especially valuable if:
- Product developers double every 1–2 years
- Services must scale to hundreds of millions of users
- Reliability despite high rate of change is important to users

The LCE team was Google's solution to achieving safety without impeding change.
