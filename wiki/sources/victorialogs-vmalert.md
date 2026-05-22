---
title: "VictoriaLogs — Alerting with Logs (vmalert integration)"
tags:
  [victorialogs, vmalert, logsql, alerting, recording-rules, log-based-alerting]
sources: [victorialogs-vmalert.md]
updated: 2026-05-22
---

# VictoriaLogs — Alerting with Logs

vmalert integrates with VictoriaLogs via its stats APIs (`/select/logsql/stats_query` and `/select/logsql/stats_query_range`) to enable alerting and recording rules written in LogsQL.

## Quick Start

```bash
./bin/vmalert \
  -rule=alert.rules \
  -datasource.url=http://victorialogs:9428 \   # VictoriaLogs address
  -notifier.url=http://alertmanager:9093 \
  -remoteWrite.url=http://victoriametrics:8428 \
  -remoteRead.url=http://victoriametrics:8428
```

Add `type: vlogs` at group level, or set `-rule.defaultRuleType=vlogs`.

## Alerting Rules Example

Alert if error/warn log count exceeds 10 in the last 5 minutes:

```yaml
groups:
  - name: ServiceLog
    type: vlogs
    interval: 5m
    rules:
      - alert: HasMoreThan10ErrorLogs
        expr: "{env=prod} status:in(error,warn) | stats count() as error_logs | filter error_logs:>10"
        annotations:
          description: "Too many errors/warnings in last 5 minutes: {{$value}}"
```

Alert if failed requests exceed 10% per IP:

```yaml
- name: ServiceRequest
  type: vlogs
  interval: 5m
  rules:
    - alert: TooManyFailedRequestsByIP
      expr: '* | extract "ip=<ip> " | extract "status_code=<code>;" | stats by (ip) count() if (code:~"4.*") as failed, count() as total | math (failed / total) * 100 as failed_percentage | filter failed_percentage:>10 | fields ip, failed_percentage'
      annotations:
        description: "{{$labels.ip}} has {{$value}}% failed requests in last 5 minutes"
```

## Recording Rules Example

Calculate nginx request count every 5 minutes:

```yaml
groups:
  - name: RequestCount
    type: vlogs
    interval: 5m
    rules:
      - record: nginxRequestCount
        expr: "{env=test,service=nginx} | stats count(*) as requests"
```

## Time Filter

vmalert automatically appends `_time: <group_interval>` to expressions. Omit time filter in your rules — vmalert adds it. Override with explicit `_time:10m` at the start of the expression when needed.

## Performance: Multiple Stats in One Expression

```yaml
- record: requestDurationQuantile
  expr: "* | stats by (service) quantile(0.5, request_duration_seconds) p50, quantile(0.9, request_duration_seconds) p90, quantile(0.99, request_duration_seconds) p99"
```

Generates three metrics per service per evaluation:

```
requestDurationQuantile{stats_result="p50", service="service-1"}
requestDurationQuantile{stats_result="p90", service="service-1"}
requestDurationQuantile{stats_result="p99", service="service-1"}
```

## FAQ

### Attach sample log row to alerts?

Use `row_any()` only inside `annotations` via the `query` template function — not in `expr` (returned row can change between evaluations):

```yaml
annotations:
  description: >-
    path={{ $labels.path }} errors={{ $value }} {{ $ms := query (printf "path:%q | stats count() as hits, row_any(_msg) as sample_msg | filter hits:>0" $labels.path) }} {{ if gt (len $ms) 0 }}sample={{ label "sample_msg" (index $ms 0) }}{{ end }}
```

### Multitenancy?

Use `headers` in group config:

```yaml
groups:
  - name: MyGroup
    headers:
      - "AccountID: 1"
      - "ProjectID: 2"
```

### Mixed VictoriaMetrics + VictoriaLogs rules?

Use vmauth to route by path — `prometheus` type rules go to VictoriaMetrics, `vlogs` rules go to VictoriaLogs — and point vmalert at vmauth.

## Key Flags for VictoriaLogs

- `-rule.defaultRuleType=vlogs` — make all rules LogsQL by default
- `-rule.evalDelay` — reduce to a few seconds (no intentional delay in VictoriaLogs)

## Related

- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
- [VictoriaMetrics entity](../entities/victoriametrics.md)
- [Alertmanager concept](../concepts/alertmanager.md)
