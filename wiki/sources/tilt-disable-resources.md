---
title: "Tilt: Disabling Resources at Runtime"
tags: [tilt, resources, devtools, workflow]
sources: [tilt-disable-resources]
updated: 2026-07-01
---

# Tilt: Disabling Resources at Runtime

Available since [[tilt]] **v0.24.0**. Lets you stop, hide, or selectively run resources without restarting Tilt or editing your [[tiltfile]].

**Disabling** a resource stops its running process and deletes any objects it owns — equivalent to `tilt down` scoped to that resource. **Enabling** creates, builds, deploys, and starts it again.

## Methods

### 1. `tilt args` (startup scope)

Pass resource names on the command line. Named resources are enabled; everything else is disabled but still visible in the UI.

```bash
# start with only 'frontend' and 'glitch' enabled
tilt up frontend glitch

# later, switch to a different set
tilt args bounding-box muxer max-object-detector
```

Run `tilt args` with no arguments to open the current args for interactive editing.

> Note: if the args list doesn't change between edits, Tilt treats it as a no-op — even if you toggled resources through the UI in the meantime.

See [[tilt-tiltfile-config]] for defining named groups via the config API.

### 2. Tilt UI

**Detail View** — "Disable Resource" button near a resource's logs. Logs remain visible after disabling; an "Enable Resource" button replaces it.

**Table View** — select multiple resources via checkboxes, then use the bulk action buttons (Enable / Disable) that appear above the table.

Disabled resources sort to the bottom of their group (see [[tiltfile]] resource labels / resource groups) in both views.

> Note: UI enable/disable does **not** cascade through dependencies. Disabling resource A while resource B depends on it leaves B running.

### 3. `tilt enable` / `tilt disable` CLI

```bash
# enable specific resources
tilt enable frontend storage

# enable only these two, disable everything else
tilt enable --only frontend storage

# enable all
tilt enable --all

# disable specific resources
tilt disable frontend storage

# disable all
tilt disable --all
```

### 4. Tiltfile (`config` built-ins)

Use the `config` API to set programmatic defaults. See [[tilt-tiltfile-config]] for full examples.

```python
# start Tilt with every resource disabled
config.clear_enabled_resources()
```

This is useful when your catalog is large and developers should opt-in to only the resources they need.

## Behaviour Summary

| Action                             | Effect                                                    |
| ---------------------------------- | --------------------------------------------------------- |
| Disable                            | Stops process, deletes owned objects                      |
| Enable                             | Creates, builds, deploys, starts process                  |
| `tilt args`                        | Sets enabled set at startup; UI changes don't update args |
| UI toggle                          | Immediate; no dependency propagation                      |
| `tilt enable/disable`              | CLI control over running session                          |
| `config.clear_enabled_resources()` | Default-off for all resources                             |

## Related

- [[tilt]] — core overview
- [[tilt-control-loop]] — how Tilt continuously reconciles resource state
- [[tilt-tiltfile-config]] — config API, groups, and examples for `tilt args`
- [[tiltfile]] — where resources are declared
