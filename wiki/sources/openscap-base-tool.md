---
title: "OpenSCAP Base Tool (oscap)"
tags: [openscap, oscap, scap, xccdf, oval, command-line, nist-certified]
sources: [openscap-base-tool.md]
updated: 2026-05-22
---

# OpenSCAP Base Tool (oscap)

The `oscap` command-line tool is the core OpenSCAP scanning engine. It is NIST SCAP 1.2 certified (since April 2014) and supports SCAP 1.0, 1.1, and 1.2.

## Capabilities

- Parse and evaluate SCAP standard components (XCCDF, OVAL, SCAP Data Streams)
- Validate SCAP content against XML schemas
- Display information about SCAP content and list profiles
- Generate compliance and vulnerability reports in HTML and ARF formats
- Perform remediation of non-compliant settings

## Installation

```bash
# Fedora
dnf install openscap-scanner

# RHEL 6/7, CentOS 6/7
yum install openscap-scanner

# Debian / Ubuntu
apt-get install libopenscap8
```

Also available for Windows (installer from GitHub releases).

## Key Commands

Show oscap version and supported specs:

```bash
oscap -V
```

Evaluate a DISA STIG:

```bash
oscap xccdf eval \
  --profile selected_profile \
  --results result_file \
  --cpe cpe_dictionary \
  disa_stig_content
```

Evaluate PCI-DSS profile on RHEL 7 (with SSG):

```bash
oscap xccdf eval \
  --report report.html \
  --profile xccdf_org.ssgproject.content_profile_pci-dss \
  /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml
```

## Library

The OpenSCAP library is the foundation for:

- SCAP Workbench (GUI tailoring and scanning)
- SCAPTimony (Red Hat Satellite integration)
- OpenSCAP Daemon (continuous scanning)

## Related

- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Security Compliance](../sources/openscap-security-compliance.md)
- [OpenSCAP Vulnerability Assessment](../sources/openscap-vulnerability-assessment.md)
