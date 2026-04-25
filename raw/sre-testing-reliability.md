# Testing for Reliability

Written by Alex Perry and Max Luebbe
Edited by Diane Bates

> If you haven't tried it, assume it's broken.
>
> Unknown

One key responsibility of Site Reliability Engineers is to quantify confidence in the systems they maintain. SREs perform this task by adapting classical software testing techniques to systems at scale. Confidence can be measured both by past reliability and future reliability. The former is captured by analyzing data provided by monitoring historic system behavior, while the latter is quantified by making predictions from data about past system behavior.

Testing is the mechanism you use to demonstrate specific areas of equivalence when changes occur. Each test that passes both before and after a change reduces the uncertainty for which the analysis needs to allow. Thorough testing helps us predict the future reliability of a given site with enough detail to be practically useful.

The amount of testing you need to conduct depends on the reliability requirements for your system. As the percentage of your codebase covered by tests increases, you reduce uncertainty and the potential decrease in reliability from each change.

### Relationships Between Testing and Mean Time to Repair

Passing a test or a series of tests doesn't necessarily prove reliability. However, tests that are failing generally prove the *absence* of reliability.

A monitoring system can uncover bugs, but only as quickly as the reporting pipeline can react. The *Mean Time to Repair* (MTTR) measures how long it takes the operations team to fix the bug, either through a rollback or another action.

It's possible for a testing system to identify a bug with zero MTTR. Zero MTTR occurs when a system-level test is applied to a subsystem, and that test detects the exact same problem that monitoring would detect. Such a test enables the push to be blocked so the bug never reaches production. Repairing zero MTTR bugs by blocking a push is both quick and convenient. The more bugs you can find with zero MTTR, the higher the *Mean Time Between Failures* (MTBF) experienced by your users.

## Types of Software Testing

Software tests broadly fall into two categories: traditional and production. Traditional tests are more common in software development to evaluate the correctness of software offline, during development. Production tests are performed on a live web service to evaluate whether a deployed software system is working correctly.

## Traditional Tests

Traditional software testing begins with unit tests. Testing of more complex functionality is layered atop unit tests.

### Unit tests

A *unit test* is the smallest and simplest form of software testing. These tests are employed to assess a separable unit of software, such as a class or function, for correctness independent of the larger software system that contains the unit. Unit tests are also employed as a form of specification to ensure that a function or module exactly performs the behavior required by the system.

### Integration tests

Software components that pass individual unit tests are assembled into larger components. Engineers then run an *integration test* on an assembled component to verify that it functions correctly. Dependency injection is an extremely powerful technique for creating mocks of complex dependencies so that an engineer can cleanly test a component.

### System tests

A *system test* is the largest scale test that engineers run for an undeployed system. All modules belonging to a specific component are assembled into the system, and then the engineer tests the end-to-end functionality. System tests come in many different flavors:

**Smoke tests:** Engineers test very simple but critical behavior. Smoke tests are also known as *sanity testing*, and serve to short-circuit additional and more expensive testing.

**Performance tests:** Ensure that the performance of the system stays acceptable over the duration of its lifecycle. A performance test ensures that over time, a system doesn't degrade or become too expensive.

**Regression tests:** Prevent bugs from sneaking back into the codebase. By documenting historical bugs as tests at the system or integration level, engineers refactoring the codebase can be sure that they don't accidentally reintroduce them.

## Production Tests

Production tests interact with a live production system. These tests are in many ways similar to black-box monitoring, and are therefore sometimes called *black-box testing*. Production tests are essential to running a reliable production service.

### Configuration test

At Google, web service configurations are described in files stored in version control. For each configuration file, a separate *configuration test* examines production to see how a particular binary is actually configured and reports discrepancies against that file. Such tests are inherently not hermetic, as they operate outside the test infrastructure sandbox.

Configuration tests are built and tested for a specific version of the checked-in configuration file. Comparing which version of the test is passing in relation to the goal version for automation implicitly indicates how far actual production currently lags behind ongoing engineering work.

Configuration tests can be very simple when the production deployment uses the actual file content and offers a real-time query to retrieve a copy of the content. In this case, the test code simply issues that query and diffs the response against the file.

### Stress test

In order to safely operate a system, SREs need to understand the limits of both the system and its components. Engineers use *stress tests* to find the limits on a web service:

* How full can a database get before writes start to fail?
* How many queries a second can be sent to an application server before it becomes overloaded?

### Canary test

To conduct a canary test, a subset of servers is upgraded to a new version or configuration and then left in an incubation period. Should no unexpected variances occur, the release continues and the rest of the servers are upgraded in a progressive fashion. Should anything go awry, the modified servers can be quickly reverted to a known good state. We commonly refer to the incubation period for the upgraded servers as "baking the binary."

A canary test isn't really a test; rather, it's structured user acceptance. It only exposes the code under test to less predictable live production traffic, and thus, it isn't perfect and doesn't always catch newly introduced faults.

## Creating a Test and Build Environment

When entering a project with low or nonexistent test coverage, start by asking:

* Can you prioritize the codebase? Stack-rank the components of the system by any measure of importance.
* Are there particular functions or classes that are absolutely mission-critical or business-critical?
* Which APIs are other teams integrating against?

