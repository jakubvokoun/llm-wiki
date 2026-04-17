---
title: "getcap(8) Man Page"
tags: [linux, capabilities, getcap, tools]
sources: [linux-getcap-man7.md]
updated: 2026-04-16
---

# getcap(8) — Examine File Capabilities

Part of the **libcap** package.

## Synopsis

```
getcap [-v] [-n] [-r] [-h] filename [...]
```

## Options

| Option | Effect                                                              |
| ------ | ------------------------------------------------------------------- |
| `-r`   | Recursive search                                                    |
| `-v`   | Display all searched entries, even those with no file capabilities  |
| `-n`   | Print non-zero user namespace root UID associated with capabilities |
| `-h`   | Quick usage help                                                    |

## Common usage

```bash
# Check a single binary
getcap /usr/bin/fping
# → /usr/bin/fping cap_net_raw=ep

# Enumerate all capabilities across filesystem (pentest / audit)
getcap -r / 2>/dev/null
```

## Note on empty capabilities

An empty `=` capability value is **not** the same as no capability. A file
with `=` causes a process with ambient capabilities to lose them on exec (but
this ambient-suppression applies only to non-root processes — the kernel
reverted root suppression). See setcap(8) for details.

## See also

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [setcap(8)](linux-setcap-man7.md)
- [capsh(1), cap_get_file(3), cap_to_text(3), capabilities(7)]
