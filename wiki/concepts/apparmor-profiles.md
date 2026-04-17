---
title: "AppArmor Profiles"
tags: [apparmor, profiles, mac, linux, containers]
sources:
  [apparmor-archwiki.md, docker-apparmor.md, apparmor-core-policy-reference.md]
updated: 2026-04-16
---

# AppArmor Profiles

An [AppArmor](../entities/apparmor.md) profile is a per-application security
policy that defines a whitelist of allowed system resources. The kernel enforces
the profile whenever the confined binary runs.

## Profile location and format

Profiles are human-readable text files in `/etc/apparmor.d/`. Convention:
filename mirrors the binary path with `/` replaced by `.` (e.g.,
`usr.bin.nginx`).

Minimal structure:

```
#include <tunables/global>

profile <name> [/path/to/binary] [flags=(...)] {
    #include <abstractions/base>

    # File access rules
    /path/to/resource  <access_modes>,

    # Capability rules
    capability <name>,

    # Network rules
    network <domain> <type>,

    # Deny rules (override allows, enforced even in complain mode)
    deny /sensitive/path rwklx,
}
```

## Access modes

| Mode | Permission                                                    |
| ---- | ------------------------------------------------------------- |
| `r`  | Read                                                          |
| `w`  | Write (create, delete, modify)                                |
| `m`  | Memory-map executable                                         |
| `x`  | Execute (qualifier required: `ix`, `px`, `ux`, `cx`, `Px`, …) |
| `l`  | Hard link                                                     |
| `k`  | File lock                                                     |

Execute qualifiers:

| Qualifier | Meaning                                         |
| --------- | ----------------------------------------------- |
| `ix`      | Inherit profile (child runs under same profile) |
| `px`      | Transition to child's own profile (must exist)  |
| `ux`      | Unconfined execute (dangerous — avoid)          |
| `cx`      | Transition to locally-defined child profile     |

## Profile modes

| Mode         | Violations                                 |
| ------------ | ------------------------------------------ |
| **enforce**  | Blocked + logged                           |
| **complain** | Logged only (but `deny` rules still block) |

Load in enforce mode: `apparmor_parser -a /etc/apparmor.d/<profile>`
Load in complain mode: `apparmor_parser -C /etc/apparmor.d/<profile>`

## deny rules

- Always take precedence over `allow` rules
- Enforced in **both** enforce and complain mode
- Used in abstractions to protect sensitive paths regardless of profile
- Silence `aa-logprof` prompts for known-safe denials

## Variables and abstractions

```
@{HOME}         → /home/*/ /root/
@{PROC}         → /proc/
@{MULTIARCH}    → *-linux-gnu*/
```

`#include <abstractions/base>` — minimal rules for shared libraries, locales,
NSS.

## Globbing

AppArmor uses bash-like but distinct path globbing:

| Pattern | Matches                                    |
| ------- | ------------------------------------------ |
| `*`     | Any chars at one directory level (no `/`)  |
| `**`    | Any chars across multiple directory levels |
| `?`     | Single char (no `/`)                       |
| `{a,b}` | Alternation                                |
| `[]`    | Character class                            |

## Profile language versions

- **v2.x** — implicit permissions (e.g., `CAP_SYS_ADMIN` implicitly allows mount)
- **v3.x** — all permissions explicit; safer and more precise

## Docker integration

Docker auto-generates `docker-default` for all containers unless overridden:

```bash
docker run --security-opt apparmor=my-profile myimage
```

See [Docker AppArmor Profiles](../sources/docker-apparmor.md) for a full Nginx
example and debugging guidance.

## Profile development workflow

1. `aa-genprof <binary>` — generate initial profile in complain mode
2. Exercise the application
3. `aa-logprof` — review violations, add allow rules
4. Test → repeat step 2–3 until clean
5. `aa-enforce /etc/apparmor.d/<profile>` — switch to enforce

## See also

- [AppArmor](../entities/apparmor.md)
- [Mandatory Access Control](mandatory-access-control.md)
- [Linux Capabilities](linux-capabilities.md)
- [Container Security](container-security.md)
- [AppArmor — Arch Wiki](../sources/apparmor-archwiki.md)
- [AppArmor Core Policy Reference](../sources/apparmor-core-policy-reference.md)
