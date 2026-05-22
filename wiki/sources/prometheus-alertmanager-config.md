---
title: "Alertmanager — Configuration Reference"
tags:
  [
    alertmanager,
    prometheus,
    routing,
    receivers,
    inhibition,
    silencing,
    configuration,
  ]
sources: [prometheus-alertmanager-config.md]
updated: 2026-05-22
---

# Alertmanager — Configuration Reference

Official Prometheus Alertmanager configuration reference. Alertmanager handles alert deduplication, grouping, routing, silencing, and notifications.

## Configuration Basics

Config file loaded via `--config.file=alertmanager.yml`. Reloaded at runtime via `SIGHUP` or `POST /-/reload`.

### Top-Level Structure

```yaml
global: # defaults for receivers; applies where not overridden
route: # routing tree — all alerts enter here
receivers: # named notification endpoints
inhibit_rules: # suppression rules
time_intervals: # named time ranges
mute_time_intervals: # time ranges during which to mute
templates: # glob paths to template files
```

## Global Settings

Global defaults cover SMTP, Slack, PagerDuty, OpsGenie, VictorOps, Telegram, and others. Each receiver type has its API key/URL defaulted here and overridden per-receiver. Key global fields:

- `smtp_smarthost`, `smtp_from`, `smtp_require_tls`
- `slack_api_url`, `pagerduty_url`, `opsgenie_api_url`
- `resolve_timeout`: time after which an alert without updates is declared resolved

## Route Tree

```yaml
route:
  receiver: <string> # fallback receiver
  group_by: [<labelname>] # labels to group alerts
  group_wait: <duration> # wait before sending first notification
  group_interval: <duration> # wait for sending more notifications
  repeat_interval: <duration> # wait before resending a notification
  continue: <bool> # whether to continue matching child routes
  matchers:
    - <matcher>
  routes:
    - <route>
```

Matchers use label equality (`=`), inequality (`!=`), regex (`=~`), negative regex (`!~`).

## Receivers

A receiver defines one or more integration configurations:

```yaml
receivers:
  - name: <string>
    email_configs: [<email_config>]
    pagerduty_configs: [<pagerduty_config>]
    slack_configs: [<slack_config>]
    webhook_configs: [<webhook_config>]
    victorops_configs: [<victorops_config>]
    opsgenie_configs: [<opsgenie_config>]
    pushover_configs: [<pushover_config>]
    telegram_configs: [<telegram_config>]
    msteams_configs: [<msteams_config>]
    discord_configs: [<discord_config>]
    jira_configs: [<jira_config>]
    rocketchat_configs: [<rocketchat_config>]
    webex_configs: [<webex_config>]
    sns_configs: [<sns_config>]
    wechat_configs: [<wechat_config>]
```

### Webhook Config

Generic HTTP integration — preferred for custom integrations:

```yaml
webhook_configs:
  - url: <string>
    send_resolved: <bool> # default: true
    http_config: <http_config>
    max_alerts: <int> # 0 = no limit
```

Webhook POST body matches the [notification template Data structure](../sources/prometheus-alertmanager-notifications.md).

## Inhibition Rules

Suppress alerts matching `target_matchers` when a "source" alert matching `source_matchers` exists:

```yaml
inhibit_rules:
  - source_matchers: [<matcher>]
    target_matchers: [<matcher>]
    equal: [<labelname>] # labels that must be equal in both
```

## Time Intervals

Named time ranges for muting or routing:

```yaml
time_intervals:
  - name: business-hours
    time_intervals:
      - times:
          - start_time: "09:00"
            end_time: "17:00"
        weekdays: ["monday:friday"]
        location: "Local"
```

## TLS and HTTP Config

Receivers support `tls_config` (ca_file, cert_file, key_file, insecure_skip_verify) and `http_config` (proxy_url, follow_redirects, bearer_token).

## Silences

Silences are created at runtime via the API or UI — they match alerts by label selectors and suppress notifications for a configured duration.

## Limits

Command-line flags control silence limits:

- `--silences.max-silences`: max number of silences (including expired)
- `--silences.max-silence-size-bytes`: max size of individual silences

## Related

- [Alertmanager concept](../concepts/alertmanager.md)
- [Notification templates](../sources/prometheus-alertmanager-notifications.md)
- [Prometheus Alerting Rules](../sources/prometheus-alerting-rules.md)
- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
