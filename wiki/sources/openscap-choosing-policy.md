---
title: "OpenSCAP — Choosing a Security Policy"
tags:
  [
    openscap,
    scap,
    security-policy,
    stig,
    pci-dss,
    usgcb,
    cis,
    scap-security-guide,
  ]
sources: [openscap-choosing-policy.md]
updated: 2026-05-22
---

# OpenSCAP — Choosing a Security Policy

Guide to selecting an appropriate SCAP security policy. No universal policy exists — each organization must evaluate available options against its own requirements.

## Policy Selection Criteria

A good security policy should:

- Balance security risk against business needs
- Be proactive (define what _should_ be done, not what's forbidden)
- Implement mandatory government/industry requirements
- Use SCAP documents for automation
- Be regularly updated and maintained

## Common Security Specifications

| Standard           | Authority                      | Scope                                   |
| ------------------ | ------------------------------ | --------------------------------------- |
| **DISA STIG**      | US Department of Defense       | Government computer configuration       |
| **USGCB**          | NIST                           | Federal agency IT product baselines     |
| **PCI DSS**        | PCI Security Standards Council | Organizations handling credit card data |
| **CIS Benchmarks** | Center for Internet Security   | Best-practice baselines per OS/software |
| **NIST SP 800-53** | NIST                           | Federal information systems controls    |

## SCAP Content Sources

- **NIST NCP**: `web.nvd.nist.gov/view/ncp/repository` — publicly available policies for many products
- **Red Hat OVAL**: `redhat.com/security/data/oval/` — security advisories for RHEL
- **SUSE OVAL**: `ftp.suse.com/pub/projects/security/oval/` — SUSE security incidents

## SCAP Security Guide Profile Coverage

SCAP Security Guide (SSG) provides multiple profiles per platform. Key platforms and available profiles include:

- **Fedora**: OSPP, PCI-DSS, Standard, CUSP
- **RHEL 7**: CIS (L1/L2), CJIS, CUI, HIPAA, OSPP, PCI-DSS, STIG, USGCB, C2S, Australian Essential Eight
- **RHEL 8/9**: CIS, HIPAA, OSPP, PCI-DSS, STIG, Essential Eight, ANSSI-BP-028 (minimal/intermediary/high/enhanced)
- **Ubuntu 20.04/22.04**: CIS (L1/L2, server/workstation), STIG, Standard
- **SUSE 12/15**: CIS, DISA STIG, PCI-DSS, ANSSI-BP-028, HIPAA
- **OpenShift 4**: CIS, NIST 800-53 (Moderate/High), NERC CIP, PCI-DSS, Essential Eight
- **macOS 10.15**: NIST 800-53 Moderate

## Related

- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [OpenSCAP Customization](../sources/openscap-customization.md)
- [OpenSCAP Security Compliance](../sources/openscap-security-compliance.md)
