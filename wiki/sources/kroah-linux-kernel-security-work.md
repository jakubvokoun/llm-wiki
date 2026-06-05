---
title: "Linux kernel security work (kroah.com)"
tags: [linux-kernel, security, cve, embargo, disclosure]
sources: [kroah-linux-kernel-security-work.md]
updated: 2026-06-05
---

# Linux kernel security work

Greg Kroah-Hartman explains how the Linux kernel **security team** actually operates — reactive bug-fixing with deliberately **no announcements** — and why it is a separate group from the kernel **CVE team**. Part of his series on the [Linux kernel CVE release process](kroah-linux-cves-overview.md).

## tl;dr

- The security team fixes reported issues fast, merges to public trees, and announces nothing.
- Security team and [CVE team](kroah-linux-cve-assignment-process.md) are **different people**, all acting as individuals, not on behalf of employers.
- Send plain-text email only; do not expect a CVE from emailing the security team.

## How it works

- **Reactive, not proactive:** distinct from the proactive [Kernel Self-Protection Project](https://kspp.github.io/). Reports go to the documented [security-bugs](https://www.kernel.org/doc/html/latest/process/security-bugs.html) alias.
- **Plain text, no encryption:** the alias is one-address-to-many, so PGP doesn't work. GKH pushes back on governments (UK) forcing encryption as counterproductive.
- **Independence:** members cannot tell their employer anything discussed before resolution. This keeps the team operable across governments — and GKH frames it as the model project security teams will need under the EU [CRA](../concepts/cyber-resilience-act.md).
- **No embargoes > 7 days:** once a fix exists there's no reason to hold it. Very few changes get any embargo.
- **No pre-announcement list:** repeatedly requested by companies, repeatedly refused — any such list "should always be considered public and contain leaks."

## "A bug is a bug is a bug"

The no-marking policy traces to a 2008 Linus Torvalds thread: marking security fixes is "pointless and wrong because it makes people think that other bugs aren't potential security fixes." Because the kernel is open source, developers **don't know how you use it** — a trivial bugfix for one user is a critical vulnerability fix for another. Policy reduces to: fix known bugs ASAP, ship releases to users ASAP.

## Hardware security issues

Cross-vendor hardware bugs ([Spectre](https://en.wikipedia.org/wiki/Spectre_%28security_vulnerability%29)/[Meltdown](https://en.wikipedia.org/wiki/Meltdown_%28security_vulnerability%29)) break the no-embargo model, so a separate [embargoed-hardware-issues](https://www.kernel.org/doc/html/latest/process/embargoed-hardware-issues.html) process exists with a restricted encrypted list. GKH calls it "clunky, awkward, and often extremely slow," and notes CRA timelines may make long hardware embargoes impossible.

## Origin

Pre-2005 there was no official contact path — just an ad-hoc group. A 2005 thread (Steve Bergman → 36 emails) led Chris Wright to add the security contact + `Documentation/SecurityBugs` to the tree.

## Related

- [Greg Kroah-Hartman](../entities/greg-kroah-hartman.md)
- [Linux CVE assignment process](kroah-linux-cve-assignment-process.md)
- [Cyber Resilience Act](../concepts/cyber-resilience-act.md)
- [Vulnerability Disclosure](../concepts/vulnerability-disclosure.md)
