---
title: "HackTricks: Time Namespace"
tags: [container-security, linux-namespaces, linux-hardening]
sources: [hacktricks-time-namespace.md]
updated: 2026-05-01
---

# HackTricks: Time Namespace

Source: [hacktricks-time-namespace.md](../../raw/hacktricks-time-namespace.md)

## Key Takeaways

The time namespace virtualizes `CLOCK_MONOTONIC` and `CLOCK_BOOTTIME` — not `CLOCK_REALTIME`. It is the newest and most specialized namespace. Its primary uses are checkpoint/restore, deterministic testing, and advanced runtime behavior. It is **not** a headline container-escape mechanism.

The time namespace does not falsify the host wall clock or break certificate expiry checks system-wide.

## Lab

```bash
sudo unshare --time --fork bash
ls -l /proc/self/ns/time /proc/self/ns/time_for_children
cat /proc/$$/timens_offsets 2>/dev/null

# Adjust monotonic offset by two days inside the namespace
sudo unshare -Tr --mount-proc bash
echo "monotonic 172800000000000" > /proc/$$/timens_offsets
cat /proc/uptime

# Convenience flags (newer util-linux)
sudo unshare -T --monotonic="+24h" --boottime="+7d" --mount-proc bash
```

## OCI Runtime Support

OCI Runtime Spec v1.1 added explicit `time` namespace support via `linux.timeOffsets`:

```json
{
  "linux": {
    "namespaces": [{ "type": "time" }],
    "timeOffsets": { "monotonic": 86400, "boottime": 600 }
  }
}
```

Newer `runc` implements this field.

## Checks

```bash
readlink /proc/self/ns/time               # time namespace identifier
readlink /proc/self/ns/time_for_children  # inherited by children
cat /proc/$$/timens_offsets 2>/dev/null   # monotonic and boottime offsets
```

## Abuse / Security Impact

- No direct container escape primitive
- Useful for understanding checkpoint/restore artifacts, uptime/logging anomalies
- `CLOCK_REALTIME` is not virtualized — wall clock is unchanged

```bash
readlink /proc/self/ns/time
date
cat /proc/uptime
```

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
