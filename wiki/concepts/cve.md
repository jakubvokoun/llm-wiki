---
title: "CVE (Common Vulnerabilities and Exposures)"
tags: [cve, vulnerability, identifier, cve-org, nvd, purl, cpe]
sources:
  [
    kroah-linux-cve-assignment-process.md,
    kroah-linux-cves-overview.md,
    cisa-coordinated-vulnerability-disclosure.md,
  ]
updated: 2026-06-05
---

# CVE (Common Vulnerabilities and Exposures)

The industry-standard identifier system for publicly disclosed software/hardware vulnerabilities, run by the **CVE Program** (cve.org, MITRE-operated, US-government-sponsored). Each CVE record names a vulnerability so tools and humans can reference it unambiguously.

## How a CVE comes to exist

- IDs are issued by **[CVE Numbering Authorities](cve-numbering-authority.md)** (CNAs) within their scope.
- A record documents affected products, versions/ranges, references, and (sometimes) severity.
- **cve.org's definition of a vulnerability**: a weakness in a product that can be exploited to negatively impact confidentiality, integrity, or availability — the definition a CNA must follow.

## Record quality issues (from the Linux CNA experience)

- **Ranges, not scalars** — good records encode exact git/version ranges; consumers must walk the version graph, not do `<`/`>` comparisons. ([Why Linux versioning breaks naive comparison](../sources/kroah-linux-kernel-version-numbers.md).)
- **CPE is near-useless** for range checking; **[PURL](https://github.com/package-url/purl-spec)** is better but doesn't yet support self-hosted projects (Linux, GNOME, glibc, …).
- **NVD enrichment** (esp. [CVSS](cvss.md) scores) is contested — the Linux CNA tells users to ignore third-party severity scores on kernel CVEs.
- **Volume** — the Linux kernel CNA alone issues ~60 CVEs/week, forcing **machine-parseable, automation-first** records.

## Related

- [CVE Numbering Authority](cve-numbering-authority.md) · [CVSS](cvss.md)
- [Vulnerability Disclosure](vulnerability-disclosure.md) · [Vulnerability Handling](vulnerability-handling.md)
- Sources: [Linux CVE assignment process](../sources/kroah-linux-cve-assignment-process.md) · [CISA CVD](../sources/cisa-coordinated-vulnerability-disclosure.md)
