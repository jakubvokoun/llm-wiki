# Checklist - Linux Privilege Escalation

## Best tool to look for Linux local privilege escalation vectors: LinPEAS

### System Information

* [ ] Get **OS information**
* [ ] Check the **PATH**, any **writable folder**?
* [ ] Check **env variables**, any sensitive detail?
* [ ] Search for **kernel exploits** **using scripts** (DirtyCow?)
* [ ] **Check** if the **sudo version** is vulnerable
* [ ] **Dmesg** signature verification failed
* [ ] More system enum (date, system stats, cpu info, printers)
* [ ] Enumerate more defenses

### Drives

* [ ] **List mounted** drives
* [ ] **Any unmounted drive?**
* [ ] **Any creds in fstab?**

### Installed Software

* [ ] **Check for** **useful software** **installed**
* [ ] **Check for** **vulnerable software** **installed**

### Processes

* [ ] Is any **unknown software running**?
* [ ] Is any software running with **more privileges than it should have**?
* [ ] Search for **exploits of running processes** (especially the version running).
* [ ] Can you **modify the binary** of any running process?
* [ ] **Monitor processes** and check if any interesting process is running frequently.
* [ ] Can you **read** some interesting **process memory** (where passwords could be saved)?

### Scheduled/Cron jobs?

* [ ] Is the **PATH** being modified by some cron and you can **write** in it?
* [ ] Any **wildcard** in a cron job?
* [ ] Some **modifiable script** is being **executed** or is inside **modifiable folder**?
* [ ] Have you detected that some **script** could be or are being **executed** very **frequently**? (every 1, 2 or 5 minutes)

### Services

* [ ] Any **writable .service** file?
* [ ] Any **writable binary** executed by a **service**?
* [ ] Any **writable folder in systemd PATH**?
* [ ] Any **writable systemd unit drop-in** in `/etc/systemd/system/<unit>.d/*.conf` that can override `ExecStart`/`User`?

### Timers

* [ ] Any **writable timer**?

### Sockets

* [ ] Any **writable .socket** file?
* [ ] Can you **communicate with any socket**?
* [ ] **HTTP sockets** with interesting info?

### D-Bus

* [ ] Can you **communicate with any D-Bus**?

### Network

* [ ] Enumerate the network to know where you are
* [ ] **Open ports you couldn't access before** getting a shell inside the machine?
* [ ] Can you **sniff traffic** using `tcpdump`?

### Users

* [ ] Generic users/groups **enumeration**
* [ ] Do you have a **very big UID**? Is the **machine** **vulnerable**?
* [ ] Can you **escalate privileges thanks to a group** you belong to?
* [ ] **Clipboard** data?
* [ ] Password Policy?
* [ ] Try to **use** every **known password** that you have discovered previously to login **with each** possible **user**. Try to login also without a password.

### Writable PATH

* [ ] If you have **write privileges over some folder in PATH** you may be able to escalate privileges

### SUDO and SUID commands

* [ ] Can you execute **any command with sudo**? Can you use it to READ, WRITE or EXECUTE anything as root? (**GTFOBins**)
* [ ] If `sudo -l` allows `sudoedit`, check for **sudoedit argument injection** (CVE-2023-22809) via `SUDO_EDITOR`/`VISUAL`/`EDITOR` to edit arbitrary files on vulnerable versions (`sudo -V` < 1.9.12p2). Example: `SUDO_EDITOR="vim -- /etc/sudoers" sudoedit /etc/hosts`
* [ ] Is any **exploitable SUID binary**? (**GTFOBins**)
* [ ] Are **sudo** commands **limited** by **path**? can you **bypass** the restrictions?
* [ ] **Sudo/SUID binary without path indicated**?
* [ ] **SUID binary specifying path**? Bypass
* [ ] **LD_PRELOAD vuln**
* [ ] **Lack of .so library in SUID binary** from a writable folder?
* [ ] **SUDO tokens available**? Can you create a SUDO token?
* [ ] Can you **read or modify sudoers files**?
* [ ] Can you **modify /etc/ld.so.conf.d/**?
* [ ] **OpenBSD DOAS** command

### Capabilities

* [ ] Has any binary any **unexpected capability**?

### ACLs

* [ ] Has any file any **unexpected ACL**?

### Open Shell sessions

* [ ] **screen**
* [ ] **tmux**

### SSH

* [ ] **Debian** **OpenSSL Predictable PRNG - CVE-2008-0166**
* [ ] **SSH Interesting configuration values**

### Interesting Files

* [ ] **Profile files** - Read sensitive data? Write to privesc?
* [ ] **passwd/shadow files** - Read sensitive data? Write to privesc?
* [ ] **Check commonly interesting folders** for sensitive data
* [ ] **Weird Location/Owned files,** you may have access to or alter executable files
* [ ] **Modified** in last mins
* [ ] **Sqlite DB files**
* [ ] **Hidden files**
* [ ] **Script/Binaries in PATH**
* [ ] **Web files** (passwords?)
* [ ] **Backups**?
* [ ] **Known files that contains passwords**: Use **Linpeas** and **LaZagne**
* [ ] **Generic search**

### Writable Files

* [ ] **Modify python library** to execute arbitrary commands?
* [ ] Can you **modify log files**? **Logtotten** exploit
* [ ] Can you **modify /etc/sysconfig/network-scripts/**? Centos/Redhat exploit
* [ ] Can you **write in ini, int.d, systemd or rc.d files**?

### Other tricks

* [ ] Can you **abuse NFS to escalate privileges**?
* [ ] Do you need to **escape from a restrictive shell**?

## References

* [Sudo advisory: sudoedit arbitrary file edit](https://www.sudo.ws/security/advisories/sudoedit_any/)
* [Oracle Linux docs: systemd drop-in configuration](https://docs.oracle.com/en/operating-systems/oracle-linux/8/systemd/ModifyingsystemdConfigurationFiles.html)
