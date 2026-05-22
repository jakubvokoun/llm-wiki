---
title: "OpenSCAP"
tags: [openscap, scap, security-compliance, vulnerability-assessment, oscap]
updated: 2026-05-22
---

# OpenSCAP

Open-source implementation of the SCAP standard for automated security compliance and vulnerability assessment. Developed by Red Hat; NIST SCAP 1.2 certified since April 2014.

## Components

| Tool | Description |
| ---- | ----------- |
| **oscap** | Core CLI scanner — evaluate XCCDF/OVAL, generate reports and fix scripts |
| **SCAP Workbench** | GUI frontend for scanning and policy tailoring |
| **OpenSCAP Daemon** | Continuous scheduled scanning service |
| **SCAP Security Guide (SSG)** | Primary content library: machine-readable policies for PCI DSS, STIG, USGCB, CIS, HIPAA, OSPP |

## Key Standards Implemented

- **XCCDF**: checklists of security rules
- **OVAL**: machine-readable vulnerability definitions
- **CPE**: unique platform/software identifiers for matching
- **CCE**: standard IDs for configuration issues
- **ARF**: result data format for report exchange

## SCAP Content (SSG) Coverage

Platforms: RHEL 6–9, Fedora, Ubuntu, Debian, SUSE 12/15, Oracle Linux, OpenShift 4, macOS, Firefox, Chromium, Amazon EKS.

Notable profiles: DISA STIG, CIS (Level 1/2), NIST 800-53, PCI-DSS, HIPAA, USGCB, ACSC Essential Eight, ANSSI-BP-028.

## Usage in Practice

```bash
# Install
dnf install openscap-scanner scap-security-guide

# List profiles
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml

# Run compliance scan
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml

# Scan + auto-remediate
oscap xccdf eval --remediate --profile ... /path/to/ds.xml
```

## Sources

- [OpenSCAP Base Tool](../sources/openscap-base-tool.md)
- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [OpenSCAP User Manual](../sources/openscap-user-manual.md)
- [Choosing a SCAP Policy](../sources/openscap-choosing-policy.md)
- [OpenSCAP Customization](../sources/openscap-customization.md)
- [OpenSCAP Security Compliance](../sources/openscap-security-compliance.md)
- [OpenSCAP Vulnerability Assessment](../sources/openscap-vulnerability-assessment.md)
