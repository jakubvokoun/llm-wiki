## SCAP may seem complex at first glance. Let's walk through a simple use case as an introduction.

# Getting Started

On this page, we will walk you through the process of security compliance evaluation using SCAP on a single system. Keep in mind that this is only an example to illustrate the basic principles of OpenSCAP and we will intentionally cut corners and sacrifice some flexibility to keep the example simple. Consider this document the first step towards OpenSCAP proficiency. If you decide to try the procedure outlined below for yourself, we recommend that you use SCAP Workbench, a tool which provides a graphical interface for OpenSCAP.

### Scanner

SCAP scanner — which we will sometimes refer to as "the tool" — is an application that reads SCAP security policy and checks whether or not the system is compliant with it. It goes through all rules defined in the policy one by one and reports whether each rule is fulfilled. If all checks pass, the system is compliant with the security policy.

### Security Policy

Security policies — also called "SCAP content" or just "content" — are the centerpoint of any compliance strategy. They determine how a system must be set up and what to check for.

## 1. First Scan Using a Graphical Interface

### 1.1. Installation

OpenSCAP offers many tools to scan your systems. For your first scan, we recommend using [SCAP Workbench](/tools/scap-workbench/), which can be easily obtained on many different operating systems. If you are using Fedora, Red Hat Enterprise Linux, CentOS, or Scientific Linux, you can install this tool and all necessary dependencies using the following command:

# yum install scap-workbench

Once you install and start SCAP Workbench, you will see a graphical tool providing a simple interface to a certified [OpenSCAP scanner](/tools/openscap-base/). The interface allows you to select scan parameters and run a scan in only a few mouse clicks, as we're about to demonstrate.

### 1.2. Selecting a Security Policy

The next step is to choose an appropriate [security policy](/security-policies/choosing-policy/). These policies contain machine-readable descriptions of the rules which your system will be required to follow. Several policies which you can choose from are provided by [SCAP Security Guide](/security-policies/scap-security-guide/) (SSG), which is installed automatically as a dependency of SCAP Workbench, but you can also provide your own policy.

### 1.3. Selecting a Profile

Each security policy can contain multiple profiles, which provide sets of rules and values implemented according to a specific security baseline. You can think of a profile as a particular subset of rules within the policy; the profile determines which rules defined in the policy are selected (checked) and what values are used during the evaluation.

### 1.4. Evaluation

After you select a policy and a profile, you can start your first scan. The process usually takes a few minutes, depending on the number of selected rules.

When the evaluation is completed, SCAP Workbench will display an overview of scan results. You can save the results in various formats — HTML, ARF, or XCCDF.

## 2. First Scan Using a Command Line

In the previous section we have performed an evaluation using a graphical tool called [SCAP Workbench](/tools/scap-workbench). Let us now apply these skills and perform an evaluation using the NIST-certified OpenSCAP Scanner directly.

### 2.1. Installation

In the following procedure, we will be using the oscap tool from [OpenSCAP Base](/tools/openscap-base/). If you followed the previous example and installed SCAP Workbench, this tool has been downloaded as a dependency. If you haven't, you can install the package using the following command:

# yum install openscap-scanner

### 2.2. Selecting a Security Policy

The oscap does not provide any security policies on its own — you have to obtain the rule sets from a separate package. On Fedora, RHEL, CentOS or Scientific Linux, default policies are provided by [SCAP Security Guide](/security-policies/scap-security-guide/) (SSG). Again, if you followed the previous procedure, this package should already be installed on your system; if not, you can use the following command to add it:

# yum install scap-security-guide

SSG policy files are located in the **/usr/share/xml/scap/ssg/content/** directory. In this example, we will choose a policy for Red Hat Enterprise Linux 6: **ssg-rhel6-ds.xml**. You can list all available security policies by getting a list of datastream files:

ls -1 /usr/share/xml/scap/ssg/content/ssg-\*-ds.xml

### 2.3. Selecting a Profile

Each security policy can have multiple profiles which provide policies implemented according to specific security baselines. Every profile can select different rules and use different values. You can list these profiles using the following command:

$ oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml

```
$ oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
Document type: Source Data Stream
Imported: 2015-07-13T10:23:11

Stream: scap_org.open-scap_datastream_from_xccdf_ssg-rhel6-xccdf-1.2.xml
Generated: (null)
Version: 1.2
Checklists:
        Ref-Id: scap_org.open-scap_cref_ssg-rhel6-xccdf-1.2.xml
                Profiles:
                        xccdf_org.ssgproject.content_profile_CS2
                        xccdf_org.ssgproject.content_profile_common
                        xccdf_org.ssgproject.content_profile_server
                        xccdf_org.ssgproject.content_profile_stig-rhel6-server-upstream
                        xccdf_org.ssgproject.content_profile_usgcb-rhel6-server
                        xccdf_org.ssgproject.content_profile_rht-ccp
                        xccdf_org.ssgproject.content_profile_CSCF-RHEL6-MLS
                        xccdf_org.ssgproject.content_profile_C2S
                        xccdf_org.ssgproject.content_profile_pci-dss
                Referenced check files:
                        ssg-rhel6-oval.xml
                                system: http://oval.mitre.org/XMLSchema/oval-definitions-5
Checks:
        Ref-Id: scap_org.open-scap_cref_ssg-rhel6-oval.xml
        Ref-Id: scap_org.open-scap_cref_output--ssg-rhel6-cpe-oval.xml
        Ref-Id: scap_org.open-scap_cref_output--ssg-rhel6-oval.xml
Dictionaries:
        Ref-Id: scap_org.open-scap_cref_output--ssg-rhel6-cpe-dictionary.xml
```

An example of a profile is USGCB: xccdf_org.ssgproject.content_profile_usgcb-rhel6-server.

For the purposes of this document, we will use the **xccdf_org.ssgproject.content_profile_rht-ccp** profile, which is a profile for Certified Cloud Providers (CCP). Feel free to try the other profiles as well.

### 2.4. Evaluation

Now that we have determined which security policy and profile we want to use, let's use oscap to perform an evaluation against them. The following command-line invocation may seem daunting at first, but it's no different from what we have done in the previous procedure using [SCAP Workbench](/tools/scap-workbench/):

```
# oscap xccdf eval \
 --profile xccdf_org.ssgproject.content_profile_rht-ccp \
 --results-arf arf.xml \
 --report report.html \
 /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

The options can be broken down as follows:

* `--profile` chooses the profile; we used a profile chooser combobox for this in SCAP Workbench.
* `--results-arf` tells oscap that we want the results stored as an ARF in a file called **arf.xml**.
* `--report` Requests that oscap also generates an HTML report alongside the ARF.

The evaluation process usually takes a few minutes, depending on the number of selected rules. Similarly to SCAP Workbench, oscap will also provide you an overview of results after it's finished, and you will find reports saved and available for review in your current working directory.

Congratulations! You can now perform a local SCAP compliance scan and generate reports using both a graphical interface and the command line.

## Where to go from here?

- [Tutorials](/resources/documentation/)
- [Tools](/tools/)
- [Security Policies](/security-policies/)
- [Profile Customization](/security-policies/customization/)
