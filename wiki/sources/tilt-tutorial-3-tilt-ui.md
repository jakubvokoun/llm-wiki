---
title: "Tilt UI — Tutorial Part 3"
tags: [tilt, ui, developer-experience, kubernetes]
sources: [tilt-tutorial-3-tilt-ui]
updated: 2026-07-01
---

# Tilt UI — Tutorial Part 3

Reference: [Tilt Tutorial Part 3](https://docs.tilt.dev/tutorial/3-tilt-ui.html). Covers the web UI that [[tilt]] provides for monitoring and controlling your multi-service dev environment.

## Launching the UI

- Press `(Spacebar)` in the terminal running `tilt demo` (or `tilt up`) to open the browser automatically.
- Alternatively, use the URL printed in the terminal output.

## Resource Overview

The default landing page. Return to it anytime by clicking the Tilt logo (upper left).

| Column         | Description                                                                                    |
| -------------- | ---------------------------------------------------------------------------------------------- |
| Update status  | Result of the last build/deploy cycle (image build + `kubectl apply` for Kubernetes resources) |
| Runtime status | Live Pod state — reflects readiness checks                                                     |
| Pod ID         | One-click copy to clipboard for use with `kubectl`                                             |
| Widgets        | [[tilt-custom-buttons]] configured for the resource (unit tests, lint, etc.)                   |
| Endpoints      | Clickable links for all Tilt-managed port-forwards; custom external URLs can be added too      |
| Trigger mode   | Per-resource toggle between automatic (file-watch) and manual update modes                     |

Resources are grouped by their **resource labels** (set in the [[tiltfile]] via `resource_group` or label arguments).

## Trigger Mode

- Default: automatic — Tilt rebuilds/redeploys whenever a watched file changes (see [[tilt-control-loop]]).
- Per-resource or global manual mode is configured in the Tiltfile with `trigger_mode()` / `manual_update_control`.
- The UI toggle lets you pause/resume automatic updates without touching the Tiltfile.
- A resource in manual mode can always be updated on-demand via the **Trigger Update** (↻) button.

## Resource Details View

Click any resource row to drill into its detail view. Central focus is **logs**; all overview info (buttons, endpoints, Pod ID) is also present.

- **"All Resources"** link in the navbar: shows interleaved logs from every service simultaneously.

### Log Filtering

| Filter          | How to use                                                                                                               |
| --------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Source          | Restrict to build/update logs OR runtime logs (not both)                                                                 |
| Level           | Show only errors and warnings collected from Docker, Kubernetes events, etc.; click `... (more)` for surrounding context |
| Keyword / Regex | Non-destructive filter; type a keyword or regex to narrow the live log stream                                            |

## Custom Buttons (Widgets)

- Configured in the Tiltfile; see [[tilt-custom-buttons]] and the [buttons docs](https://docs.tilt.dev/buttons.html).
- Support parameterized inputs.
- Log output goes to the relevant resource's log stream — no terminal switching needed.
- Typical uses: run unit tests, linters, migrations, or any one-off task.

## Design Philosophy

- Unobtrusive by default — runs in the background, surfaces only when something needs attention.
- Aims to unify the multi-service development experience without requiring constant context-switching.
