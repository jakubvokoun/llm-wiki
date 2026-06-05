---
title: "Linux is a CNA (kroah.com)"
tags: [linux-kernel, cve, cna, security, kernel-org]
sources: [kroah-linux-is-a-cna.md]
updated: 2026-06-05
---

# Linux is a CNA

Greg Kroah-Hartman's February 2024 announcement that the Linux kernel project was accepted as a [CVE Numbering Authority](../concepts/cve-numbering-authority.md) (CNA) for vulnerabilities found in Linux. From this point the kernel.org community — not outside parties — became responsible for issuing all [CVEs](../concepts/cve.md) for the kernel.

## Key points

- **Self-determination motive:** becoming a CNA stops any other group from assigning kernel CVEs without the kernel community's involvement. Part of a broader trend — [curl](https://daniel.haxx.se/blog/2024/01/16/curl-is-a-cna/) and the Python Software Foundation did the same; [OpenSSF](../entities/openssf.md) and cve.org provided support.
- **Regulatory tailwind:** GKH notes open source projects "might be mandated" to do this work given laws being enacted worldwide — foreshadowing the EU [Cyber Resilience Act](../concepts/cyber-resilience-act.md).
- **Different layer:** the kernel CNA process differs from typical CNAs because the kernel sits at a different layer and serves one of the widest, most varied user bases of any project.
- **Where to track it:** allocated CVEs are announced on the [linux-cve-announce mailing list](https://lore.kernel.org/linux-cve-announce/) and stored in the public [vulns.git](https://git.kernel.org/pub/scm/linux/security/vulns.git/) repository.

This was the first step; the operational detail of how assignment works came in [later posts](kroah-linux-cve-assignment-process.md).

## Related

- [Greg Kroah-Hartman](../entities/greg-kroah-hartman.md)
- [CVE Numbering Authority](../concepts/cve-numbering-authority.md)
- [Linux kernel security work](kroah-linux-kernel-security-work.md)
- [Linux CVE assignment process](kroah-linux-cve-assignment-process.md)
