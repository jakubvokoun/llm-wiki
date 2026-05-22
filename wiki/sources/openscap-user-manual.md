---
title: "OpenSCAP 1.3 User Manual"
tags:
  [
    openscap,
    oscap,
    scap,
    xccdf,
    oval,
    user-manual,
    remediation,
    tailoring,
    remote-scanning,
  ]
sources: [openscap-user-manual.md]
updated: 2026-05-22
---

# OpenSCAP 1.3 User Manual

The complete reference for using the `oscap` command-line tool. Covers SCAP 1.3 (backward compatible with 1.0–1.2).

## Key Concepts

- **SCAP**: NIST standards for security automation — XCCDF (checklists), OVAL (definitions), CPE (platform enumeration), CCE (configuration enumeration)
- **SCAP content / security policies**: files consumed by `oscap` — most commonly SCAP Source Data Streams (`*-ds.xml`)
- **Profile**: a named subset of rules within a policy tailored to a specific security baseline
- **SCAP Security Guide (SSG)**: primary SCAP content source; installed to `/usr/share/xml/scap/ssg/content/`

## Installation

```bash
# RHEL 8+ / Fedora
dnf install openscap-scanner scap-security-guide

# RHEL 7 / CentOS 7
yum install openscap-scanner scap-security-guide

# Debian / Ubuntu
apt install libopenscap8
```

## Displaying Information

```bash
# Show oscap version, supported specs, built-in CPE names, OVAL objects
oscap --version

# Show content info: document type, profiles, checklists, check files
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

Output includes:

- **Document type**: XCCDF, OVAL, Source Data Stream, Result Data Stream
- **Status**: accepted / draft / deprecated / incomplete
- **Profiles**: ID and title for each profile in the benchmark

## Core oscap Subcommands

| Subcommand                   | Purpose                                 |
| ---------------------------- | --------------------------------------- |
| `oscap xccdf eval`           | Evaluate XCCDF benchmark against system |
| `oscap oval eval`            | Evaluate OVAL definitions               |
| `oscap xccdf generate guide` | Generate HTML security guide            |
| `oscap xccdf generate fix`   | Generate remediation script             |
| `oscap info`                 | Display content metadata                |

## Local Compliance Evaluation

```bash
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --results results.xml \
  --results-arf arf.xml \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

Options:

- `--profile`: profile ID (from `oscap info`)
- `--results`: XCCDF results file
- `--results-arf`: reusable ARF (Asset Reporting Format) results
- `--report`: HTML report

## Evaluation with Remediation

```bash
oscap xccdf eval \
  --remediate \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --results results.xml \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

`--remediate` applies fixes automatically after evaluation.

## OVAL Vulnerability Assessment

```bash
# Direct OVAL evaluation
oscap oval eval Red_Hat_Enterprise_Linux_8.xml

# Generate HTML report from OVAL results
oscap oval generate report /tmp/oval-results.xml > /tmp/oval-report.html
```

## Remote Scanning (via SSH)

```bash
oscap-ssh user@remote-host 22 xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

`oscap-ssh` transfers content and runs `oscap` on the remote host.

## Tailoring (Customization)

Tailoring files contain adjusted profiles without modifying original content:

```bash
oscap xccdf eval \
  --profile tailored_profile_id \
  --tailoring-file my-tailoring.xml \
  --report report.html \
  /path/to/ssg-ds.xml
```

Create tailoring files with SCAP Workbench.

## Generating Reports and Fix Scripts

```bash
# Generate HTML hardening guide
oscap xccdf generate guide \
  --profile selected_profile \
  /path/to/ssg-ds.xml > guide.html

# Generate bash remediation script
oscap xccdf generate fix \
  --profile selected_profile \
  --fix-type bash \
  /path/to/ssg-ds.xml > fix.sh

# Generate Ansible remediation playbook
oscap xccdf generate fix \
  --profile selected_profile \
  --fix-type ansible \
  /path/to/ssg-ds.xml > playbook.yml
```

## Result File Formats

| Format                       | Use case                       |
| ---------------------------- | ------------------------------ |
| XCCDF results XML            | Rule-by-rule pass/fail results |
| ARF (Asset Reporting Format) | Reusable, importable results   |
| HTML report                  | Human-readable                 |

## Related

- [OpenSCAP Base Tool](../sources/openscap-base-tool.md)
- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Customization](../sources/openscap-customization.md)
- [OpenSCAP Security Compliance](../sources/openscap-security-compliance.md)
