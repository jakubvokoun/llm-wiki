## Looking for a certified tool which can parse and evaluate each component of the SCAP standard?

OpenSCAP represents both a library and a command line tool which can be used to parse and evaluate each component of the [SCAP standard](/features/standards/). The library approach allows for the swift creation of new SCAP tools rather than spending time learning existing file structure. The command-line tool, called oscap, offers a multi-purpose tool designed to format content into documents or scan the system based on this content. Whether you want to evaluate [DISA STIGs](https://public.cyber.mil/stigs/downloads/), NIST's [USGCB](http://usgcb.nist.gov/), or Red Hat's Security Response Team's content, all are supported by OpenSCAP.

If your main goal is to perform configuration and vulnerability scans of a local system then oscap can be the right tool for you. It can evaluate both XCCDF benchmarks and OVAL definitions and generate the appropriate results.

The tool supports SCAP 1.2 and is backward compatible with SCAP 1.1 and 1.0.

The OpenSCAP library is the core building block used in a content tailoring program called [SCAP Workbench](/tools/scap-workbench/), integrated in Red Hat Satellite by [SCAPTimony](/tools/scaptimony/) and used for all SCAP evaluation by [OpenSCAP Daemon](/tools/openscap-daemon/).

OpenSCAP is available on various Linux distributions, including Red Hat Enterprise Linux, Fedora and Ubuntu. Since version 1.3.0 OpenSCAP supports also Microsoft Windows.

## Download and Install OpenSCAP

### OpenSCAP for Linux

Install **OpenSCAP** using the following command:

* On **Fedora**:

  dnf install openscap-scanner
* On **RHEL 6, RHEL7, CentOS 6 and CentOS 7**:

  yum install openscap-scanner
* On **Debian and Ubuntu**:

  apt-get install libopenscap8

### OpenSCAP for Windows

[Download Windows Installer](https://github.com/OpenSCAP/openscap/releases/download/1.3.0/OpenSCAP-1.3.0-win32.msi)

### OpenSCAP sources

[Get the sources on GitHub](https://github.com/OpenSCAP/openscap/releases)

## Documentation for OpenSCAP Base

With the oscap tool you can perform configuration and vulnerability scans, validate your SCAP content in line with SCAP standard XML schemas, display basic information about your content, or list profiles in an XCCDF benchmark.

To display the version of oscap, supported specifications, built-in CPE names, and supported OVAL objects, type the following command:

$ oscap -V

#### How to Evaluate a DISA STIG

The oscap tool can help you evaluate a Security Technical Implementation Guide (STIG) from the Defense Information Systems Agency (DISA) on your local machine with the following command:

`$ oscap xccdf eval --profile selected_profile --results result_file --cpe cpe_dictionary disa_stig_content`

If you are looking for a detailed step by step instruction please refer to the [user manual](http://static.open-scap.org/openscap-1.2/oscap_user_manual.html#_how_to_evaluate_disa_stig).

#### Make a RHEL7 machine PCI-DSS compliant

You can use the oscap tool to evaluate a Payment Card Industry Data Security Standard (PCI-DSS) on your machine with the following command which assumes that you have the [SCAP Security Guide](/security-policies/scap-security-guide/) installed already:

`$ oscap xccdf eval --report report.html --profile xccdf_org.ssgproject.content_profile_pci-dss /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml`

If you are interested in more practical examples of basic or advanced usage, or want to find information regarding development please see the manual.

[User Manual](http://static.open-scap.org/openscap-1.2/oscap_user_manual.html)

## References

"Red Hat's development team did a great job implementing the sizable and challenging requirements from the SCAP standard for 32 bit and 64 bit Linux systems." *Stephan Mueller, [atsec](https://www.atsec.com), Team Lead*

"SCAP is a valuable tool for maintaining a secure, consistent computing environment. We believe in open standards, and we believe in the continuous, repeatable security process SCAP makes possible. That's why we're proud to offer this **certified**, **open source** SCAP tool. OpenSCAP will make it much easier for agencies to add verifiable, repeatable scanning to their security process." *Gunnar Hellekson, chief strategist, U.S. Public Sector, [Red Hat](http://www.redhat.com/en)*

OpenSCAP Base received [SCAP 1.2 certification](https://www.redhat.com/en/about/press-releases/red-hat-continues-drive-open-security-standards-openscap-receives-nist-certification) from [NIST](https://nvd.nist.gov/scap/validation/128.cfm) on 29th April 2014.

## Do you need help with OpenSCAP Base?

**I have a problem I would like to ask about**

**OPTION 1**: Join the [mailing list](https://www.redhat.com/mailman/listinfo/open-scap-list).

**OPTION 2**: You can also join the #openscap IRC channel on Libera.Chat.

**I have found a bug / I want to create a new ticket**

File a bug against OpenSCAP Base on the [Github Issue Page](https://github.com/OpenSCAP/openscap/issues).

**I need more information**

See the [oscap user manual.](http://static.open-scap.org/openscap-1.2/oscap_user_manual.html)

**I want to help with development**

Read the instructions that you can find on [github.](https://github.com/OpenSCAP/openscap/blob/maint-1.2/docs/contribute/contribute.adoc)
