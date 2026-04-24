---
title: "Service Reliability Hierarchy"
tags: [sre, reliability, hierarchy, monitoring, incident-response, google]
sources: [sre-book-part-iii-practices.md]
updated: 2026-04-24
---

# Service Reliability Hierarchy

A framework for understanding the elements that go into making a service reliable, from most basic to most advanced. Modeled on Abraham Maslow's Hierarchy of Needs. Developed by Google SREs including Mikey Dickerson while helping rescue healthcare.gov in 2013-2014.

## The Hierarchy

```
         ┌─────────────────────────┐
         │         Product         │   Reliable launches; user experience
         ├─────────────────────────┤
         │       Development       │   Consensus, cron, pipelines, data integrity
         ├─────────────────────────┤
         │    Capacity Planning    │   Forecasting, load balancing, overload handling
         ├─────────────────────────┤
         │         Testing         │   Prevent known failure classes before production
         ├─────────────────────────┤
         │   Postmortem / RCA      │   Blameless culture, outage tracking, learning
         ├─────────────────────────┤
         │    Incident Response    │   On-call, troubleshooting, emergency response
         ├─────────────────────────┤
         │       Monitoring        │   Know the service is working; alert before users notice
         └─────────────────────────┘
```

## Key Principle

**Each layer depends on the layers below it being solid.** You cannot have:

- Reliable product launches without reliable capacity planning
- Effective capacity planning without good testing
- Useful postmortems without good monitoring
- Effective incident response without good monitoring and postmortems

Trying to skip levels is a common failure mode — teams try to do product launches before their monitoring is solid.

## The Layers

### Monitoring (Bottom)

The foundational layer. Without it, you're flying blind. Monitoring enables:

- Knowing whether the service works at all
- Alerting before users notice problems
- Data for all higher-level decisions

See: [Observability](observability.md), [Four Golden Signals](four-golden-signals.md), [Borgmon](borgmon.md)

### Incident Response

On-call support is a tool to achieve the larger mission, not an end in itself. Effective incident response includes:

- Effective triage (stop the bleeding first)
- Structured troubleshooting
- Managing incidents to minimize impact

See: [Incident Response](incident-response.md), [Troubleshooting](troubleshooting.md)

### Postmortem / Root-Cause Analysis

Don't repeatedly fix the same issue. A blameless postmortem culture is the first step in understanding what went wrong. Outage tracking enables learning across the organization.

See: [Site Reliability Engineering](site-reliability-engineering.md)

### Testing

An ounce of prevention is worth a pound of cure. Test suites prevent known failure classes from reaching production.

### Capacity Planning

Demand forecasting (organic and inorganic), load balancing, overload handling, cascading failure prevention. Auxon (Google's capacity planning tool) is an example.

### Development

Large-scale system design that SREs own:

- Distributed consensus (Paxos) as foundation for reliable state
- Distributed cron for periodic work
- Data processing pipelines
- Data integrity

### Product (Top)

The top of the hierarchy — reliable product launches. Getting here means all lower layers are solid enough to confidently give users a good experience from Day Zero.

## Historical Context

The hierarchy was explicitly articulated when Mikey Dickerson and colleagues from Google SRE temporarily joined the US government to help with the healthcare.gov launch (late 2013 - early 2014). The failing site needed a systematic approach to increasing reliability, and the hierarchy provided the framework.

Mikey Dickerson later became the first administrator of the US Digital Service, an agency to bring SRE principles and practices to US government IT systems.

## Related Pages

- [Site Reliability Engineering](site-reliability-engineering.md)
- [Observability](observability.md)
- [Incident Response](incident-response.md)
- [Troubleshooting](troubleshooting.md)
- [SRE Book Part III Practices](../sources/sre-book-part-iii-practices.md)
