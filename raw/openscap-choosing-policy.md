# Choosing a Policy

**There is no need to be an expert in security to deploy a security policy. You don't even need to learn the SCAP standard to write a security policy. Many security policies are available online, in a standardized form of SCAP checklists.**

Unfortunately, there is no universal security policy that could be applied everywhere; each organization has different needs and different security requirements. Before applying a security policy, it is necessary to think about your needs and go through the available offerings. This page will give you a brief overview of commonly-used security policies.

From a high level point of view, a good security policy should balance security risk against your business' needs. Security policy should be written in a pro-active way – that is, it shouldn't describe what is forbidden, but instead what should be done, and how to do it. It is best to implement security policy using SCAP documents, for ease of automation. Security policy must incorporate any mandatory government and industry requirements, and should be regularly updated and maintained.

## Security specifications

**[Security Technical Implementation Guides (STIGs)](https://public.cyber.mil/stigs/downloads/)** by The United States Department of Defense specify how government computers must be configured and managed.

**[The United States Government Configuration Baseline (USGCB)](http://usgcb.nist.gov/)** creates security configuration baselines for IT products widely deployed across the federal agencies. The USGCB is a Federal government-wide initiative that provides guidance to agencies on what should be done to improve and maintain an effective configuration settings focusing primarily on security.

**[Payment Card Industry Data Security Standard (PCI DSS)](https://www.pcisecuritystandards.org/security_standards/documents.php?association=PCI-DSS)** must be followed by anyone who is handling credit card information and payments. It is a proprietary information security standard for organizations that handle branded credit cards from the major card schemes.

## SCAP Content

NIST SCAP Content at the National Checklist Program Repository of the National Vulnerability Database offers publicly available security policies for a wide range of products. Repository: [web.nvd.nist.gov/view/ncp/repository](https://web.nvd.nist.gov/view/ncp/repository)

The **Red Hat** repository of OVAL content consists of OVAL Definitions that correspond to Red Hat Errata security advisories. Repository: [redhat.com/security/data/oval/](https://www.redhat.com/security/data/oval/)

The **SUSE** Linux Enterprise OVAL Information database is an index of fixed security incidents indexed by product, RPM package name and version for use in security compliance checking. Repository: [ftp.suse.com/pub/projects/security/oval/](http://ftp.suse.com/pub/projects/security/oval/)

## Security policies available in the SCAP Security Guide

The SCAP Security Guide is not just one security policy, but a whole number of them. For each platform, there are several profiles which provide security policies implemented according to security baselines.

These guides to secure configuration of the following platforms with the following profiles are currently available in upstream:

### Alibaba Cloud Linux 2

- [CIS Aliyun Linux 2 Benchmark for Level 2](http://static.open-scap.org/ssg-guides/ssg-alinux2-guide-cis.html)
- [CIS Aliyun Linux 2 Benchmark for Level 1](http://static.open-scap.org/ssg-guides/ssg-alinux2-guide-cis_l1.html)
- [Standard System Security Profile for Alibaba Cloud Linux 2](http://static.open-scap.org/ssg-guides/ssg-alinux2-guide-standard.html)

### Alibaba Cloud Linux 3

- [CIS Benchmark for Alibaba Cloud Linux 3 for Level 2](http://static.open-scap.org/ssg-guides/ssg-alinux3-guide-cis.html)
- [CIS Benchmark for Alibaba Cloud Linux 3 for Level 1](http://static.open-scap.org/ssg-guides/ssg-alinux3-guide-cis_l1.html)
- [Standard System Security Profile for Alibaba Cloud Linux 3](http://static.open-scap.org/ssg-guides/ssg-alinux3-guide-standard.html)

### Anolis OS 8

- [Standard System Security Profile for Anolis OS 8](http://static.open-scap.org/ssg-guides/ssg-anolis8-guide-standard.html)

### Chromium

- [Upstream STIG for Google Chromium](http://static.open-scap.org/ssg-guides/ssg-chromium-guide-stig.html)

### Debian 10

- [Profile for ANSSI DAT-NT28 High (Enforced) Level](http://static.open-scap.org/ssg-guides/ssg-debian10-guide-anssi_np_nt28_high.html)
- [Profile for ANSSI DAT-NT28 Minimal Level](http://static.open-scap.org/ssg-guides/ssg-debian10-guide-anssi_np_nt28_minimal.html)
- [Profile for ANSSI DAT-NT28 Restrictive Level](http://static.open-scap.org/ssg-guides/ssg-debian10-guide-anssi_np_nt28_restrictive.html)
- [Profile for ANSSI DAT-NT28 Average (Intermediate) Level](http://static.open-scap.org/ssg-guides/ssg-debian10-guide-anssi_np_nt28_average.html)
- [Standard System Security Profile for Debian 10](http://static.open-scap.org/ssg-guides/ssg-debian10-guide-standard.html)

### Debian 11

- [Profile for ANSSI DAT-NT28 High (Enforced) Level](http://static.open-scap.org/ssg-guides/ssg-debian11-guide-anssi_np_nt28_high.html)
- [Profile for ANSSI DAT-NT28 Minimal Level](http://static.open-scap.org/ssg-guides/ssg-debian11-guide-anssi_np_nt28_minimal.html)
- [Profile for ANSSI DAT-NT28 Restrictive Level](http://static.open-scap.org/ssg-guides/ssg-debian11-guide-anssi_np_nt28_restrictive.html)
- [Profile for ANSSI DAT-NT28 Average (Intermediate) Level](http://static.open-scap.org/ssg-guides/ssg-debian11-guide-anssi_np_nt28_average.html)
- [Standard System Security Profile for Debian 11](http://static.open-scap.org/ssg-guides/ssg-debian11-guide-standard.html)

### Amazon Elastic Kubernetes Service

- [CIS Amazon Elastic Kubernetes Service (EKS) Benchmark – Node](http://static.open-scap.org/ssg-guides/ssg-eks-guide-cis-node.html)
- [CIS Amazon Elastic Kubernetes Service Benchmark – Platform](http://static.open-scap.org/ssg-guides/ssg-eks-guide-cis.html)

### Fedora

- [OSPP – Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-fedora-guide-ospp.html)
- [PCI-DSS v3.2.1 Control Baseline for Fedora](http://static.open-scap.org/ssg-guides/ssg-fedora-guide-pci-dss.html)
- [Standard System Security Profile for Fedora](http://static.open-scap.org/ssg-guides/ssg-fedora-guide-standard.html)
- [CUSP – Common User Security Profile for Fedora Workstation](http://static.open-scap.org/ssg-guides/ssg-fedora-guide-cusp_fedora.html)

### Firefox

- [Mozilla Firefox STIG](http://static.open-scap.org/ssg-guides/ssg-firefox-guide-stig.html)
- [CUSP – Common User Security Profile for Mozilla Firefox](http://static.open-scap.org/ssg-guides/ssg-firefox-guide-cusp_firefox.html)

### Apple macOS 10.15

- [NIST 800-53 Moderate-Impact Baseline for Apple macOS 10.15 Catalina](http://static.open-scap.org/ssg-guides/ssg-macos1015-guide-moderate.html)

### Red Hat OpenShift Container Platform 4

- [CIS Red Hat OpenShift Container Platform 4 Benchmark](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-cis-node.html)
- [NIST 800-53 High-Impact Baseline for Red Hat OpenShift – Node level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-high-node.html)
- [NIST 800-53 High-Impact Baseline for Red Hat OpenShift – Platform level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-high.html)
- [NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift – Node level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-moderate-node.html)
- [NERC CIP cybersecurity standards profile for Red Hat OpenShift Container Platform – Node level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-nerc-cip-node.html)
- [NERC CIP cybersecurity standards profile for Red Hat OpenShift Container Platform – Platform level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-nerc-cip.html)
- [PCI-DSS v3.2.1 Control Baseline for Red Hat OpenShift Container Platform 4](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-pci-dss-node.html)
- [PCI-DSS v3.2.1 Control Baseline for Red Hat OpenShift Container Platform 4](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-pci-dss.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-e8.html)
- [NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift – Platform level](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-moderate.html)
- [CIS Red Hat OpenShift Container Platform 4 Benchmark](http://static.open-scap.org/ssg-guides/ssg-ocp4-guide-cis.html)

### Oracle Linux 7

- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-anssi_nt28_enhanced.html)
- [DRAFT – ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-anssi_nt28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-anssi_nt28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-anssi_nt28_minimal.html)
- [Criminal Justice Information Services (CJIS) Security Policy](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-cjis.html)
- [Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-cui.html)
- [[DRAFT] Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-e8.html)
- [PCI-DSS v3.2.1 Control Baseline Draft for Oracle Linux 7](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-pci-dss.html)
- [Security Profile of Oracle Linux 7 for SAP](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-sap.html)
- [Standard System Security Profile for Oracle Linux 7](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-standard.html)
- [[DRAFT] Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-ospp.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-hipaa.html)
- [NIST National Checklist Program Security Guide](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-ncp.html)
- [DISA STIG with GUI for Oracle Linux 7](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-stig_gui.html)
- [DISA STIG for Oracle Linux 7](http://static.open-scap.org/ssg-guides/ssg-ol7-guide-stig.html)

### Oracle Linux 8

- [Criminal Justice Information Services (CJIS) Security Policy](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-cjis.html)
- [Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-cui.html)
- [[DRAFT] Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-e8.html)
- [PCI-DSS v3.2.1 Control Baseline Draft for Oracle Linux 8](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-pci-dss.html)
- [Standard System Security Profile for Oracle Linux 8](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-standard.html)
- [[DRAFT] Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-ospp.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-hipaa.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-anssi_bp28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-anssi_bp28_minimal.html)
- [DISA STIG for Oracle Linux 8](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-stig.html)
- [DISA STIG with GUI for Oracle Linux 8](http://static.open-scap.org/ssg-guides/ssg-ol8-guide-stig_gui.html)

### Oracle Linux 9

- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-anssi_bp28_minimal.html)
- [[DRAFT] Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-cui.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-e8.html)
- [PCI-DSS v3.2.1 Control Baseline for Oracle Linux 9](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-pci-dss.html)
- [Standard System Security Profile for Oracle Linux 9](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-standard.html)
- [[DRAFT] Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-ospp.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-hipaa.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-anssi_bp28_high.html)
- [[DRAFT] DISA STIG for Oracle Linux 9](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-stig.html)
- [[DRAFT] DISA STIG with GUI for Oracle Linux 9](http://static.open-scap.org/ssg-guides/ssg-ol9-guide-stig_gui.html)

### openSUSE

- [Standard System Security Profile for openSUSE](http://static.open-scap.org/ssg-guides/ssg-opensuse-guide-standard.html)

### Red Hat Enterprise Linux CoreOS 4

- [DRAFT – ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-anssi_bp28_enhanced.html)
- [DRAFT – ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-anssi_bp28_high.html)
- [DRAFT – ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-anssi_bp28_intermediary.html)
- [DRAFT – ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-anssi_bp28_minimal.html)
- [NIST 800-53 High-Impact Baseline for Red Hat Enterprise Linux CoreOS](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-high.html)
- [NIST 800-53 Moderate-Impact Baseline for Red Hat Enterprise Linux CoreOS](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-moderate.html)
- [NERC CIP cybersecurity standards profile for Red Hat Enterprise Linux CoreOS](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-nerc-cip.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-e8.html)
- [[DRAFT] DISA STIG for Red Hat Enterprise Linux CoreOS](http://static.open-scap.org/ssg-guides/ssg-rhcos4-guide-stig.html)

### Red Hat Enterprise Linux 7

- [C2S for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-C2S.html)
- [CIS Red Hat Enterprise Linux 7 Benchmark for Level 2 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cis.html)
- [CIS Red Hat Enterprise Linux 7 Benchmark for Level 1 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cis_server_l1.html)
- [CIS Red Hat Enterprise Linux 7 Benchmark for Level 1 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cis_workstation_l1.html)
- [CIS Red Hat Enterprise Linux 7 Benchmark for Level 2 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cis_workstation_l2.html)
- [Criminal Justice Information Services (CJIS) Security Policy](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cjis.html)
- [Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-cui.html)
- [PCI-DSS v3.2.1 Control Baseline for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-pci-dss.html)
- [Standard System Security Profile for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-standard.html)
- [OSPP – Protection Profile for General Purpose Operating Systems v4.2.1](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-ospp.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-e8.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-hipaa.html)
- [NIST National Checklist Program Security Guide](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-ncp.html)
- [RHV hardening based on STIG for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-rhelh-stig.html)
- [VPP – Protection Profile for Virtualization v. 1.0 for Red Hat Virtualization](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-rhelh-vpp.html)
- [Red Hat Corporate Profile for Certified Cloud Providers (RH CCP)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-rht-ccp.html)
- [DISA STIG with GUI for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-stig_gui.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-anssi_nt28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-anssi_nt28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-anssi_nt28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-anssi_nt28_minimal.html)
- [DISA STIG for Red Hat Enterprise Linux 7](http://static.open-scap.org/ssg-guides/ssg-rhel7-guide-stig.html)

### Red Hat Enterprise Linux 8

- [CIS Red Hat Enterprise Linux 8 Benchmark for Level 2 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cis.html)
- [CIS Red Hat Enterprise Linux 8 Benchmark for Level 1 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cis_server_l1.html)
- [CIS Red Hat Enterprise Linux 8 Benchmark for Level 1 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cis_workstation_l1.html)
- [CIS Red Hat Enterprise Linux 8 Benchmark for Level 2 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cis_workstation_l2.html)
- [Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cui.html)
- [Standard System Security Profile for Red Hat Enterprise Linux 8](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-standard.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-e8.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-hipaa.html)
- [Australian Cyber Security Centre (ACSC) ISM Official](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-ism_o.html)
- [DISA STIG with GUI for Red Hat Enterprise Linux 8](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-stig_gui.html)
- [Criminal Justice Information Services (CJIS) Security Policy](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-cjis.html)
- [Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-ospp.html)
- [PCI-DSS v3.2.1 Control Baseline for Red Hat Enterprise Linux 8](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-pci-dss.html)
- [Red Hat Corporate Profile for Certified Cloud Providers (RH CCP)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-rht-ccp.html)
- [DISA STIG for Red Hat Enterprise Linux 8](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-stig.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-anssi_bp28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-rhel8-guide-anssi_bp28_minimal.html)

### Red Hat Enterprise Linux 9

- [[DRAFT] Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-cui.html)
- [PCI-DSS v3.2.1 Control Baseline for Red Hat Enterprise Linux 9](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-pci-dss.html)
- [[DRAFT] DISA STIG for Red Hat Enterprise Linux 9](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-stig.html)
- [[DRAFT] DISA STIG with GUI for Red Hat Enterprise Linux 9](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-stig_gui.html)
- [CIS Red Hat Enterprise Linux 9 Benchmark for Level 2 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-cis.html)
- [CIS Red Hat Enterprise Linux 9 Benchmark for Level 1 – Server](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-cis_server_l1.html)
- [CIS Red Hat Enterprise Linux 9 Benchmark for Level 1 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-cis_workstation_l1.html)
- [Australian Cyber Security Centre (ACSC) Essential Eight](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-e8.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-hipaa.html)
- [Australian Cyber Security Centre (ACSC) ISM Official](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-ism_o.html)
- [CIS Red Hat Enterprise Linux 9 Benchmark for Level 2 – Workstation](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-cis_workstation_l2.html)
- [Protection Profile for General Purpose Operating Systems](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-ospp.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-anssi_bp28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-rhel9-guide-anssi_bp28_minimal.html)

### Red Hat Virtualization 4

- [PCI-DSS v3.2.1 Control Baseline for Red Hat Virtualization Host (RHVH)](http://static.open-scap.org/ssg-guides/ssg-rhv4-guide-pci-dss.html)
- [[DRAFT] DISA STIG for Red Hat Virtualization Host (RHVH)](http://static.open-scap.org/ssg-guides/ssg-rhv4-guide-rhvh-stig.html)
- [VPP – Protection Profile for Virtualization v. 1.0 for Red Hat Virtualization Host (RHVH)](http://static.open-scap.org/ssg-guides/ssg-rhv4-guide-rhvh-vpp.html)

### SUSE Linux Enterprise 12

- [Standard System Security Profile for SUSE Linux Enterprise 12](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-standard.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-anssi_bp28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-anssi_bp28_minimal.html)
- [DISA STIG for SUSE Linux Enterprise 12](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-stig.html)
- [CIS SUSE Linux Enterprise 12 Benchmark for Level 2 – Server](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-cis.html)
- [CIS SUSE Linux Enterprise 12 Benchmark for Level 1 – Server](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-cis_server_l1.html)
- [CIS SUSE Linux Enterprise 12 Benchmark for Level 1 – Workstation](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-cis_workstation_l1.html)
- [CIS SUSE Linux Enterprise 12 Benchmark Level 2 – Workstation](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-cis_workstation_l2.html)
- [PCI-DSS v4 Control Baseline for SUSE Linux enterprise 12](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-pci-dss-4.html)
- [PCI-DSS v3.2.1 Control Baseline for SUSE Linux enterprise 12](http://static.open-scap.org/ssg-guides/ssg-sle12-guide-pci-dss.html)

### SUSE Linux Enterprise 15

- [Hardening for Public Cloud Image of SUSE Linux Enterprise Server (SLES) for SAP Applications 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-pcs-hardening-sap.html)
- [Standard System Security Profile for SUSE Linux Enterprise 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-standard.html)
- [ANSSI-BP-028 (enhanced)](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-anssi_bp28_enhanced.html)
- [ANSSI-BP-028 (high)](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-anssi_bp28_high.html)
- [ANSSI-BP-028 (intermediary)](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-anssi_bp28_intermediary.html)
- [ANSSI-BP-028 (minimal)](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-anssi_bp28_minimal.html)
- [Public Cloud Hardening for SUSE Linux Enterprise 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-pcs-hardening.html)
- [DISA STIG for SUSE Linux Enterprise 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-stig.html)
- [CIS SUSE Linux Enterprise 15 Benchmark for Level 2 – Server](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-cis.html)
- [CIS SUSE Linux Enterprise 15 Benchmark for Level 1 – Server](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-cis_server_l1.html)
- [CIS SUSE Linux Enterprise 15 Benchmark for Level 1 – Workstation](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-cis_workstation_l1.html)
- [CIS SUSE Linux Enterprise 15 Benchmark Level 2 – Workstation](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-cis_workstation_l2.html)
- [Health Insurance Portability and Accountability Act (HIPAA)](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-hipaa.html)
- [PCI-DSS v4 Control Baseline for SUSE Linux enterprise 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-pci-dss-4.html)
- [PCI-DSS v3.2.1 Control Baseline for SUSE Linux enterprise 15](http://static.open-scap.org/ssg-guides/ssg-sle15-guide-pci-dss.html)

### Ubuntu 16.04

- [Profile for ANSSI DAT-NT28 High (Enforced) Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1604-guide-anssi_np_nt28_high.html)
- [Profile for ANSSI DAT-NT28 Minimal Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1604-guide-anssi_np_nt28_minimal.html)
- [Profile for ANSSI DAT-NT28 Restrictive Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1604-guide-anssi_np_nt28_restrictive.html)
- [Profile for ANSSI DAT-NT28 Average (Intermediate) Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1604-guide-anssi_np_nt28_average.html)
- [Standard System Security Profile for Ubuntu 16.04](http://static.open-scap.org/ssg-guides/ssg-ubuntu1604-guide-standard.html)

### Ubuntu 18.04

- [Profile for ANSSI DAT-NT28 High (Enforced) Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-anssi_np_nt28_high.html)
- [Profile for ANSSI DAT-NT28 Minimal Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-anssi_np_nt28_minimal.html)
- [Profile for ANSSI DAT-NT28 Restrictive Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-anssi_np_nt28_restrictive.html)
- [CIS Ubuntu 18.04 LTS Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-cis.html)
- [Profile for ANSSI DAT-NT28 Average (Intermediate) Level](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-anssi_np_nt28_average.html)
- [Standard System Security Profile for Ubuntu 18.04](http://static.open-scap.org/ssg-guides/ssg-ubuntu1804-guide-standard.html)

### Ubuntu 20.04

- [CIS Ubuntu 20.04 Level 1 Workstation Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-cis_level1_workstation.html)
- [Canonical Ubuntu 20.04 LTS Security Technical Implementation Guide (STIG) V1R1](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-stig.html)
- [Standard System Security Profile for Ubuntu 20.04](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-standard.html)
- [CIS Ubuntu 20.04 Level 1 Server Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-cis_level1_server.html)
- [CIS Ubuntu 20.04 Level 2 Server Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-cis_level2_server.html)
- [CIS Ubuntu 20.04 Level 2 Workstation Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2004-guide-cis_level2_workstation.html)

### Ubuntu 22.04

- [CIS Ubuntu 22.04 Level 1 Workstation Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-cis_level1_workstation.html)
- [Standard System Security Profile for Ubuntu 22.04](http://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-standard.html)
- [CIS Ubuntu 22.04 Level 1 Server Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-cis_level1_server.html)
- [CIS Ubuntu 22.04 Level 2 Server Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-cis_level2_server.html)
- [CIS Ubuntu 22.04 Level 2 Workstation Benchmark](http://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-cis_level2_workstation.html)

### UnionTech OS Server 20

- [Standard System Security Profile for UnionTech OS Server 20](http://static.open-scap.org/ssg-guides/ssg-uos20-guide-standard.html)
