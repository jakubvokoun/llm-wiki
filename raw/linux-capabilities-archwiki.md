# Capabilities — ArchWiki

Capabilities (POSIX 1003.1e, capabilities(7)) provide fine-grained control over superuser permissions, allowing use of the root user to be avoided. Software developers are encouraged to replace uses of the powerful setuid attribute in a system binary with a more minimal set of capabilities. Many packages make use of capabilities, such as `CAP_NET_RAW` being used for fping. This enables `fping` to be run by a normal user (as with the setuid method), while at the same time limiting the security consequences of a potential vulnerability in `fping`.

## Implementation

Capabilities are implemented on Linux using extended attributes (xattr(7)) in the *security* namespace. Extended attributes are supported by all major Linux file systems, including Ext2, Ext3, Ext4, Btrfs, JFS, XFS, and Reiserfs. The following example prints the capabilities of fping with `getcap`, and then prints the same data in its encoded form using `getfattr`:

```
$ getcap /usr/bin/fping
/usr/bin/fping cap_net_raw=ep

$ getfattr --dump --match="^security\." /usr/bin/fping
# file: usr/bin/fping
security.capability=0sAQAAAgAgAAAAAAAAAAAAAAAAAAA=
```

Some programs copy extended attributes automatically, while others require a special flag.

Capabilities are set by package install scripts on Arch, e.g. fping.install.

## Administration and maintenance

It is considered a bug if a package has overly permissive capabilities, so these cases should be reported rather than listed here. A capability essentially equivalent to root access (`CAP_SYS_ADMIN`) or trivially allowing root access (`CAP_DAC_OVERRIDE`) does not count as a bug since Arch does not support any MAC/RBAC systems.

**Warning:** Many capabilities enable trivial privilege escalation. For examples and explanations see Brad Spengler's post [False Boundaries and Arbitrary Code Execution](https://forums.grsecurity.net/viewtopic.php?f=7&t=2522).

## Other programs that benefit from capabilities

The following packages do not have files with the setuid attribute but require root privileges to work. By enabling some capabilities, regular users can use the program without privilege elevation.

The `+ep` behind the capabilities indicate the capability sets *effective* and *permitted*, more information can be found at capabilities(7) § File capabilities.

| program | Command (run as root) |
| --- | --- |
| Beep | `setcap cap_dac_override,cap_sys_tty_config+ep /usr/bin/beep` |
| chvt(1) | `setcap cap_dac_read_search,cap_sys_tty_config+ep /usr/bin/chvt` |
| iftop(8) | `setcap cap_net_raw+ep /usr/bin/iftop` |
| mii-tool(8) | `setcap cap_net_admin+ep /usr/bin/mii-tool` |
| nethogs(8) | `setcap cap_net_admin,cap_net_raw+ep /usr/bin/nethogs` |
| wavemon(1) | `setcap cap_net_admin+ep /usr/bin/wavemon` |

Some packaged binaries, like mtr(8), are already configured with needed capabilities via `.install` files.

## Useful commands

Find setuid-root files:

```
$ find /usr/bin /usr/lib -perm /4000 -user root
```

Find setgid-root files:

```
$ find /usr/bin /usr/lib -perm /2000 -group root
```

## Running a program with temporary capabilities

Using capsh(1) it is possible to run a program with some specific capabilities without modifying the extended attributes of the binary. The following example shows how to attach to a process using GDB using the `CAP_SYS_PTRACE` capability:

```
$ sudo -E capsh --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_sys_ptrace+eip" --keep=1 --user="$USER" --addamb="cap_sys_ptrace" --shell=/usr/bin/gdb -- -p <pid>
```

An example of binding to a low port using netcat, in this case 123:

```
$ sudo -E capsh --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_net_bind_service+eip" --keep=1 --user="$USER" --addamb="cap_net_bind_service" --shell=/usr/bin/nc -- -lvtn 123
Listening on 0.0.0.0 123
```

## systemd

Using `AmbientCapabilities` and `CapabilityBoundingSet`, it is possible to assign capabilities to systemd units, which is much more safe than setting capabilities on binaries. See systemd.exec(5).

## See also

- Man pages: capabilities(7), setcap(8), getcap(8)
- [Wikibooks:Grsecurity/Appendix/Capability Names and Descriptions](https://en.wikibooks.org/wiki/Grsecurity/Appendix/Capability_Names_and_Descriptions)
- [Seccomp BPF (SECure COMPuting with filters)](https://docs.kernel.org/userspace-api/seccomp_filter.html)
