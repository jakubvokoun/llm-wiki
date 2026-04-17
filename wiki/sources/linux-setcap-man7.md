---
title: "setcap(8) Man Page"
tags: [linux, capabilities, setcap, tools]
sources: [linux-setcap-man7.md]
updated: 2026-04-16
---

# setcap(8) — Set File Capabilities

Part of the **libcap** package.

## Synopsis

```
setcap [-q] [-n <rootuid>] [-v] {capabilities|-|-r} filename [...]
```

## Options

| Option         | Effect                                                             |
| -------------- | ------------------------------------------------------------------ |
| `capabilities` | Set the file capability string (cap_text_formats(7) syntax)        |
| `-`            | Read capability string from stdin (terminated by blank line)       |
| `-r`           | Remove capability set from file                                    |
| `-v`           | Verify: check that the file already has the specified capabilities |
| `-n <rootuid>` | Set for use only in a user namespace with this root UID            |
| `-q`           | Quiet mode                                                         |
| `-f`           | Force completion even for invalid operations                       |

## Important note: remove vs empty

`-r` removes the xattr entirely. Setting an **empty** capability set (`=`) is
different — an empty set prevents a binary from executing with privilege even
when the process has ambient+inheritable capabilities. Note: this root
suppression was reverted for the root user identity itself; for full
suppression use `capsh --mode`.

## Exit code

- `0` on success, `1` on failure.

## Capability string format

See `cap_text_formats(7)`. Examples:

```bash
setcap cap_net_raw+ep /usr/bin/fping
setcap cap_net_bind_service,cap_dac_override+ep /usr/bin/myapp
setcap -r /usr/bin/myapp   # remove all capabilities
```

## See also

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [getcap(8)](linux-getcap-man7.md)
- [capsh(1), cap_from_text(3), capabilities(7), user_namespaces(7)]
