---
title: "Tilt Telemetry FAQ"
tags: [tilt, telemetry, privacy]
sources: [tilt-telemetry-faq]
updated: 2026-07-01
---

# Tilt Telemetry FAQ

[[tilt]] collects anonymized usage analytics to understand which features are
used and which bugs are encountered. Analytics are opt-in: on the first web UI
visit, Tilt prompts for a choice.

## Opt-in / Opt-out Controls

| Method              | Command / Setting                      | Precedence |
| ------------------- | -------------------------------------- | ---------- |
| CLI opt-in          | `tilt analytics opt in`                | user pref  |
| CLI opt-out         | `tilt analytics opt out` (+ restart)   | user pref  |
| Env disable         | `export TILT_DISABLE_ANALYTICS="true"` | highest    |
| Do Not Track (std.) | `export DO_NOT_TRACK="1"`              | highest    |
| Tiltfile override   | `analytics_settings(enable=True)`      | team-level |

The **environment variable** overrides everything (including the Tiltfile
setting). The **Tiltfile setting** overrides individual user preferences and is
intended for devtools teams who want to opt in all developers on the team by
default.

## Where Data Goes

Telemetry is sent to Tilt's own ingestion server at `events.windmill.build`.
From there it may be stored in managed services (Google Cloud, Datadog) for
analysis. The data is not sold or shared with advertisers.

## What Is Collected

Tilt records **aggregate usage patterns**, not personal or project-specific
data. Examples of what is captured:

- Which Tiltfile built-ins are invoked and how often (e.g. `docker_build`,
  `default_registry`)
- Web UI interactions
- Command invocations (`tilt up` flags, mode, OS)
- Tilt version, anonymized user ID, anonymized machine ID

### Example payload — `tilt up`

```json
{
  "watch": "true",
  "version": "0.10.18-dev",
  "user": "a62525469776f5b299733bdc95718d47",
  "os": "linux",
  "name": "tilt.cmd.up",
  "mode": "auto",
  "machine": "8c581ff2fc00c6a47ecbd50abe47fb40",
  "git.origin": "3QLdKIWhsYTCsPI0vtsx6Q=="
}
```

### Example payload — Tiltfile load

```json
{
  "version": "0.10.18-dev",
  "user": "a62525469776f5b299733bdc95718d47",
  "tiltfile.invoked.docker_build": "3",
  "tiltfile.invoked.default_registry": "1",
  "os": "linux",
  "name": "tilt.tiltfile.loaded",
  "machine": "8c581ff2fc00c6a47ecbd50abe47fb40",
  "git.origin": "3QLdKIWhsYTCsPI0vtsx6Q=="
}
```

Note that `user` and `machine` are opaque hashes, and `git.origin` is a
base64-encoded hash — not the raw repository URL.

## Privacy Protections: String Hashing

Strings that may reveal project details (repo names, service names, directory
names) are **hashed** before transmission. This is a best-effort protection:

- It is **not foolproof** — some data snippets (e.g. a service named
  `deathray-backend`, or a raw error message) could leak through.
- **Recommendation:** opt out if working on classified or sensitive projects.

## Source

- Raw: `raw/tilt-telemetry-faq.md`
- Origin: <https://docs.tilt.dev/telemetry_faq.html>
