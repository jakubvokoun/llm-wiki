---
title: "Alertmanager — Notification Template Reference"
tags: [alertmanager, prometheus, notifications, templates, go-templates]
sources: [prometheus-alertmanager-notifications.md]
updated: 2026-05-22
---

# Alertmanager — Notification Template Reference

Alertmanager sends notifications to receivers (Slack, PagerDuty, email, webhook) using Go templates. This is the data model and function reference for authoring custom notification templates.

## Data Structures

### Data (top-level template object)

| Field               | Type    | Description                                           |
| ------------------- | ------- | ----------------------------------------------------- |
| `Receiver`          | string  | Name of the receiver being notified                   |
| `Status`            | string  | `firing` if any alert is firing, otherwise `resolved` |
| `Alerts`            | []Alert | All alerts in the notification group                  |
| `GroupLabels`       | KV      | Labels used to group these alerts                     |
| `CommonLabels`      | KV      | Labels common across all alerts                       |
| `CommonAnnotations` | KV      | Annotations common across all alerts                  |
| `ExternalURL`       | string  | Backlink to the Alertmanager instance                 |

`Alerts` has two filter methods: `.Firing` and `.Resolved`.

### Alert

| Field          | Type      | Description                                 |
| -------------- | --------- | ------------------------------------------- |
| `Status`       | string    | `firing` or `resolved`                      |
| `Labels`       | KV        | Alert labels                                |
| `Annotations`  | KV        | Alert annotations                           |
| `StartsAt`     | time.Time | When the alert started firing               |
| `EndsAt`       | time.Time | Known end time or timeout from last receipt |
| `GeneratorURL` | string    | Backlink to the causing entity              |
| `Fingerprint`  | string    | Unique identifier for the alert             |

### KV (key/value string map)

| Method        | Returns  | Description                 |
| ------------- | -------- | --------------------------- |
| `SortedPairs` | []Pair   | Sorted key/value pairs      |
| `Remove`      | KV       | Copy without specified keys |
| `Names`       | []string | All label names             |
| `Values`      | []string | All label values            |

## Template Functions

Key functions available beyond Go's built-in template functions:

| Function                    | Description                                             |
| --------------------------- | ------------------------------------------------------- |
| `humanizeDuration`          | Human-readable duration string                          |
| `date`                      | Format time: `date "2006-01-02" .StartsAt`              |
| `since`                     | Duration since a time.Time                              |
| `tz`                        | Time in timezone: `tz "Europe/Paris" .StartsAt`         |
| `match`                     | Regex match                                             |
| `reReplaceAll`              | Regex replace                                           |
| `join`                      | `join sep []string` (arg order inverted for pipelining) |
| `toJson`                    | JSON encode any value                                   |
| `toLower`/`toUpper`/`title` | String case conversion                                  |
| `trimSpace`                 | Trim leading/trailing whitespace                        |
| `safeHtml`                  | Mark string as HTML (skip escaping)                     |
| `safeUrl`                   | Mark string as URL (skip escaping)                      |
| `dict`                      | Create `map[string]any` from variadic key-value pairs   |
| `list`                      | Return arguments as `[]interface{}`                     |
| `append`                    | Append to a slice                                       |
| `urlUnescape`               | Unescape URL percent encoding                           |

## Related

- [Alertmanager concept](../concepts/alertmanager.md)
- [Alertmanager configuration](../sources/prometheus-alertmanager-config.md)
- [Prometheus Alerting Rules](../sources/prometheus-alerting-rules.md)
