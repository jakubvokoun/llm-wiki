---
title: "Tilt Manual Update Control"
tags: [tilt, trigger-mode, local-dev, kubernetes]
sources: [tilt-manual-update-control]
updated: 2026-07-01
---

# Tilt Manual Update Control

Source: <https://docs.tilt.dev/manual_update_control.html>

## Overview

By default [[tilt]] watches the filesystem and automatically rebuilds and redeploys any resource whose file dependencies change (`TriggerMode: Auto`). Manual Update Control lets you pause that automation — Tilt still tracks file changes but waits for an explicit user action before applying them.

## TriggerMode

Two constants are available in the [[tiltfile]]:

| Constant              | Behaviour                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------- |
| `TRIGGER_MODE_AUTO`   | Default. Update fires automatically whenever a relevant file changes.                     |
| `TRIGGER_MODE_MANUAL` | Tilt shows an asterisk in the UI when files are pending; update must be clicked manually. |

### Setting trigger mode

**Per-resource** — pass `trigger_mode` to the resource-configuration function:

```python
k8s_resource('snack', trigger_mode=TRIGGER_MODE_MANUAL)
```

Supported on `k8s_resource()`, `local_resource()`, and `dc_resource()`.

**Global default** — call the top-level `trigger_mode()` function before resource declarations:

```python
trigger_mode(TRIGGER_MODE_MANUAL)

k8s_resource('snack')                          # inherits Manual
k8s_resource('bar', trigger_mode=TRIGGER_MODE_AUTO)  # overrides back to Auto
```

Per-resource settings always win over the global default.

## auto_init

`auto_init` (default `True`) controls whether a resource runs once at Tilt startup, before any file changes occur. Combining it with `trigger_mode` gives four behaviours:

| `trigger_mode`        | `auto_init` | Runs at start? | Runs on file change? |
| --------------------- | ----------- | -------------- | -------------------- |
| `TRIGGER_MODE_AUTO`   | `True`      | Yes            | Yes (automatic)      |
| `TRIGGER_MODE_AUTO`   | `False`     | No             | Yes (automatic)      |
| `TRIGGER_MODE_MANUAL` | `True`      | Yes            | Only when triggered  |
| `TRIGGER_MODE_MANUAL` | `False`     | No             | Only when triggered  |

The `auto_init=False` + `TRIGGER_MODE_MANUAL` combination is the most restrictive: the resource never runs unless the user explicitly clicks the trigger button. Useful for expensive or disruptive operations (e.g. integration tests, database migrations).

The `auto_init=False` + `TRIGGER_MODE_AUTO` combination skips the initial run but still reacts to file changes automatically — handy for linters or test runners that only make sense after the first manual setup.

## UI Indicators

When a resource is in Manual mode and has pending file changes, Tilt marks it with an **asterisk** in the sidebar. An **apply button** appears next to the resource name to kick off the update on demand.

## Relation to the control loop

Manual Update Control is a UI and [[tiltfile]]-level overlay on top of [[tilt-control-loop]]: the reconciler still tracks state and dependencies, but the trigger step is gated by user intent rather than file-watch events.

## Quick-reference snippets

```python
# Fully automatic (default — explicit is fine too)
k8s_resource('api', trigger_mode=TRIGGER_MODE_AUTO)

# Manual trigger, still runs at startup
k8s_resource('worker', trigger_mode=TRIGGER_MODE_MANUAL)

# Only run when explicitly triggered; never auto-starts
k8s_resource('migration', trigger_mode=TRIGGER_MODE_MANUAL, auto_init=False)

# Skip startup run, but auto-update on file changes (e.g. test runner)
local_resource('tests', cmd='go test ./...', trigger_mode=TRIGGER_MODE_AUTO, auto_init=False)

# Set Manual as the project-wide default
trigger_mode(TRIGGER_MODE_MANUAL)
```