Shipping software that is obviously broken is among the most cardinal sins of a developer. It takes little effort to create a series of smoke tests to run for every release—a low-effort, high-impact first step.

One way to establish a strong testing culture is to start documenting all reported bugs as test cases. If every bug is converted into a test, each test is supposed to initially fail because the bug hasn't yet been fixed. As engineers fix the bugs, the software passes testing and you're on the road to developing a comprehensive regression test suite.

Once source control is in place, add a continuous build system that builds the software and runs tests every time code is submitted. It's essential that the latest version of a software project in source control is working completely. When the build system notifies engineers about broken code, they should drop all of their other tasks and prioritize fixing the problem:

* It's usually harder to fix what's broken if there are changes to the codebase after the defect is introduced.
* Broken software slows down the team.
* Release cadences lose their value.
* The ability to respond to emergency releases becomes much more complex.

When the build is predictably solid and reliable, developers can iterate faster—stability drives agility.

## Testing at Scale

### Testing Scalable Tools

SRE-developed tools that need testing include those that:

* Retrieve and propagate database performance metrics
* Predict usage metrics to plan for capacity risks
* Refactor data within a service replica
* Change files on a server

SRE tools share two characteristics:
* Their side effects remain within the tested mainstream API
* They're isolated from user-facing production by an existing validation and release barrier

**Automation tools** (database index selection, load balancing between datacenters, shuffling relay logs) also need testing. They share two characteristics:
* The actual operation is against a robust, predictable, and well-tested API
* The purpose is a side effect that is an invisible discontinuity to another API client

### Testing Disaster

Many disaster recovery tools can be carefully designed to operate *offline*:

* Compute a *checkpoint* state that is equivalent to cleanly stopping the service
* Push the checkpoint state to be *loadable* by existing nondisaster validation tools
* Support the usual release *barrier* tools, which trigger the *clean start* procedure

Online repair tools inherently operate outside the mainstream API and are more interesting to test. One challenge in a distributed system is determining if normal behavior (which may be eventually consistent) will interact badly with the repair.

**Statistical testing techniques** (fuzzing, Chaos Monkey, Jepsen) aren't necessarily repeatable tests. They can provide a log of all randomly selected actions, help pinpoint suspicious areas in code, and sometimes demonstrate failure situations more severe than the original run.

### The Need for Speed

For every version in the code repository, every defined test provides a pass or fail indication. You must form hypotheses about the many scenarios of interest and run the appropriate number of repeats of each test to allow a reasonable inference.

For a service with over 21,000 simple tests, to reliably not incorrectly flag a user's patch as damaging, individual tests must run correctly over 99.9999% of the time.

Most tests are simple, self-contained hermetic binaries running for a few seconds that give engineers interactive feedback. Tests that require orchestration across many binaries tend to be classified as batch tests and can't offer interactive feedback. Test results are best given to engineers before context switching occurs.

### Pushing to Production

In the SRE model, segregating testing infrastructure from production configuration prevents relating the model describing production to the model describing the application behavior. This segregation also limits project velocity because of commit races between the versioning systems.

Consider a scenario of unified versioning and unified testing: the ability of the SRE methodology to apply becomes possible, and migration risk can be eliminated.

### Expect Testing to Fail

Effective API/ABI management tools and interpreted languages now support building and executing a new software version every few minutes. Using intermediates (testing many versions between annual releases), you can unambiguously map problems found during testing back to their underlying causes.

If you let users try more versions of the software during the year, the MTBF suffers because there are more opportunities for user-visible breakage. However, you can also discover areas that would benefit from additional test coverage.

Careful reliability management combines the limits on uncertainty due to test coverage with the limits on user-visible faults in order to adjust the release cadence. This combination maximizes the knowledge that you gain from operations and end users.

### Integration

In addition to unit testing a configuration file to mitigate its risk to reliability, it's also important to consider integration testing configuration files. Writing configuration files in an interpreted language is risky—loading content actually consists of executing a program, with no inherent upper limit on how inefficient loading can be.

The benefit of using protocol buffers is that the schema is defined in advance and automatically checked at load time, removing much of the toil while offering bounded runtime.

### Production Probes

Known good requests should work; known bad requests should error. Implementing both kinds of coverage as an integration test is generally a good idea. Splitting known good requests into those that can be replayed against production and those that can't yields three sets:

* Known bad requests
* Known good requests that can be replayed against production
* Known good requests that can't be replayed against production

Each set can be used as both integration and release tests, and most can also be used as monitoring probes.

The monitoring probe running in production is a configuration that wasn't previously tested (because frontends and backends have independent release cycles). Therefore, production probes provide genuine additional coverage beyond release tests.

Those probes should never fail. If they do fail, it means either the frontend API or backend API is not equivalent between the production and release environments.

## Conclusion

Testing is one of the most profitable investments engineers can make to improve the reliability of their product. Testing isn't an activity that happens once or twice in the lifecycle of a project; it's continuous. The methodologies and techniques in this chapter provide a solid foundation for measuring faults and uncertainty in a software system, and help engineers reason about the reliability of software as it's written and released to users.
