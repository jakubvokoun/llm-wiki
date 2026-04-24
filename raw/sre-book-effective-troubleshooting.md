# Chapter 12 — Effective Troubleshooting

Written by Chris Jones

> Be warned that being an expert is more than understanding how a system is supposed to work. Expertise is gained by investigating why a system doesn't work.
>
> Brian Redman

> Ways in which things go right are special cases of the ways in which things go wrong.
>
> John Allspaw

Troubleshooting is a critical skill for anyone who operates distributed computing systems—especially SREs—but it's often viewed as an innate skill that some people have and others don't. However, troubleshooting is *both* learnable and teachable.

Novices are often tripped up when troubleshooting because the exercise ideally depends upon two factors: an understanding of how to troubleshoot generically (i.e., without any particular system knowledge) and a solid knowledge of the system.

## Theory

Formally, we can think of the troubleshooting process as an application of the hypothetico-deductive method: given a set of observations about a system and a theoretical basis for understanding system behavior, we iteratively hypothesize potential causes for the failure and try to test those hypotheses.

In an idealized model, we'd start with a problem report telling us that something is wrong with the system. Then we can look at the system's telemetry and logs to understand its current state. This information, combined with our knowledge of how the system is built, how it should operate, and its failure modes, enables us to identify some possible causes.

We can then test our hypotheses in one of two ways:

1. Compare the observed state of the system against our theories to find confirming or disconfirming evidence.
2. Actively "treat" the system—change the system in a controlled way—and observe the results.

### Common Pitfalls

Ineffective troubleshooting sessions are plagued by problems at the Triage, Examine, and Diagnose steps:

- Looking at symptoms that aren't relevant or misunderstanding the meaning of system metrics → wild goose chases
- Misunderstanding how to change the system safely and effectively to test hypotheses
- Coming up with wildly improbable theories or latching on to causes of past problems ("it happened once, it must be happening again")
- Hunting down spurious correlations that are actually coincidences or correlated with shared causes

