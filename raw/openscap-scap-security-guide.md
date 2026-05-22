# SCAP Security Guide

## Verified security advises that are worth following. Offering high level of automation. For free.

SCAP Security Guide is a security policy written in a form of SCAP documents. The security policy created in SCAP Security Guide covers many areas of computer security and provides the best-practice solutions. The guide consists of rules with very detailed description and also includes proven remediation scripts, optimized for target systems. SCAP Security Guide, together with OpenSCAP tools, can be used for auditing your system in an automated way.

SCAP Security Guide implements security guidances recommended by respected authorities, namely PCI DSS, STIG, and USGCB. SCAP Security Guide transforms these security guidances into a machine readable format which then can be used by OpenSCAP to audit your system. SCAP Security Guide builds multiple security baselines from a single high-quality SCAP content. The DISA STIG for RHEL 6, which provides required settings for US Department of Defense systems, is one example of a baseline created from this guidance. If your systems must to comply to these baselines, you simply select appropriate profile from SCAP Security Guide.

Security policies in SCAP Security Guide are available for various operating systems and other software – Fedora, Red Hat Enterprise Linux, Mozilla Firefox and others.

SCAP Security guide is a dynamic open source project, which means that many organizations interested in computer security share their efforts and collaborate on security policies contained in SCAP Security guide. It has usage in Military and Intelligence communities, healthcare, aviation, telecom and other industries. And above all, SCAP Security guide is available for download free.

### How to install SCAP security guide

Install **SCAP Security Guide** on **Fedora**:

```
dnf install scap-security-guide
```

Install **SCAP Security Guide** on **RHEL 6, RHEL 7, CentOS 6, CentOS 7, Scientific Linux 6, Scientific Linux 7**:

```
yum install scap-security-guide
```

Install **SCAP Security Guide** on **Debian 10 and newer** using apt:

```
apt install ssg-base ssg-debderived ssg-debian ssg-nondebian ssg-applications
```

Install **SCAP Security Guide** on **Ubuntu 18.04 and newer** using apt:

```
apt install ssg-base ssg-debderived ssg-debian ssg-nondebian ssg-applications
```

Install **SCAP Security Guide** on **openSUSE Leap** or **openSUSE Tumbleweed**:

```
zypper install scap-security-guide
```

Install **SCAP Security Guide** on **SUSE Linux Enterprise Server 12 or 15**:

```
zypper install scap-security-guide
```

## References

**Red Hat** uses SSG for continuous monitoring of their [OpenShift](https://www.openshift.com/) infrastructure, and has done since 2012.

A number of IC and DoD entities have developed customized XCCDF profiles based off of SSG for their RHEL6 baselines and security compliance verification.

A European airline utilizes SSG to verify security compliance of their in-seat entertainment systems.

In 2013, Red Hat joined **Lockheed Martin's** Cyber Alliance. They collaborated on the CSCF-RHEL6-MLS profile.

Through sponsorship from the **U.S. Navy**, SSG serves as the upstream of the U.S. Government's implementation guide to JBoss EAP5.

A US-based financial services firm performs continuous monitoring with SSG, utilizing the STIG profile, ensuring their trade systems remain in compliance with their security policy.

Through collaboration with DISA FSO, NSA's Information Assurance Directorate, and Red Hat, SSG serves as Red Hat's upstream for **U.S. Department of Defense** Security Technical Implementation Guides (STIGs).

Working with **Amazon**, SSG open sourced the RHEL6 baseline for CIA's C2S environment. This profile was based off the Center for Internet Security's Red Hat Enterprise Linux 6 Benchmark, v1.2.0.

## Documentation for SCAP Security Guide

After installing, all SCAP Security Guide security policies are in directory `/usr/share/xml/scap/ssg/content/`. There are files for every platform available in a form of XCCDF, OVAL or datastream documents. In most of use cases, you want to use the datastreams, which file names end with `-ds.xml`.

#### Using SCAP Security Guide in the OpenSCAP scanner

Display all available profiles:

```
# oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Then run the scan:

```
# oscap xccdf eval --profile selected_profile --results-arf arf.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Replace *selected_profile* with some profile of your choice. After evaluation, the `arf.xml` file will contain all results in a reusable Result DataStream format, `report.html` will contain a dynamic, human readable report that can be opened in a browser.

#### Using SCAP Security Guide in the SCAP Workbench

SCAP Security Guide is fully integrated with SCAP Workbench, an easy-to-use graphical tool. Its purpose is to audit either local or remote machines. When started, SCAP Workbench will automatically offer you SCAP Security Guide content and will ask you for selecting the guide and a profile.

[See Documentation](https://github.com/OpenSCAP/scap-security-guide/wiki)

## Do you need help with SCAP Security Guide?

**I have a problem I would like to ask about**

**OPTION 1**: Join the [mailing list](https://lists.fedorahosted.org/mailman/listinfo/scap-security-guide).

**OPTION 2**: You can also join the #openscap IRC channel on Libera.Chat.

**I have found a bug / I want to create a new ticket**

File a bug against SCAP Security Guide on the [GitHub Issue Page](https://github.com/OpenSCAP/scap-security-guide/issues)

**I need more information**

See the [SCAP Security Guide WIKI](https://github.com/OpenSCAP/scap-security-guide/wiki)
