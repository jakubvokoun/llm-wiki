# vmalert-tool

VMAlert command-line tool

## Unit testing for rules

You can use `vmalert-tool` to run unit tests for alerting and recording rules.
It will perform the following actions:

* sets up an isolated VictoriaMetrics instance;
* simulates the periodic ingestion of time series;
* queries the ingested data for recording and alerting rules evaluation like [vmalert](/victoriametrics/vmalert/);
* checks whether the firing alerts or resulting recording rules match the expected results.

See how to run vmalert-tool for unit test below:

```
# Run vmalert-tool with one or multiple test files via `--files` cmd-line flag
# Supports file path with hierarchical patterns and regexpes, and http url.
./vmalert-tool unittest --files /path/to/file --files http://<some-server-addr>/path/to/test.yaml
```

vmalert-tool unittest is compatible with [Prometheus config format for tests](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/#test-file-format)
except `promql_expr_test` field. Use `metricsql_expr_test` field name instead. The name is different because vmalert-tool
validates and executes [MetricsQL](/victoriametrics/metricsql/) expressions,
which aren't always backward compatible with PromQL.

### Limitations

* vmalert-tool evaluates all the groups defined in `rule_files` using `evaluation_interval`(default `1m`) instead of `interval` under each rule group.
* vmalert-tool shares the same limitation with [vmalert](/victoriametrics/vmalert/#limitations) on chaining rules under one group:

by default, rules execution is sequential within one group, but persistence of execution results to remote storage is asynchronous. Hence, user shouldn't rely on chaining of recording rules when result of previous recording rule is reused in the next one.

The workaround is to divide them in two groups and put groupA in front of groupB (or use `group_eval_order` to define the evaluation order):

```
groups:
- name: groupA
  rules:
  - record: A
    expr: sum(xxx)
- name: groupB
  rules:
  - alert: B
    expr: A >= 0.75
    for: 1m
```

### Test file format

The configuration format for files specified in `--files` cmd-line flag is the following:

```
# Path to the files or http url containing rule groups configuration.
rule_files:
  [ - <string> ]

# The evaluation interval for rules specified in `rule_files`
[ evaluation_interval: <duration> | default = 1m ]

# Groups listed below will be evaluated by order.
group_eval_order:
  [ - <string> ]

# The list of unit test files to be checked during evaluation.
tests:
  [ - <test_group> ]
```

#### `<test_group>`

```
# Interval between samples for input series
[ interval: <duration> | default = evaluation_interval ]
# Time series to persist into the database according to configured <interval> before running tests.
input_series:
  [ - <series> ]

# Name of the test group, optional
[ name: <string> ]

# Unit tests for alerting rules
alert_rule_test:
  [ - <alert_test_case> ]

# Unit tests for Metricsql expressions.
metricsql_expr_test:
  [ - <metricsql_expr_test> ]

external_labels:
  [ <labelname>: <string> ... ]
```

#### `<series>`

```
# series in the following format '<metric name>{<label name>=<label value>, ...}'
series: <string>

# values support several special equations:
#    'a+bxc' becomes 'a a+b a+(2*b) a+(3*b) … a+(c*b)'
#    'a-bxc' becomes 'a a-b a-(2*b) a-(3*b) … a-(c*b)'
#    '_' represents a missing sample from scrape
#    'stale' indicates a stale sample
values: <string>
```

#### `<alert_test_case>`

```
# The time elapsed from time=0s when this alerting rule should be checked.
eval_time: <duration>

# Name of the group name to be tested.
groupname: <string>

# Name of the alert to be tested.
alertname: <string>

# List of the expected alerts that are firing under the given alertname at the given evaluation time.
exp_alerts:
  [ - <alert> ]
```

#### `<alert>`

```
exp_labels:
  [ <labelname>: <string> ]
exp_annotations:
  [ <labelname>: <string> ]
```

#### `<metricsql_expr_test>`

```
# Expression to evaluate
expr: <string>

# The time elapsed from time=0s when this expression be evaluated.
eval_time: <duration>

# Expected samples at the given evaluation time.
exp_samples:
  [ - <sample> ]
```

#### `<sample>`

```
labels: <string>
value: <number>
```

### Example

`test.yaml` is the test file which follows the syntax above and `rules.yaml` contains the alerting rules.

With `rules.yaml` in the same directory with `test.yaml`, run `./vmalert-tool unittest --files=./unittest/testdata/test.yaml -external.label=cluster=prod`.

#### `test.yaml`

```
rule_files:
  - rules.yaml

evaluation_interval: 1m

tests:
  - interval: 1m
    input_series:
      - series: 'up{job="prometheus", instance="localhost:9090"}'
        values: "0+0x1440"

    metricsql_expr_test:
      - expr: subquery_interval_test
        eval_time: 4m
        exp_samples:
          - labels: '{__name__="subquery_interval_test", cluster="prod", instance="localhost:9090", job="prometheus"}'
            value: 1

    alert_rule_test:
      - eval_time: 2h
        groupname: group1
        alertname: InstanceDown
        exp_alerts:
          - exp_labels:
              job: prometheus
              severity: page
              instance: localhost:9090
              cluster: prod
            exp_annotations:
              summary: "Instance localhost:9090 down"
              description: "localhost:9090 of job prometheus in cluster prod has been down for more than 5 minutes."

      - eval_time: 0
        groupname: group1
        alertname: AlwaysFiring
        exp_alerts:
          - exp_labels:
              cluster: prod

      - eval_time: 0
        groupname: group1
        alertname: InstanceDown
        exp_alerts: []
```

#### `rules.yaml`

```
groups:
  - name: group1
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: page
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} of job {{ $labels.job }} in cluster {{ $externalLabels.cluster }} has been down for more than 5 minutes."
      - alert: AlwaysFiring
        expr: 1

  - name: group2
    rules:
      - record: job:test:count_over_time1m
        expr: sum without(instance) (count_over_time(test[1m]))
      - record: subquery_interval_test
        expr: count_over_time(up[5m:])
```

### Debug mode

vmalert-tool can print additional log messages for specific alerting rules by:

1. Set `debug: true` in rule's configuration;
2. Run vmalert-tool with the flag `-loggerLevel=INFO`.

### Configuration

Run `vmalert-tool unittest --help` to get all configuration options:

```
  -files
    File path or http url with test files. Supports an array of values separated by comma or specified via multiple flags.
  -disableAlertgroupLabel
    disable adding group's Name as label to generated alerts and time series. (default: false)
  -external.label
    Optional label in the form 'name=value' to add to all generated recording rules and alerts.
  -external.url
    Optional external URL to template in rule's labels or annotations.
  -httpListenPort
    Optional local port for incoming HTTP requests.
  -loggerLevel
    Minimum level of errors to log. Possible values: INFO, WARN, ERROR, FATAL, PANIC (default "ERROR").
```
