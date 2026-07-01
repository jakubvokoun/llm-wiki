---
title: "Tilt Tutorial: First Look Overview"
tags: [tilt, tutorial, kubernetes, docker]
sources: [tilt-tutorial-overview]
updated: 2026-07-01
---

# Tilt Tutorial: First Look Overview

Introduction page for the official Tilt tutorial series, using the
[`tilt-avatars`](https://github.com/tilt-dev/tilt-avatars) sample project as a
running example.

## Tutorial Structure

| #   | Section                         | Key Topic                                                            |
| --- | ------------------------------- | -------------------------------------------------------------------- |
| 1   | Preparation (Optional)          | Install Tilt, [[docker]], and clone sample project                   |
| 2   | Launching & Managing Resources  | `tilt up` and the [[tilt-control-loop]]                              |
| 3   | Tilt UI                         | Log aggregation and dev-environment status dashboard                 |
| 4   | Code. Update. Repeat.           | Incremental rebuilds — right thing at the right time                 |
| 5   | Smart Rebuilds with Live Update | [[tilt-live-update]] for hot reload without native framework support |

## Key Concepts Introduced

- **`tilt up`** — primary CLI command that starts the [[tilt]] control loop and
  opens the UI.
- **[[tilt-control-loop]]** — Tilt's watch-build-deploy cycle that reacts to
  file changes automatically.
- **[[tilt-live-update]]** — sync file changes into a running container and
  trigger in-process reload steps, avoiding full image rebuilds.
- **[[tiltfile]]** — project configuration file (written in [[starlark]]) that
  defines resources, build rules, and live-update specs.

## Sample Project

- Repo: `tilt-dev/tilt-avatars` on GitHub
- Used throughout all tutorial sections; can be followed interactively or read
  as reference.

## Prerequisites (Section 1 Summary)

- Tilt CLI installed
- [[docker]] running locally (or a remote [[kubernetes]] cluster)
- Sample project source checked out

Estimated setup time: under 10 minutes.

## What Comes After

The tutorial leads into the
[Write a Tiltfile Guide](https://docs.tilt.dev/tiltfile_authoring.html), which
applies tutorial concepts to authoring a [[tiltfile]] from scratch for a real
project.

## Related Pages

- [[tilt]] — core tool reference
- [[tiltfile]] — configuration file format
- [[tilt-control-loop]] — watch/build/deploy cycle details
- [[tilt-live-update]] — file sync and in-process reload
- [[tilt-extensions]] — reusable Tiltfile helpers
- [[tilt-tutorial-1-prerequisites]] — tutorial section 1 detail
