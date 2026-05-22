# Alerting with Logs

[vmalert](/victoriametrics/vmalert/) integrates with VictoriaLogs via stats APIs
[`/select/logsql/stats_query`](/victorialogs/querying/#querying-log-stats) and
[`/select/logsql/stats_query_range`](/victorialogs/querying/#querying-log-range-stats).
These endpoints return log stats in a format compatible with the Prometheus querying API.
This allows using VictoriaLogs as the datasource in vmalert and creating alerting and recording rules via [LogsQL](/victorialogs/logsql/).

## Quick Start

Run vmalert with the following settings:

```
./bin/vmalert -rule=alert.rules                  \  # Path to the files or HTTP URL with alerting and/or recording rules in YAML format
    -datasource.url=http://victorialogs:9428     \  # VictoriaLogs address
    -notifier.url=http://alertmanager:9093       \  # Alertmanager URL (required if alerting rules are used)
    -remoteWrite.url=http://victoriametrics:8428 \  # Remote write-compatible storage to persist recording rules and alerts state info
    -remoteRead.url=http://victoriametrics:8428  \  # Prometheus HTTP API-compatible datasource to restore alerts state from
```

Note: By default, vmalert assumes all configured rules have the `prometheus` type.
For rules in LogsQL, specify `type: vlogs` at the group level, or set the `-rule.defaultRuleType=vlogs` command-line flag.

With the configuration example above, vmalert will:

1. Execute rules listed in the `-rule` file against the VictoriaLogs service configured via `-datasource.url`.
2. Send triggered alerting notifications to the Alertmanager service configured via `-notifier.url`.
3. Persist results of recording rule expressions and alerts state to a Prometheus-compatible remote-write endpoint (VictoriaMetrics) configured via `-remoteWrite.url`.
4. On vmalert restarts, restore alerts state by querying a Prometheus-compatible HTTP API endpoint (VictoriaMetrics) configured via `-remoteRead.url`.

## Configuration

### Flags

Key flags related to integration with VictoriaLogs:

```
-datasource.url string
   Datasource address supporting log stats APIs.
-notifier.url array
   Prometheus Alertmanager URL.
-remoteWrite.url string
   Optional URL to VictoriaMetrics or vminsert where to persist alerts state and recording rule results.
-remoteRead.url string
   Optional URL to a datasource compatible with MetricsQL for restoring alerts state.
-rule array
   Path to the files or HTTP URL with alerting and/or recording rules in YAML format.
-rule.defaultRuleType
   The default type for rule expressions; can be overridden by the 'type' parameter inside the rule group.
   Supported values: "graphite", "prometheus" and "vlogs". Default is "prometheus".
-rule.evalDelay time
   Adjustment of the time parameter for rule evaluation requests to compensate for intentional data delay.
   Since there is no intentional search delay in VictoriaLogs, this can be reduced to a few seconds.
```

### Groups

#### Alerting rules

`vmalert` executes the given LogsQL query from the `expr` option according to the provided `interval`.

The `expr` query must contain [`stats` pipe](/victorialogs/logsql/#stats-pipe) in order to calculate some metric over the selected logs, and use this metric in alerting threshold. Use [`filter` pipe](/victorialogs/logsql/#filter-pipe) for filtering the calculated metric according to the needed threshold.

Example — fires if the number of logs with `error` or `warn` status in `env=prod` exceeds 10 during the last 5 minutes:

```
groups:
- name: ServiceLog
  type: vlogs
  interval: 5m
  rules:
  - alert: HasMoreThan10ErrorLogs
    expr: '{env=prod} status:in(error,warn) | stats count() as error_logs | filter error_logs:>10'
    annotations:
      description: 'Too big number of errors and warnings during the last 5 minutes: {{$value}}'
```

Example using `stats by (...)`, `math` and `fields` pipes — triggers if failed requests exceed 10% for a given `ip`:

```
- name: ServiceRequest
  type: vlogs
  interval: 5m
  rules:
  - alert: TooManyFailedRequestsByIP
    expr: '* | extract "ip=<ip> " | extract "status_code=<code>;" | stats by (ip) count() if (code:~"4.*") as failed, count() as total | math (failed / total) * 100 as failed_percentage | filter failed_percentage:>10 | fields ip, failed_percentage'
    annotations:
      description: "Connection from address {{$labels.ip}} has {{$value}}% failed requests in the last 5 minutes"
```

#### Recording rules

`vmalert` executes the given LogsQL query from the `expr` option according to the provided `interval` and stores the query results as metrics at the remote storage.

Example — calculates the number of logs for `env=test` and `service=nginx` per every 5 minute interval:

```
groups:
- name: RequestCount
  type: vlogs
  interval: 5m
  rules:
  - record: nginxRequestCount
    expr: '{env=test,service=nginx} | stats count(*) as requests'
```

Example using `stats by (...)`, `math` and `fields` pipes — calculates the share of errors per each `service`:

```
groups:
- name: RequestCount
  type: vlogs
  interval: 5m
  rules:
  - record: prodErrorsShareByService
    expr: '{env=prod} | stats by (service) count() as logs_total, count() if (error) errors | math (errors / total) as errors_share | fields service, errors_share'
```

## Time filter

It's recommended to omit the time filter in rule expressions. By default, vmalert automatically appends the time filter `_time: <group_interval>` to the expression. For instance, the rule below will be evaluated every 5 minutes and will return the result with logs from the last 5 minutes:

```
groups:
- name: Requests
  type: vlogs
  interval: 5m
  rules:
  - alert: TooManyFailedRequestByIP
    expr: '* | extract "ip=<ip> " | extract "status_code=<code>;" | stats by (ip) count() if (code:~"4.*") as failed, count() as total | math (failed / total) * 100 as failed_percentage | filter failed_percentage:>10 | fields ip, failed_percentage'
    annotations:
      description: "Connection from address {{$labels.ip}} has {{$value}}% failed requests in the last 5 minutes"
```

Users can specify a custom time filter if needed:

```
groups:
- name: Requests
  type: vlogs
  interval: 5m
  rules:
  - alert: TooManyFailedRequestByIP
    expr: '_time:10m | extract "ip=<ip> " | ...'
    annotations:
      description: "Connection from address {{$labels.ip}} has {{$value}}% failed requests in the last 10 minutes"
```

## Rules backfilling

vmalert supports alerting and recording rule backfilling (aka replay) against VictoriaLogs:

```
./bin/vmalert -rule=path/to/your.rules \
    -datasource.url=http://localhost:9428 \
    -rule.defaultRuleType=vlogs \
    -remoteWrite.url=http://localhost:8428 \
    -replay.timeFrom=2021-05-11T07:21:43Z \
    -replay.timeTo=2021-05-29T18:40:43Z
```

## Performance tip

LogsQL allows users to obtain multiple stats from a single expression. For instance, calculating multiple percentiles at once:

```
_time:5m | stats
  quantile(0.5, request_duration_seconds) p50,
  quantile(0.9, request_duration_seconds) p90,
  quantile(0.99, request_duration_seconds) p99
```

Used in a recording rule:

```
groups:
  - name: requestDuration
    type: vlogs
    interval: 5m
    rules:
      - record: requestDurationQuantile
        expr: '* | stats by (service) quantile(0.5, request_duration_seconds) p50, quantile(0.9, request_duration_seconds) p90, quantile(0.99, request_duration_seconds) p99'
```

This rule generates three metrics per service in each evaluation:

```
requestDurationQuantile{stats_result="p50", service="service-1"}
requestDurationQuantile{stats_result="p90", service="service-1"}
requestDurationQuantile{stats_result="p99", service="service-1"}
```

## Frequently Asked Questions

### How to attach a sample log row to alerts?

Use [`row_any()`](/victorialogs/logsql/#row_any-stats) only inside `annotations` via the `query` template function.

Note: do not use these functions in `expr`, since the returned row can change between evaluations.

Example with a stable `expr` and a sampled log message in `annotations`:

```
groups:
  - name: vlogs
    type: vlogs
    interval: 1m
    rules:
      - alert: ErrorsByPath
        expr: '* | stats by (path) count() as errors | filter errors:>10'
        for: 2m
        annotations:
          description: >-
            path={{ $labels.path }} errors={{ $value }}
            {{ $ms := query (printf "path:%q | stats count() as hits, row_any(_msg) as sample_msg | filter hits:>0" $labels.path) }}
            {{ if gt (len $ms) 0 }}sample={{ label "sample_msg" (index $ms 0) }}{{ end }}
```

### How to use multitenancy in rules?

Specify the tenant to query in the VictoriaLogs datasource via the `headers` parameter in the group config:

```
groups:
  - name: MyGroup
    headers:
    - "AccountID: 1"
    - "ProjectID: 2"
    rules: ...
```

### How to use one vmalert for VictoriaLogs and VictoriaMetrics rules at the same time?

We recommend running separate instances of vmalert for VictoriaMetrics and VictoriaLogs. However, vmalert supports having many groups with different rule types (`vlogs`, `prometheus`, `graphite`). Use [vmauth](/victoriametrics/vmauth/) to route requests of different types between datasources:

```
unauthorized_user:
  url_map:
    - src_paths:
      - "/api/v1/query.*"
      url_prefix: "http://victoriametrics:8428"
    - src_paths:
      - "/select/logsql/.*"
      url_prefix: "http://victorialogs:9428"
```

Now vmalert can be configured with `-datasource.url=http://vmauth:8427/` to send queries to vmauth.
