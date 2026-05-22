---
title: "Prometheus — Defining Recording Rules (Config Reference)"
tags: [prometheus, recording-rules, alerting-rules, configuration, promtool]
sources: [prometheus-recording-rules.md]
updated: 2026-05-22
---

# Prometheus — Defining Recording Rules (Config Reference)

Official Prometheus documentation for defining recording and alerting rules in rule files.

## Rule Files

Rules are defined in YAML files loaded via `rule_files` in the Prometheus config. Files can be reloaded at runtime via `SIGHUP`. Syntax can be pre-validated without a running server:

```bash
promtool check rules /path/to/example.rules.yml
```

## Rule Group Schema

Recording and alerting rules live inside named rule groups:

```yaml
groups:
  - name: <string> # unique within file
    interval: <duration> # default: global.evaluation_interval
    limit: <int> # default 0 = no limit
    query_offset: <duration> # default: global.rule_query_offset
    labels:
      <labelname>: <labelvalue> # added/overwritten before storing
    rules:
      - <rule>
```

## Recording Rule Schema

```yaml
record: <string> # output metric name (must be valid metric name)
expr: <string> # PromQL expression evaluated each cycle
labels:
  <labelname>: <labelvalue>
```

## Alerting Rule Schema

```yaml
alert: <string> # alert name (must be valid label value)
expr: <string> # PromQL expression; resultant series become alerts
for: <duration> # pending → firing threshold (default: 0s)
keep_firing_for: <duration> # continues firing after condition clears (default: 0s)
labels:
  <labelname>: <tmpl_string>
annotations:
  <labelname>: <tmpl_string>
```

## Key Behaviors

- **Limit enforcement**: When the per-group `limit` is exceeded, _all_ series/alerts produced by that rule are discarded, with no stale markers written.
- **Query offset**: `query_offset` shifts evaluation timestamps into the past, useful when remote write targets introduce metric availability delays.
- **Slow evaluation**: If a group hasn't finished before its next scheduled evaluation, the next iteration is skipped. Gap appears in the recorded metric; `rule_group_iterations_missed_total` is incremented.

## Related

- [Prometheus Recording Rules (best practices)](../sources/prometheus-rules.md)
- [Prometheus Alerting (best practices)](../sources/prometheus-alerting.md)
- [Prometheus Recording Rules concept](../concepts/prometheus-recording-rules.md)
- [Alertmanager](../concepts/alertmanager.md)
