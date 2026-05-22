---
title: "OpenSCAP — Security Compliance"
tags: [openscap, scap, security-compliance, oscap, remediation, automation]
sources: [openscap-security-compliance.md]
updated: 2026-05-22
---

# OpenSCAP — Security Compliance

Overview of the security compliance domain and how the OpenSCAP ecosystem addresses it.

## What Is Security Compliance?

Security compliance means a system has been analyzed and verified to meet all requirements of a specific security policy (benchmark). It encompasses both:

- **Compliance analysis**: identifying non-compliant configurations
- **Remedial action**: correcting configurations to achieve compliance

Common regulatory frameworks: DISA STIG, FedRAMP, FISMA, PCI DSS, USGCB, NIAP.

## Key Process Steps

1. **Determine** the required security baseline
2. **Obtain** a machine-processable security checklist (SCAP format)
3. **Identify current state** against the baseline
4. **React promptly** — run corrective operations for non-compliant items
5. **Automate** — schedule scans on a regular basis
6. **Use tooling** to minimize effort and downtime

## Practical Examples

Evaluation against USGCB profile on RHEL 6.7:

```bash
oscap xccdf eval \
  --profile usgcb-rhel6-server \
  --results /tmp/usgcb-rhel6-server-results.xml \
  --report /tmp/usgcb-rhel6-server-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-xccdf.xml
```

Evaluation + automatic remediation in one step:

```bash
oscap xccdf eval \
  --remediate \
  --profile usgcb-rhel6-server \
  --results /tmp/usgcb-rhel6-server-results.xml \
  --report /tmp/usgcb-rhel6-server-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-xccdf.xml
```

## OpenSCAP Advantages

- Machine-readable SCAP content from SCAP Security Guide
- Automated compliance + remediation in a single pass
- Schedulable for continuous compliance monitoring
- Compatible with Spacewalk, Foreman, OpenSCAP Daemon, SCAP Workbench

## Related

- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [OpenSCAP Vulnerability Assessment](../sources/openscap-vulnerability-assessment.md)
- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Customization](../sources/openscap-customization.md)
