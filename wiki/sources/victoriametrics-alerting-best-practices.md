---
title: "Alerting Best Practices (VictoriaMetrics)"
tags:
  [
    alerting,
    monitoring,
    prometheus,
    vmalert,
    victoriametrics,
    sre,
    observability,
  ]
sources: [victoriametrics-alerting-best-practices.md]
updated: 2026-04-24
---

# Alerting Best Practices (VictoriaMetrics)

**Authors:** Roman Khavronenko and Mathias Palmersheim  
**Published:** Aug 22, 2025

## Core principle: every alert must be actionable

If engineers consistently ignore an alert, it should not exist. An alert that fires but demands no action is noise — noise causes fatigue — fatigue causes real alerts to be ignored.

## Defining alerting rules

### Rule expression (`expr`)

1. Must describe a state that **genuinely requires action** from an on-call engineer.
2. Test against real data across multiple time intervals and environments.
3. Return only the labels you actually need — reduce cardinality by aggregating (e.g. `max(...) by(job) > 0.9`).

**Lookbehind window rule:** Use at least **4× the scrape interval** as the lookbehind window.  
Reason: vmalert executes instant queries with a default 5-minute lookback (`-datasource.queryStep`). A scrape interval ≥ 5 min means data points may fall outside the window. Even with a shorter interval, always account for delivery delays.

Example: `rate(errors_total[1m])` with a 1-minute scrape interval is meaningless — needs at least 2 data points.

### The `for` param

Prevents alert flapping from short-lived transient conditions. The alert fires only after the `expr` is true for the entire `for` duration.

- Set `for` **greater than the lookbehind window** to capture sustained conditions, not single events.  
  Example: `[5m]` window → `for: 10m`.
- Longer `for` = more latency before firing. Balance noise vs. response speed.
- Do not set `for` to the same duration as the lookbehind window — the alert would trivially remain active.

### The `keep_firing_for` param

The inverse of `for`. Keeps an alert firing for a specified duration **after** the `expr` stops returning results.

Purpose: prevents premature resolution due to brief data gaps (one empty evaluation resolves the alert by default). Without it, a CPU alert can flap if usage dips below threshold momentarily, generating repeated identical notifications.

### Labels

Two purposes:

1. **Categorization** — `severity: critical`, `team: platform` → used by Alertmanager for routing.
2. **Enrichment** — static context not in the metric, e.g. `region: EMEA`.

**Anti-pattern:** Setting a label to a dynamic value like `$value` — this changes the label set on every evaluation and resets the `for` duration, causing the alert never to fire.

### Annotations

Used for human-readable context: `summary` (one-liner), `description` (simplified runbook), `dashboard` (direct Grafana panel link).

Unlike labels, annotations are **not stored in VictoriaMetrics** — ideal for long strings, URLs, templated messages.  
Templates (`$value`, `$labels`) are safe in annotations since annotations are not checked during `for` evaluation.

Extra context can be fetched at fire time via the `query()` template function, which executes arbitrary MetricsQL queries.

### External URLs (`-external.url`)

Configure `-external.url` and `-external.alert.source` in vmalert to point to user-accessible systems (e.g. Grafana). Default internal service URLs are not useful for on-call engineers. Using `$externalURL` in annotations makes rules portable across environments.

## Alert history

vmalert persists alert state changes as `ALERTS` and `ALERTS_FOR_STATE` time series. Use the VictoriaMetrics Grafana dashboard for alert statistics to identify:

- Alerts that fire too frequently (noisy)
- Alerts that never fire (possibly broken expressions)

Both extremes are suspicious and need investigation.

## Reducing noise

- Aggregate to the right granularity: per-region instead of per-pod for replicated services.
- Use SLO-based error budgets: alert only when the error budget burns too fast.
- Use Alertmanager **inhibition rules**: silence downstream alerts when a root-cause alert is present (e.g. datacenter failure causing cascade).

## Testing alerts

- **vmalert-tool**: unit-test alerting rules against controlled data. Integrate into CI for rule changes.
- **Replay (backfilling)**: run alerting rules against historical production data to verify when alerts would have fired. Results visible in the Alerts history dashboard.

## Related pages

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Zen of Prometheus](../concepts/prometheus-zen.md)
- [Runbooks](../concepts/runbooks.md)
- [VictoriaMetrics](../entities/victoriametrics.md)
