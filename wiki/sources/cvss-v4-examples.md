---
title: "CVSS v4.0 Examples"
tags: [cvss, severity, first, vulnerability, examples, cve]
sources: [cvss-v4-examples.md]
updated: 2026-06-19
---

# CVSS v4.0 Examples

A [FIRST](../entities/first.md) collection of worked [CVSS](../concepts/cvss.md) v4.0 scorings against real CVEs (document v1.7.1), showing vector strings and the reasoning behind each metric choice.

## How it's organized

- **New-metric coverage** — CVEs that exercise the v4.0 additions:
  - **Attack Requirements (AT):** CVE-2022-41741, CVE-2020-3549, CVE-2023-3089
  - **Revised User Interaction:** CVE-2021-44714, CVE-2022-21830
  - **Subsequent System impact (SC/SI/SA):** CVE-2022-22186, CVE-2023-21989, CVE-2020-3947, CVE-2023-48228
  - **Safety (supplemental):** CVE-2023-30560
- **CISA KEV example:** CVE-2026-48172
- **Classic vulnerabilities re-scored under v4.0:** Heartbleed (CVE-2014-0160), Log4Shell (CVE-2021-44228), Shellshock (CVE-2014-6271), Juniper ARP DoS (CVE-2013-6014), ThinkPwn (CVE-2016-5729), Intel DCI (CVE-2018-3652).
- **Vulnerability classes** — a reference set spanning regreSSHion (CVE-2024-6387), SQL injection, on-path attacker, DoS, reflected/stored/expanded-impact XSS, CSRF, privilege escalation (un/highly privileged), RCE/ACE (Spring4Shell CVE-2022-22965), physical access, information disclosure, command injection, ACL bypass, [SSRF](../concepts/ssrf.md) (CVE-2024-1233), and ICS.

## Why it's useful

The class-by-class section is the practical lookup: it shows the canonical vector for common bug types (e.g. how reflected vs stored XSS differ in User Interaction and Vulnerable/Subsequent System assignment), which the [FAQ](cvss-v4-faq.md) cross-references for edge cases.

## See also

- [CVSS](../concepts/cvss.md)
- [Specification](cvss-v4-specification-document.md)
- [User Guide](cvss-v4-user-guide.md)
- [Implementation Guide](cvss-v4-implementation-guide.md)
- [FAQ](cvss-v4-faq.md)
- [CVE](../concepts/cve.md)
- [FIRST](../entities/first.md)
