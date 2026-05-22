---
title: "Prometheus — Alerting Rules (Config Reference)"
tags: [prometheus, alerting-rules, alertmanager, templating, configuration]
sources: [prometheus-alerting-rules.md]
updated: 2026-05-22
---

# Prometheus — Alerting Rules (Config Reference)

Official Prometheus documentation for defining alerting rules.

## Overview

Alerting rules evaluate PromQL expressions and fire when the expression returns one or more vector elements. They are defined in the same rule group format as recording rules (see [recording rules config](../sources/prometheus-recording-rules.md)).

## Alert Lifecycle

| State   | Meaning                                                  |
| ------- | -------------------------------------------------------- |
| Pending | Expression matches, but `for` duration not yet satisfied |
| Firing  | Expression has matched for at least the `for` duration   |

- **`for`**: time the condition must be continuously true before firing (default: fires immediately)
- **`keep_firing_for`**: how long the alert stays firing after the condition last held — prevents flapping and false resolutions from data gaps

## Example

```yaml
groups:
  - name: example
    labels:
      team: myteam
    rules:
      - alert: HighRequestLatency
        expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
        for: 10m
        keep_firing_for: 5m
        labels:
          severity: page
        annotations:
          summary: High request latency
```

## Templating

Label and annotation values support Go templates:

```
{{ $labels.<labelname> }}   # label value of the firing instance
{{ $value }}                # numeric expression value
{{ $externalLabels.<name> }} # Prometheus external labels
```

## Synthetic ALERTS Series

While an alert is active, Prometheus stores:

```
ALERTS{alertname="<name>", alertstate="<pending|firing>", <alert labels>} = 1
```

The series is marked stale when the alert deactivates.

## Alertmanager Integration

Alerting rules detect _what is broken right now_. Prometheus sends alert state to [Alertmanager](../concepts/alertmanager.md), which handles:

- Deduplication
- Grouping
- Routing
- Silencing
- Rate limiting

## Related

- [Prometheus Recording Rules (config)](../sources/prometheus-recording-rules.md)
- [Prometheus Alerting best practices](../sources/prometheus-alerting.md)
- [Alertmanager concept](../concepts/alertmanager.md)
- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
