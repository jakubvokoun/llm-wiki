---
title: "HackTricks: euid, ruid, suid"
tags: [linux-hardening, privilege-escalation, suid, linux-internals]
sources: [hacktricks-euid-ruid-suid.md]
updated: 2026-05-01
---

# HackTricks: euid, ruid, suid

Source: [hacktricks-euid-ruid-suid.md](../../raw/hacktricks-euid-ruid-suid.md)

## Key Takeaways

Three user ID types control Linux process privileges:

- **`ruid`** (real UID): who launched the process
- **`euid`** (effective UID): what privileges the kernel checks — normally equals ruid, but changes on SetUID binary execution
- **`suid`** (saved UID): preserved copy of euid before privilege drop, allowing processes to reclaim elevated status

Non-root processes can only set `euid` to their current `ruid`, `euid`, or `suid`. Root (or `CAP_SETUID`) can set any value.

## setuid Functions

| Function                      | Effect                                                                               |
| ----------------------------- | ------------------------------------------------------------------------------------ |
| `setuid(uid)`                 | For root: sets ruid+euid+suid all to `uid` (permanent). For non-root: sets euid only |
| `setreuid(ruid, euid)`        | Sets ruid and euid independently; non-root restricted to current values              |
| `setresuid(ruid, euid, suid)` | Full control of all three; same restrictions apply                                   |

## execve vs system with SUID

| Mechanism  | User ID behavior                                                                       |
| ---------- | -------------------------------------------------------------------------------------- |
| `execve`   | ruid unchanged; euid updated if SetUID bit set; suid ← euid                            |
| `system()` | Creates child, runs `execl("/bin/sh", "sh", "-c", cmd)` — subject to bash's euid reset |

## bash/sh Behavior with SUID

**bash without `-p`**: if `euid ≠ ruid` at startup, bash resets `euid` to `ruid`. This is why `setuid(1000) + execve("/bin/bash")` drops to ruid identity.

**bash with `-p`**: preserves the initial `euid`. Use when a SUID binary needs to maintain the elevated identity through a bash exec.

**sh**: no equivalent of `-p`; behavior varies.

## Practical Implications for SUID Exploitation

```c
// setuid + system → bash resets euid to ruid (uid=nobody, not frank)
setuid(1000); system("id");         // uid=nobody

// setreuid + system → both IDs equal, bash keeps them
setreuid(1000, 1000); system("id"); // uid=frank

// setuid + execve → euid is set, but bash resets it
setuid(1000); execve("/bin/bash", NULL, NULL); // uid=nobody

// setuid + execve with bash -p → euid preserved
char *args[] = {"/bin/bash", "-p", NULL};
setuid(1000); execve(args[0], args, NULL); // euid=frank
```

The key pattern: **always use `setreuid(target, target)` + `system()`** or **`execve` with `bash -p`** when a SUID exploit needs to maintain the target uid across shell invocation.

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
