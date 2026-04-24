---
title: "Prometheus Consoles and Dashboards Best Practices"
tags: [prometheus, monitoring, dashboards, observability]
sources: [prometheus-consoles.md]
updated: 2026-04-24
---

# Prometheus Consoles and Dashboards Best Practices

Official Prometheus guidance on dashboard design philosophy. As of Prometheus 3.0, console templates and libraries are no longer bundled — teams must provide their own via `--web.console.templates` and `--web.console.libraries` flags. This page documents the design principles.

## Design Philosophy

Resist the urge to display everything. Effective dashboards focus on distinguishing between **likely failure modes**, not raw data completeness.

For online-serving systems: structure dashboards around the service hierarchy — each service shows latency and errors for its dependencies. Operators start at the top and drill down.

## Recommended Constraints

| Element            | Limit                       |
| ------------------ | --------------------------- |
| Graphs per console | ≤ 5                         |
| Lines per graph    | ≤ 5 (stacked/area: more OK) |
| Side table entries | ≤ 20–30                     |

When limits are exceeded: demote less-critical info, split subsystems into separate consoles, aggregate instead of showing granular data, or move info to side tables.

## Separate Dashboards for Separate Audiences

On-call engineers need "what is broken?" — operational, high-signal, narrow scope.

Developers need context for feature work — broader, historical, exploratory.

These are different audiences with different questions. Maintain separate console sets for each.

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
