---
title: "Tilt's Control Loop"
tags: [tilt, control-loop, kubernetes, developer-tooling]
sources: [tilt-control-loop]
updated: 2026-07-01
---

# Tilt's Control Loop

Official docs: <https://docs.tilt.dev/controlloop.html>

An overview of how [[tilt]] goes from a [[tiltfile]] to services running live in [[kubernetes]]. For a deeper conceptual treatment see [[tilt-control-loop]].

## Resources

A **resource** is the fundamental unit of work in Tilt — anything displayed in the Tilt sidebar. Resources come in three flavours:

| Resource type | What it contains                                                             |
| ------------- | ---------------------------------------------------------------------------- |
| Image + YAML  | A [[docker]] image build plus [[kubernetes]] manifests (e.g. a microservice) |
| YAML only     | Kubernetes manifests with no image build (e.g. a database)                   |
| Local command | A command that runs on localhost (e.g. a code-generation script)             |

Tilt groups related work automatically: if a `docker_build` target and a YAML manifest both reference the same image name, Tilt heuristically merges them into one resource.

## Tiltfile Execution

The [[tiltfile]] is a [[starlark]] (Python dialect) script. Key points:

- **Declarative, not imperative.** Functions like `k8s_yaml` and `docker_build` _register_ information — they do not apply anything to the cluster immediately.
- At the end of execution, Tilt packages the registered information into resource definitions and hands them to the Tilt engine.
- Tilt watches the Tiltfile and all files that feed into it; any relevant change triggers a full re-evaluation and resource-definition update.

## Applying Resources

Once resource definitions reach the engine, Tilt executes them according to type:

1. **Local resource** → run the command on localhost.
2. **Image present** → build the [[docker]] image.
3. **Kubernetes YAML present** → deploy/apply to the [[kubernetes]] cluster.
4. **Live update configured** → modify the running container in place instead of a full rebuild (see [[tilt-live-update]]).

## Triggering Events

Tilt re-executes a resource whenever one of three events fires:

| Event             | Description                                           |
| ----------------- | ----------------------------------------------------- |
| Definition change | The resource's configuration in the Tiltfile changed  |
| File change       | A file the resource watches was modified              |
| Manual trigger    | The user explicitly triggers the resource from the UI |

File dependencies can be **explicit** (declared in the Tiltfile) or **implicit** (Tilt infers that files inside a `docker_build` context directory affect that resource).

## Control-Loop Summary

```
Execute Tiltfile → create resource definitions
      ↓
Tiltfile changes? → re-execute → update definitions
      ↓
Engine executes resources → services running in cluster
      ↓
Triggering event fires? → re-execute affected resource → repeat
```
