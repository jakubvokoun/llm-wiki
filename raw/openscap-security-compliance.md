# Security Compliance

## Meet federal, state, and industry information security regulations instantly

Since security breaches can cause serious damage, the relationship between information security and the economic growth of businesses has been subject of many research studies.

The corresponding economic model implies that optimal information security policy should incorporate both possible approaches:

* A ***reactive*** one — having a well-defined [vulnerability assessment](/features/vulnerability-assessment/) strategy
* And a ***proactive*** one — application of currently available computer protection mechanisms, or countermeasures, in order to prevent, eliminate, or minimize the impact of security flaws.

Though security vulnerabilities are difficult or even impossible to predict, many of them require multiple conditions to be met at once in order to be successfully exploited. All these conditions can be avoided using the same strategy — through application and enforcement of a security policy which:

* Prevents retired user accounts from being reused
* Defines and enforces strong passwords based on multiple criteria such as length and character variety
* Forbids the use of protocols which are no longer considered secure

In order to minimize the threat of an attack on computer infrastructure, many institutions in both the private and public sectors have adopted the concept of enforcing a **security policy** or a **security benchmark**. These policies define security requirements which all systems used by the institution must meet. In some cases, these policies are defined by government regulations (e.g., DISA STIG, FedRAMP, FISMA, PCI DSS, USGCB, NIAP).

Despite the variety of the possible requirements, there are many common steps and procedures that any institution or business wishing to protect itself should perform:

- **Determine** the specific security baseline which the underlying computer infrastructure must comply with
- **Obtain** a security checklist for the requirement(s) in a format suitable for machine processing
- **Quickly identify the current state** of the computer infrastructure against the requirement(s)
- **React promptly** — perform **corrective operations** for requirements the system **did not meet**
- Prefer an **automated** approach — perform compliance analysis and corrective operations in a machine-controlled, unattended way on a regular basis
- **Utilize** proper software tools to carry out these tasks with **minimal effort**

#### The term **security compliance** (of a computer system against a particular security baseline) is used in the field of information security to denote the fact that, after performing a qualified analysis of necessary features of the system, the system in question has been recognized to be configured in a way **that is in line with all of the requirements as demanded by the particular security policy.**

#### Compliance assessment usually involves both steps — the compliance analysis of the system as well as the subsequent remedial action (performing corrective operations where the original inspection detected non-compliance).

Depending on its area of business, there may be numerous standards a particular organization must meet simultaneously in order to be compliant with all applicable laws and contractual obligations. This makes software tools like the OpenSCAP family, which can perform compliance assessments and corrective operations in an automated and continuous fashion, the perfect candidates for any organization trying to find a way to establish a proper and sustainable security compliance management policy.

## How the OpenSCAP Ecosystem Can Help

#### Obtain a list of security requirements in a format suitable for machine processing

Many security benchmarks provided by various security compliance authorities are supplied in the form of plaintext files. A substantial effort is currently being invested into conversion of these security guidance baselines into the form of various specifications as defined by the Security Content Automation Protocol (SCAP). The SCAP Security Guide project provides these baselines as practical security guidance, and also links them to compliance requirements to ease deployment activities such as certification and accreditation.

#### Quickly identify the current state of the computer infrastructure against the requirements

Ensuring **security compliance** of a system is a **continuous process**, and the ability to quickly compare the current state of a system to the requirements at any time is crucial. Tools in the OpenSCAP family can be easily used to perform a security compliance analysis at any time, even as part of a deployment process.

#### Perform instant corrective operations on any non-compliant systems

The SCAP-formatted security baselines provided by the SCAP Security Guide allow you to immediately remedy any non-compliance. Provided corrective scripts (also called "**remediation scripts**") can automatically perform configuration changes to your system. It is even possible to combine both steps — the original compliance analysis and subsequent remediation can be done at the same time using OpenSCAP tools.

#### Execute security compliance analysis and necessary corrective operations in automated, unattended way on regular basis

Having the automation available it is easy to schedule the compliance scans:

* Either on **regular basis** (to cover the case of routine inspection of the infrastructure)
* Or to schedule an **out-of-order scan** (to properly handle the situation when new software product needs to be included into the existing solutions)

#### Minimize required effort and outage periods

The OpenSCAP project provides tools that allow you to test your upgrades beforehand and to quickly and accurately verify updates. This keeps required downtime and outage periods down to a minimum.

## Practical Examples

Performing security compliance analysis of a RHEL 6.7 system using the USGCB profile:

```
# oscap xccdf eval −−profile usgcb-rhel6-server \
  −−results /tmp/usgcb-rhel6-server-results.xml \
  −−report /tmp/usgcb-rhel6-server-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-xccdf.xml
```

Performing both security compliance analysis and corrective operations (remediation):

```
# oscap xccdf eval −−remediate −−profile usgcb-rhel6-server \
  −−results /tmp/usgcb-rhel6-server-results.xml \
  −−report /tmp/usgcb-rhel6-server-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-xccdf.xml
```
