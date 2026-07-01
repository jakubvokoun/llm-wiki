---
title: "Connecting Debuggers (Python)"
tags: [tilt, debugging, python]
sources: [tilt-debuggers-python]
updated: 2026-07-01
---

# Connecting Debuggers (Python)

Running apps in [[kubernetes|Kubernetes]] makes debuggers harder to attach; [[tilt|Tilt]]'s [[tilt-port-forwards|port forwarding]] makes it easy again. The example uses Python `remote-pdb`, but the pattern applies to remote debuggers in most languages — only the final connect step is tool-specific. Tilt has **no debugger-specific code**; it just provides a standard way to coordinate a debugger with the dev environment.

## Setup

1. **Pick a debugger port** (example: `5555`).
2. **Add the debugger** to `requirements.txt` (e.g. `remote-pdb`).
3. **Expose the port** as a `containerPort` in the Deployment/Pod YAML, alongside the app port:

   ```yaml
   ports:
     - containerPort: 8000 # app
     - containerPort: 5555 # debugger
   ```

4. **Forward the port** in the [[tiltfile|Tiltfile]]:

   ```python
   k8s_resource('example-python', port_forwards=[8000, 5555])
   ```

## Debugging (remote-pdb)

1. Insert a breakpoint in the code:

   ```python
   from remote_pdb import RemotePdb
   RemotePdb('127.0.0.1', 5555).set_trace()
   ```

2. Trip it (hit `localhost:8000`); the request hangs — expected.
3. Connect via TCP, e.g. Netcat: `nc 127.0.0.1 5555`. (A `web-pdb` variant lets you debug in a browser instead.)

**Wait for the debugger:** with `set_trace`, the debugger doesn't start listening until the breakpoint is first hit — connecting earlier just yields errors. For `remote-pdb`, wait for the log line `RemotePdb session open at 127.0.0.1:5555, waiting for connection…`.

## Your own debugger

Not listed? Spin it up with [[tilt-local-resource|local_resource]], then consider packaging it as a [[tilt-extensions|Tilt extension]] for others. Sample code exists for Python (remote-pdb, web-pdb) and NodeJS.

Related: [[tilt]], [[tilt-port-forwards]], [[tilt-example-python]].