Key principles:
- Not all failures are equally probable: "when you hear hoofbeats, think of horses not zebras"
- Prefer simpler explanations (Occam's Razor)
- Correlation is not causation

## In Practice

### Problem Report

Every problem starts with a problem report, which might be an automated alert or a colleague saying "The system is slow." An effective report should tell you:

- The *expected* behavior
- The *actual* behavior
- How to reproduce the behavior (if possible)

It's common practice at Google to open a bug for every issue, even those received via email or instant messaging. Doing so creates a log of investigation and remediation activities. Many teams discourage reporting problems directly to a person: this introduces an additional transcription step, produces lower-quality reports not visible to the whole team, and concentrates load on a handful of team members.

### Triage

Once you receive a problem report, figure out what to do about it based on its severity. Your first response in a major outage may be to start troubleshooting and try to find a root cause as quickly as possible. **Ignore that instinct!**

Instead, your course of action should be to *make the system work as well as it can under the circumstances*. This may entail:

- Diverting traffic from a broken cluster to others that are still working
- Dropping traffic wholesale to prevent a cascading failure
- Disabling subsystems to lighten the load

Stopping the bleeding should be your first priority. Novice pilots are taught that their first responsibility in an emergency is to fly the airplane; troubleshooting is secondary to getting the plane and everyone on it safely onto the ground.

### Examine

We need to be able to examine what each component in the system is doing in order to understand whether or not it's behaving correctly.

**Metrics**: A monitoring system recording metrics is a good place to start. Graphing time-series can be an effective way to understand the behavior of specific pieces of a system and find correlations.

**Logging**: Exporting information about each operation and about system state makes it possible to understand exactly what a process was doing at a given point in time. It's really useful to have:

- Multiple verbosity levels available, with a way to increase these levels on the fly
- Statistical sampling for high-traffic services
- A selection language to filter operations matching specific criteria

**Tracing**: Tracing requests through the whole stack using tools such as Dapper provides a very powerful way to understand how a distributed system is working.

**Exposing current state**: Google servers have endpoints that show a sample of RPCs recently sent or received, histograms of error rates and latency for each type of RPC, and even their current configuration.

### Diagnose

#### Simplify and Reduce

Ideally, components in a system have well-defined interfaces and perform known transformations from their input to their output. Look at the connections *between* components—or the data flowing between them—to determine whether a given component is working properly.

Dividing and conquering is a very useful general-purpose solution technique. In a multilayer system, it's often best to start systematically from one end of the stack and work toward the other end. An alternative, *bisection*, splits the system in half and examines communication paths between components on one side and the other.

#### Ask "What," "Where," and "Why"

A malfunctioning system is often still trying to do *something*—just not the thing you want it to be doing. Finding out *what* it's doing, then asking *why* it's doing that and *where* its resources are being used can help you understand how things have gone wrong.

**Example**: A Spanner cluster had high latency.
- **Why?** Tasks were using all their CPU time.
- **Where** in the server? Sorting entries in logs checkpointed to disk.
- **Where** in the log-sorting code? Evaluating a regular expression against paths to log files.
- **Solution**: Rewrite the regular expression to avoid backtracking; consider using RE2.

#### What Touched It Last

Systems have inertia: a working computer system tends to remain in motion until acted upon by an external force, such as a configuration change or a shift in the type of load served. Recent changes to a system can be a productive place to start identifying what's gone wrong.

Well-designed systems should have extensive production logging to track new version deployments and configuration changes. Correlating changes in a system's performance and behavior with other events can be helpful—for example, annotating a graph showing error rates with the start and end times of a deployment.

### Test and Treat

Once you've come up with a short list of possible causes, use the experimental method to find which factor is at the root of the actual problem. Considerations:

- An ideal test should have mutually exclusive alternatives so that it can rule one group of hypotheses in and another set out
- Consider the obvious first: perform tests in decreasing order of likelihood
- An experiment may provide misleading results due to confounding factors
- Active tests may have side effects that change future test results
- Some tests may not be definitive, only suggestive

**Take clear notes** of what ideas you had, which tests you ran, and the results you saw. If you performed active testing by changing a system, making changes in a systematic and documented fashion will help you return the system to its pre-test setup.

## Negative Results Are Magic

A "negative" result is an experimental outcome in which the expected effect is absent. **Negative results should not be ignored or discounted.** Realizing you're wrong has much value:

- **Experiments with negative results are conclusive.** They tell us something certain about production, or the design space, or the performance limits of an existing system.
- **Tools and methods can outlive the experiment.** Benchmarking tools and load generators can result just as easily from a disconfirming experiment as a supporting one.
- **Publishing negative results improves our industry's data-driven culture.** It reduces bias in our metrics and encourages others to do the same.
- **Publish your results.** If you are interested in an experiment's results, there's a good chance that other people are as well.

Be skeptical of any design document, performance review, or essay that doesn't mention failure.

## Cure

Ideally, you've narrowed the set of possible causes to one. Definitively proving that a given factor *caused* a problem—by reproducing it at will—can be difficult to do in production systems because:

- Systems are complex; multiple factors may be required jointly
- Systems are often path-dependent; they must be in a specific state before a failure occurs
- Reproducing the problem in a live production system may not be an option

Once you've found the factors that caused the problem, write up notes: what went wrong, how you tracked it down, how you fixed it, and how to prevent it from happening again (i.e., a postmortem).

## Case Study: App Engine Latency Mystery

An App Engine customer experienced a dramatic increase in latency, CPU usage, and number of running processes. The investigation:

1. Ruled out traffic increase (spike had normalized)
2. Ruled out code/config changes (happened on Saturday with no pushes)
3. Ruled out infrastructure-wide issues (only this app was affected)
4. Found suspicious correlation with `merge_join` datastore API calls (suboptimal indexing hypothesis)
5. Used distributed tracing (Dapper) to trace individual HTTP requests
6. Discovered static content was also slow—disproved the merge_join hypothesis
7. Found a 250ms gap before any RPC calls were made (app doing something internally)
8. Mitigated by upgrading to more CPU-rich instance type for the scheduled launch
9. **Root cause** (found later): A bug in access control caused an automated security scanner to create thousands of whitelist objects in the datastore. Every request then had to check all these objects, causing pathological slowness with no RPC calls visible.

Key lessons:
- Spurious correlations can lead investigations astray
- Sometimes mitigation before full diagnosis is the right call
- Unexpected changes in data volume (not code) can cause sudden performance degradation

## Making Troubleshooting Easier

Perhaps the most fundamental practices:

- Building observability—with both white-box metrics and structured logs—into each component from the ground up
- Designing systems with well-understood and observable interfaces between components

Ensuring that information is available in a consistent way throughout a system—for instance, using a unique request identifier throughout the span of RPCs generated by various components—reduces the need to figure out which log entry on an upstream component matches a log entry on a downstream component.

Problems in correctly representing the state of reality in a code change or an environment change often lead to a need to troubleshoot. Simplifying, controlling, and logging such changes can reduce the need for troubleshooting, and make it easier when it happens.
