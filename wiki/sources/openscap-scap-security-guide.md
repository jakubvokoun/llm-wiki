---
title: "SCAP Security Guide"
tags:
  [
    openscap,
    scap,
    scap-security-guide,
    ssg,
    remediation,
    compliance,
    stig,
    pci-dss,
  ]
sources: [openscap-scap-security-guide.md]
updated: 2026-05-22
---

# SCAP Security Guide (SSG)

SCAP Security Guide is a collection of machine-readable security policies in SCAP format, implementing major security standards including PCI DSS, DISA STIG, and USGCB. It is the primary source of SCAP content for the OpenSCAP ecosystem.

## Key Characteristics

- Single high-quality SCAP content base that generates multiple profiles/baselines
- Includes rule descriptions, rationale, and proven remediation scripts
- Used by Red Hat for continuous monitoring of OpenShift infrastructure since 2012
- Active collaboration between US DoD, NSA, DISA, Red Hat, and community contributors
- Available free under an open source license

## Installation

```bash
# Fedora
dnf install scap-security-guide

# RHEL 6/7, CentOS 6/7
yum install scap-security-guide

# Debian / Ubuntu
apt install ssg-base ssg-debderived ssg-debian ssg-nondebian ssg-applications

# openSUSE / SLES
zypper install scap-security-guide
```

Policy files are installed to `/usr/share/xml/scap/ssg/content/`. Use `*-ds.xml` datastream files.

## Usage with oscap

Display available profiles:

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Run a scan and generate reports:

```bash
oscap xccdf eval \
  --profile selected_profile \
  --results-arf arf.xml \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

## Usage with SCAP Workbench

SCAP Workbench automatically detects and offers SSG content on startup. Select guide → profile → run scan.

## Notable Real-World Uses

- US Government C2S (CIA/Amazon) environment baseline (RHEL 6)
- US Department of Defense STIGs (upstream for DISA STIG content)
- US Navy JBoss EAP5 implementation guide
- Financial services firms for STIG-profile continuous monitoring
- In-seat entertainment systems at a European airline

## Related

- [Choosing a SCAP Policy](../sources/openscap-choosing-policy.md)
- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [OpenSCAP Base Tool](../sources/openscap-base-tool.md)
- [OpenSCAP Customization](../sources/openscap-customization.md)
