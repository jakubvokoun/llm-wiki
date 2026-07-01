---
title: "Tilt Control Loop"
tags: [tilt, architecture, kubernetes, reconciliation]
sources:
  [tilt-control-loop, tilt-tutorial-4-code-update-repeat, tilt-file-changes]
updated: 2026-07-01
---

# Tilt Control Loop

The **control loop** is [[tilt|Tilt]]'s reconciliation engine: it continuously drives the cluster toward the state declared in the [[tiltfile|Tiltfile]], so the most current code and configuration are always running.

## Resources

A **resource** is any bundle of work Tilt manages — what the sidebar in the [[tilt-tutorial-3-tilt-ui|Tilt UI]] shows. A resource can be:

- a container image to build **plus** [[kubernetes]] YAML to deploy (a microservice), or
- just YAML to deploy (e.g. a database), or
- a local command to run ([[tilt-local-resource]]).

## The flow

1. **Execute the Tiltfile** in full to build resource definitions (some explicit, some assembled by heuristics).
2. **Re-execute** the Tiltfile whenever it or its inputs change.
3. **Execute resources**: run local commands, build images ([[docker]] or [[tilt-custom-build|custom builders]]), deploy YAML. When configured, [[tilt-live-update]] patches a running container in place instead of rebuilding.
4. **Watch for triggering events** and re-run affected resources: a resource's definition changing, a relevant file changing ([[tilt-file-changes]]), or a user manually triggering it ([[tilt-manual-update-control]]).

Tilt knows which files a resource "cares about" both **explicitly** (`resource_deps`, declared paths — see [[tilt-resource-dependencies]]) and **implicitly** (a `docker_build` context directory).

This model is what makes Tilt debuggable and extensible — understanding it helps diagnose why a resource did or didn't update.
