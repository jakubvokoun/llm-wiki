---
source_url: https://www.first.org/cvss/v4.0/specification-document
fetched: 2026-06-19
---

# Common Vulnerability Scoring System version 4.0: Specification Document

Also available [in PDF format](/cvss/v4-0/cvss-v40-specification.pdf).

Document Version: 1.2

The Common Vulnerability Scoring System (CVSS) is an open framework for
communicating the characteristics and severity of software vulnerabilities. CVSS
consists of four metric groups: Base, Threat, Environmental, and Supplemental.
The Base group represents the intrinsic qualities of a vulnerability that are
constant over time and across user environments, the Threat group reflects the
characteristics of a vulnerability that change over time, and the Environmental
group represents the characteristics of a vulnerability that are unique to a
user's environment. Base metric values are combined with default values that
assume the highest severity for Threat and Environmental metrics to produce a
score ranging from 0 to 10. To further refine a resulting severity score, Threat
and Environmental metrics can then be amended based on applicable threat
intelligence and environmental considerations. Supplemental metrics do not
modify the final score, and are used as additional insight into the
characteristics of a vulnerability. A CVSS vector string consists of a
compressed textual representation of the values used to derive the score. This
document provides the official specification for CVSS version 4.0.

The most current CVSS resources can be found at https://www.first.org/cvss/

CVSS is owned and managed by FIRST.Org, Inc. (FIRST), a US-based non-profit
organization, whose mission is to help computer security incident response teams
across the world. FIRST reserves the right to update CVSS and this document
periodically at its sole discretion. While FIRST owns all rights and interest in
CVSS, it licenses it to the public freely for use, subject to the conditions
below. Membership in FIRST is not required to use or implement CVSS. FIRST does,
however, require that any individual or entity using CVSS give proper
attribution, where applicable, that CVSS is owned by FIRST and used by
permission. Further, FIRST requires as a condition of use that any individual or
entity which publishes CVSS data conforms to the guidelines described in this
document and provides both the score and the vector string so others can
understand how the score was derived.

## Introduction

The Common Vulnerability Scoring System (CVSS) captures the principal technical
characteristics of software, hardware and firmware vulnerabilities. Its outputs
include numerical scores indicating the severity of a vulnerability relative to
other vulnerabilities.

CVSS is composed of four metric groups: Base, Threat, Environmental, and
Supplemental. The Base Score reflects the severity of a vulnerability according
to its intrinsic characteristics which are constant over time and assumes the
reasonable worst-case impact across different deployed environments. The Threat
Metrics adjust the severity of a vulnerability based on factors, such as the
availability of proof-of-concept code or active exploitation. The Environmental
Metrics further refine the resulting severity score to a specific computing
environment. They consider factors such as the presence of mitigations in that
environment and the criticality attributes of the vulnerable system. Finally,
the Supplemental Metrics describe and measure additional extrinsic attributes of
a vulnerability, intended to add context.

Base Metrics, and optionally Supplemental Metrics, are provided by the
organization maintaining the vulnerable system, or a third party assessment on
their behalf. Threat and Environmental information is available to only the end
consumer. Consumers of CVSS should enrich the Base metrics with Threat and
Environmental metric values specific to their use of the vulnerable system to
produce a score that provides a more comprehensive input to risk assessment
specific to their organization. Consumers may use CVSS information as input to
an organizational vulnerability management process that also considers factors
that are not part of CVSS in order to rank the threats to their technology
infrastructure and make informed remediation decisions. Such factors may
include, but are not limited to: regulatory requirements, number of customers
impacted, monetary losses due to a breach, life or property threatened, or
reputational impacts of a potential exploited vulnerability. These factors are
outside the scope of CVSS.

The benefits of CVSS include the provisioning of a standardized vendor and
platform agnostic vulnerability scoring methodology. It is an open framework,
providing transparency to the individual characteristics and methodology used to
derive a score.

## Metrics

CVSS is composed of four metric groups: Base, Threat, Environmental, and
Supplemental, each consisting of a set of metrics.

The Base metric group represents the intrinsic characteristics of a
vulnerability that are constant over time and across user environments. It is
composed of two sets of metrics: the Exploitability metrics and the Impact
metrics.

The Exploitability metrics reflect the ease and technical means by which the
vulnerability can be exploited. That is, they represent characteristics of the
"thing that is vulnerable", which we refer to formally as the "vulnerable
system". The Impact metrics reflect the direct consequence of a successful
exploit, and represent the consequence to the "things that suffer the impact",
which may include impact on the vulnerable system and/or the downstream impact
on what is formally called the "subsequent system(s)".

While the vulnerable system is typically a software application, operating
system, module, driver, etc. (or possibly a hardware device), the subsequent
system could be any of those examples but also includes human safety. This
potential for measuring the impact of a vulnerability other than the vulnerable
system, was a key feature introduced with CVSS v3.0. This property (formerly
known as "Scope"), is captured by the separation of impacts to the vulnerable
system and to subsequent systems, discussed later.

The Threat metric group reflects the characteristics of a vulnerability related
to threat that may change over time but not necessarily across user
environments. For example, confirmation that the vulnerability has neither been
exploited nor has any proof-of-concept exploit code or instructions publicly
available will lower the resulting CVSS score. The values found in this metric
group may change over time.

The Environmental metric group represents the characteristics of a vulnerability
that are relevant and unique to a particular consumers' environment.
Considerations include the presence of security controls which may mitigate some
or all consequences of a successful attack, and the relative importance of a
vulnerable system within a technology infrastructure.

The Supplemental metric group includes metrics that provide context as well as
describe and measure additional extrinsic attributes of a vulnerability. The
response to each metric within the Supplemental metric group is to be determined
by the CVSS consumer, allowing the usage of an end-user risk analysis system to
apply locally significant severity to the metrics and values. No metric will,
within its specification, have any impact on the final CVSS score. Consumer
organizations may then assign importance and/or effective impact of each metric,
or set/combination of metrics, giving them more, less, or absolutely no effect
on the categorization, prioritization, and assessment of the vulnerability.
Metrics and values will simply convey additional extrinsic characteristics of
the vulnerability itself.

Each of these metrics are discussed in further detail below. The User Guide
contains scoring rubrics for the Base Metrics that may be useful when scoring.

## Assessment

When the Base metrics are assigned values by an analyst, the Base metrics
assessment results in a score ranging from 0.0 to 10.0.

The Base metrics assessment can then be further refined by assessing the Threat
and Environmental metrics in order to more accurately reflect the relative
severity posed by a vulnerability to a user's environment at a specific point in
time. Assessment of the Threat and Environmental metrics is not required, but is
highly recommended for more meaningful results.

Generally, the Base metrics are specified by vulnerability bulletin analysts,
product vendors, or application vendors because they typically possess the most
accurate information about the characteristics of a vulnerability. The Threat
and Environmental metrics are specified by consumer organizations because they
are best able to assess the potential impact of a vulnerability within their own
computing environment, at a given point in time.

Assessing CVSS metrics also produces a vector string, a textual representation
of the metric values used to derive a quantitative score and qualitative rating
for the vulnerability. This vector string is a specifically formatted text
string that contains each value assigned to each metric, and should be displayed
with the vulnerability score.

The scoring assessment and vector string are explained further below.

Note that all metrics should be assessed under the assumption that the attacker
has perfect knowledge of the vulnerability. That is, the analyst need not
consider the means by which the vulnerability was identified. In addition, it is
likely that many different types of individuals will be assessing
vulnerabilities (e.g., software vendors, vulnerability bulletin analysts,
security product vendors), however, note that CVSS assessment is intended to be
agnostic to the individual and their organization.

## Nomenclature

Numerical CVSS Scores have very different meanings based on the metrics used to
calculate them. Regarding prioritization, the usefulness of a numerical CVSS
score is directly proportional to the CVSS metrics leveraged to generate that
score. Therefore, numerical CVSS scores should be labeled using nomenclature
that communicates the metrics used in its generation.

| **CVSS Nomenclature** | **CVSS Metrics Used** |
| --- | --- |
| CVSS-B | Base metrics |
| CVSS-BE | Base and Environmental metrics |
| CVSS-BT | Base and Threat metrics |
| CVSS-BTE | Base, Threat, Environmental metrics |

Additional Notes:

* This nomenclature should be used wherever a numerical CVSS value is
  displayed or communicated.
* The application of Environmental and Threat metrics is the responsibility of
  the CVSS consumer. Assessment providers such as product maintainers and
  other public/private entities such as the National Vulnerability Database
  (NVD) typically provide only the Base Scores enumerated as CVSS-B.
* The inclusion of the "E" in the nomenclature is appropriate if any
  Environmental metrics are used to generate the resulting score.
* The inclusion of the "T" in the nomenclature is appropriate if any Threat
  metrics are used to generate the resulting score.
* In CVSS v4.0, Base, Threat, and Environmental metric values are always
  considered in the calculation of the final score. The absence of explicit
  Threat and/or Environmental metric selections will still result in a
  complete score using default ("Not Defined") values. This nomenclature makes
  it explicit and clear about which metric groups were considered in the
  numerical CVSS score provided.

## Base Metrics

### Exploitability Metrics

As previously mentioned, the Exploitability metrics reflect the characteristics
of the "thing that is vulnerable", which we refer to formally as the
vulnerable system. Therefore, each of the Exploitability metrics listed below
should be assessed relative to the vulnerable system, and reflect the properties
of the vulnerability that lead to a successful attack.

When assessing Base metrics, it should be assumed that the attacker has advanced
knowledge of the target system, including general configuration and default
defense mechanisms (e.g., built-in firewalls, rate limits, traffic policing).
For example, exploiting a vulnerability that results in repeatable,
deterministic success should still be considered a Low value for Attack
Complexity, independent of the attacker's knowledge or capabilities.
Furthermore, target-specific attack mitigation (e.g., custom firewall filters,
access lists) should instead be reflected in the Environmental metric scoring
group.

Specific configurations should not impact any attribute contributing to the CVSS
Base metric assessment, i.e., if a specific configuration is required for an
attack to succeed, the vulnerable system should be assessed assuming it is in
that configuration.

#### Attack Vector (AV)

This metric reflects the context by which vulnerability exploitation is
possible. This metric value (and consequently the resulting severity) will be
larger the more remote (logically, and physically) an attacker can be in order
to exploit the vulnerable system. The assumption is that the number of potential
attackers for a vulnerability that could be exploited from across a network is
larger than the number of potential attackers that could exploit a vulnerability
requiring physical access to a device, and therefore warrants a greater
severity. The list of possible values is presented in Table 1.

**Table 1: Attack Vector**

| **Metric Value** | **Description** |
| --- | --- |
| Network (N) | The vulnerable system is bound to the network stack and the set of possible attackers extends beyond the other options listed below, up to and including the entire Internet. Such a vulnerability is often termed "remotely exploitable" and can be thought of as an attack being exploitable at the protocol level one or more network hops away (e.g., across one or more routers). An example of a network attack is an attacker causing a denial of service (DoS) by sending a specially crafted TCP packet across a wide area network (e.g., CVE-2004-0230). |
| Adjacent (A) | The vulnerable system is bound to a protocol stack, but the attack is limited at the protocol level to a logically adjacent topology. This can mean an attack must be launched from the same shared proximity (e.g., Bluetooth, NFC, or IEEE 802.11) or logical network (e.g., local IP subnet), or from within a secure or otherwise limited administrative domain (e.g., MPLS, secure VPN within an administrative network zone). One example of an Adjacent attack would be an ARP (IPv4) or neighbor discovery (IPv6) flood leading to a denial of service on the local LAN segment (e.g., CVE-2013-6014). |
| Local (L) | The vulnerable system is not bound to the network stack and the attacker's path is via read/write/execute capabilities. Either: the attacker exploits the vulnerability by accessing the target system locally (e.g., keyboard, console), or through terminal emulation (e.g., SSH); or the attacker relies on User Interaction by another person to perform actions required to exploit the vulnerability (e.g., using social engineering techniques to trick a legitimate user into opening a malicious document). |
| Physical (P) | The attack requires the attacker to physically touch or manipulate the vulnerable system. Physical interaction may be brief (e.g., evil maid attack) or persistent. An example of such an attack is a cold boot attack in which an attacker gains access to disk encryption keys after physically accessing the target system. Other examples include peripheral attacks via FireWire/USB Direct Memory Access (DMA). |

*Assessment Guidance*: When deciding between Network and Adjacent, if an attack
can be launched over a wide area network or from outside the logically adjacent
administrative network domain, use Network.

#### Attack Complexity (AC)

This metric captures measurable actions that must be taken by the attacker to
actively evade or circumvent existing built-in security-enhancing conditions
in order to obtain a working exploit. These are conditions whose primary purpose
is to increase security and/or increase exploit engineering complexity. A
vulnerability exploitable without a target-specific variable has a lower
complexity than a vulnerability that would require non-trivial customization.
This metric is meant to capture security mechanisms utilized by the vulnerable
system, and does not relate to the amount of time or attempts it would take for
an attacker to succeed, e.g. a race condition. If the attacker does not take
action to overcome these conditions, the attack will always fail.

The evasion or satisfaction of authentication mechanisms or requisites is
included in the Privileges Required assessment and is not considered here as
a factor of relevance for Attack Complexity.

**Table 2: Attack Complexity**

| **Metric Value** | **Description** |
| --- | --- |
| Low (L) | The attacker must take no measurable action to exploit the vulnerability. The attack requires no target-specific circumvention to exploit the vulnerability. An attacker can expect repeatable success against the vulnerable system. |
| High (H) | The successful attack depends on the evasion or circumvention of security-enhancing techniques in place that would otherwise hinder the attack. These include: Evasion of exploit mitigation techniques. The attacker must have additional methods available to bypass security measures in place. For example, circumvention of address space randomization (ASLR) or data execution prevention (DEP) must be performed for the attack to be successful. Obtaining target-specific secrets. The attacker must gather some target-specific secret before the attack can be successful. A secret is any piece of information that cannot be obtained through any amount of reconnaissance. To obtain the secret the attacker must perform additional attacks or break otherwise secure measures (e.g. knowledge of a secret key may be needed to break a crypto channel). This operation must be performed for each attacked target. |

#### Attack Requirements (AT)

This metric captures the prerequisite deployment and execution conditions or
variables of the vulnerable system that enable the attack. These differ from
security-enhancing techniques/technologies as the primary purpose of these
conditions is not to explicitly mitigate attacks, but rather, emerge naturally
as a consequence of the deployment and execution of the vulnerable system. If
the attacker does not take action to overcome these conditions, the attack may
succeed only occasionally or not succeed at all.

**Table 3: Attack Requirements**

| **Metric Value** | **Description** |
| --- | --- |
| None (N) | The successful attack does not depend on the deployment and execution conditions of the vulnerable system. The attacker can expect to be able to reach the vulnerability and execute the exploit under all or most instances of the vulnerability. |
| Present (P) | The successful attack depends on the presence of specific deployment and execution conditions of the vulnerable system that enable the attack. These include: A race condition must be won to successfully exploit the vulnerability. The successfulness of the attack is conditioned on execution conditions that are not under full control of the attacker. The attack may need to be launched multiple times against a single target before being successful. Network injection. The attacker must inject themselves into the logical network path between the target and the resource requested by the victim (e.g. vulnerabilities requiring an on-path attacker). |

#### Privileges Required (PR)

This metric describes the level of privileges an attacker must possess prior
to successfully exploiting the vulnerability. The method by which the attacker
obtains privileged credentials prior to the attack (e.g., free trial accounts),
is outside the scope of this metric. Generally, self-service provisioned
accounts do not constitute a privilege requirement if the attacker can grant
themselves privileges as part of the attack.

The resulting score is greatest if no privileges are required. The list of
possible values is presented in Table 4.

**Table 4: Privileges Required**

| **Metric Value** | **Description** |
| --- | --- |
| None (N) | The attacker is unauthenticated prior to attack, and therefore does not require any access to settings or files of the vulnerable system to carry out an attack. |
| Low (L) | The attacker requires privileges that provide basic capabilities that are typically limited to settings and resources owned by a single low-privileged user. Alternatively, an attacker with Low privileges has the ability to access only non-sensitive resources. |
| High (H) | The attacker requires privileges that provide significant (e.g., administrative) control over the vulnerable system allowing full access to the vulnerable system's settings and files. |

**Assessment Guidance:** Privileges Required is usually None for hard-coded
credential vulnerabilities or vulnerabilities requiring social engineering
(e.g., reflected cross-site scripting, cross-site request forgery, or file
parsing vulnerability in a PDF reader). Default credentials that have not been
changed or are not unique across each environment should be treated similarly to
hard-coded credentials.

#### User Interaction (UI)

This metric captures the requirement for a human user, other than the attacker,
to participate in the successful compromise of the vulnerable system. This
metric determines whether the vulnerability can be exploited solely at the will
of the attacker, or whether a separate user (or user-initiated process) must
participate in some manner. The resulting score is greatest when no user
interaction is required. The list of possible values is presented in Table 5.

**Table 5: User Interaction**

| **Metric Value** | **Description** |
| --- | --- |
| None (N) | The vulnerable system can be exploited without interaction from any human user, other than the attacker. Examples include: a remote attacker is able to send packets to a target system; a locally authenticated attacker executes code to elevate privileges |
| Passive (P) | Successful exploitation of this vulnerability requires limited interaction by the targeted user with the vulnerable system and the attacker's payload. These interactions would be considered involuntary and do not require that the user actively subvert protections built into the vulnerable system. Examples include: utilizing a website that has been modified to display malicious content when the page is rendered (most stored XSS or CSRF); running an application that calls a malicious binary that has been planted on the system; using an application which generates traffic over an untrusted or compromised network (vulnerabilities requiring an on-path attacker) |
| Active (A) | Successful exploitation of this vulnerability requires a targeted user to perform specific, conscious interactions with the vulnerable system and the attacker's payload, or the user's interactions would actively subvert protection mechanisms which would lead to exploitation of the vulnerability. Examples include: importing a file into a vulnerable system in a specific manner; placing files into a specific directory prior to executing code; submitting a specific string into a web application (e.g. reflected or self XSS); dismiss or accept prompts or security warnings prior to taking an action (e.g. opening/editing a file, connecting a device). |

### Impact Metrics

The Impact metrics capture the effects of a successfully exploited
vulnerability. Analysts should constrain impacts to a reasonable, final outcome
which they are confident an attacker is able to achieve.

Only an increase in access, privileges gained, or other negative outcome as a
result of successful exploitation should be considered when assessing the Impact
metrics of a vulnerability. For example, consider a vulnerability that requires
read-only permissions prior to being able to exploit the vulnerability. After
successful exploitation, the attacker maintains the same level of read access,
and gains write access. In this case, only the Integrity impact metric should be
scored, and the Confidentiality and Availability Impact metrics should be set as
None.

Note that when scoring a delta change in impact, the final impact should be
used. For example, if an attacker starts with partial access to restricted
information (Confidentiality Low) and successful exploitation of the
vulnerability results in complete loss in confidentiality (Confidentiality
High), then the resultant CVSS Base metric value should reference the "end game"
Impact metric value (Confidentiality High).

When identifying values for the impact metrics, assessment providers need to
account for impacts both to the Vulnerable System and impacts outside of the
Vulnerable System. These impacts are established by two sets of impact metrics:
"Vulnerable System impact" and "Subsequent System impact". When establishing
the boundaries for the Vulnerable System metric values, assessment providers
should use the conceptual model of a system of interest.

Formally, a system of interest for scoring a vulnerability is defined as the set
of computing logic that executes in an environment with a coherent function and
set of security policies. The vulnerability exists in one or more components of
such a system. A technology product or a solution that serves a purpose or
function from a consumer's perspective is considered a system (e.g., a server,
workstation, containerized service, etc.).

When a system provides its functionality solely to another system, or it is
designed to be exclusively used by another system, then together they are
considered as the system of interest for scoring. For example, a database used
solely by a smart speaker is considered a part of that smart speaker system.
Both the database and the smart speaker it serves would be considered the
vulnerable system if a vulnerability in that database leads to the malfunction
of the smart speaker. When a vulnerability does not have impact outside of the
vulnerable system assessment providers should leave the subsequent system impact
metrics as NONE (N).

All impacts, if any, that occur outside of the vulnerable system should be
reflected in the subsequent system impact set. When assessed in the
environmental metric group only, the subsequent system impact may, in addition
to the logical systems defined for System of Interest, also include impacts to
humans. This human impact option in the environmental metric group is explained
further in Safety (S), below.

#### Confidentiality (VC/SC)

This metric measures the impact to the confidentiality of the information
managed by the system due to a successfully exploited vulnerability.
Confidentiality refers to limiting information access and disclosure to only
authorized users, as well as preventing access by, or disclosure to,
unauthorized ones. The resulting score is greatest when the loss to the system
is highest. The list of possible values is presented in Table 6 (for the
Vulnerable System) and Table 7 (when there is a Subsequent System impacted).

**Table 6: Confidentiality Impact to the Vulnerable System (VC)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of confidentiality, resulting in all information within the Vulnerable System being divulged to the attacker. Alternatively, access to only some restricted information is obtained, but the disclosed information presents a direct, serious impact. For example, an attacker steals the administrator's password, or private encryption keys of a web server. |
| Low (L) | There is some loss of confidentiality. Access to some restricted information is obtained, but the attacker does not have control over what information is obtained, or the amount or kind of loss is limited. The information disclosure does not cause a direct, serious loss to the Vulnerable System. |
| None (N) | There is no loss of confidentiality within the Vulnerable System. |

**Table 7: Confidentiality Impact to the Subsequent System (SC)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of confidentiality, resulting in all resources within the Subsequent System being divulged to the attacker. Alternatively, access to only some restricted information is obtained, but the disclosed information presents a direct, serious impact. For example, an attacker steals the administrator's password, or private encryption keys of a web server. |
| Low (L) | There is some loss of confidentiality. Access to some restricted information is obtained, but the attacker does not have control over what information is obtained, or the amount or kind of loss is limited. The information disclosure does not cause a direct, serious loss to the Subsequent System. |
| None (N) | There is no loss of confidentiality within the Subsequent System or all confidentiality impact is constrained to the Vulnerable System. |

#### Integrity (VI/SI)

This metric measures the impact to integrity of a successfully exploited
vulnerability. Integrity refers to the trustworthiness and veracity of
information. Integrity of a system is impacted when an attacker causes
unauthorized modification of system data. Integrity is also impacted when a
system user can repudiate critical actions taken in the context of the system
(e.g. due to insufficient logging).

The resulting score is greatest when the consequence to the system is highest.
The list of possible values is presented in Table 8 (for the Vulnerable System)
and Table 9 (when there is a Subsequent System impacted).

**Table 8: Integrity Impact to the Vulnerable System (VI)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of integrity, or a complete loss of protection. For example, the attacker is able to modify any/all files protected by the Vulnerable System. Alternatively, only some files can be modified, but malicious modification would present a direct, serious consequence to the Vulnerable System. |
| Low (L) | Modification of data is possible, but the attacker does not have control over the consequence of a modification, or the amount of modification is limited. The data modification does not have a direct, serious impact to the Vulnerable System. |
| None (N) | There is no loss of integrity within the Vulnerable System. |

**Table 9: Integrity Impact to the Subsequent System (SI)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of integrity, or a complete loss of protection. For example, the attacker is able to modify any/all files protected by the Subsequent System. Alternatively, only some files can be modified, but malicious modification would present a direct, serious consequence to the Subsequent System. |
| Low (L) | Modification of data is possible, but the attacker does not have control over the consequence of a modification, or the amount of modification is limited. The data modification does not have a direct, serious impact to the Subsequent System. |
| None (N) | There is no loss of integrity within the Subsequent System or all integrity impact is constrained to the Vulnerable System. |

#### Availability (VA/SA)

This metric measures the impact to the availability of the impacted system
resulting from a successfully exploited vulnerability. While the Confidentiality
and Integrity impact metrics apply to the loss of confidentiality or integrity
of data (e.g., information, files) used by the system, this metric refers to
the loss of availability of the impacted system itself, such as a networked
service (e.g., web, database, email). Since availability refers to the
accessibility of information resources, attacks that consume network bandwidth,
processor cycles, or disk space all impact the availability of a system. The
resulting score is greatest when the consequence to the system is highest. The
list of possible values is presented in Table 10 (for the Vulnerable System) and
Table 11 (when there is a Subsequent System impacted).

**Table 10: Availability Impact to the Vulnerable System (VA)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of availability, resulting in the attacker being able to fully deny access to resources in the Vulnerable System; this loss is either sustained (while the attacker continues to deliver the attack) or persistent (the condition persists even after the attack has completed). Alternatively, the attacker has the ability to deny some availability, but the loss of availability presents a direct, serious consequence to the Vulnerable System (e.g., the attacker cannot disrupt existing connections, but can prevent new connections; the attacker can repeatedly exploit a vulnerability that, in each instance of a successful attack, leaks a only small amount of memory, but after repeated exploitation causes a service to become completely unavailable). |
| Low (L) | Performance is reduced or there are interruptions in resource availability. Even if repeated exploitation of the vulnerability is possible, the attacker does not have the ability to completely deny service to legitimate users. The resources in the Vulnerable System are either partially available all of the time, or fully available only some of the time, but overall there is no direct, serious consequence to the Vulnerable System. |
| None (N) | There is no impact to availability within the Vulnerable System. |

**Table 11: Availability Impact to the Subsequent System (SA)**

| **Metric Value** | **Description** |
| --- | --- |
| High (H) | There is a total loss of availability, resulting in the attacker being able to fully deny access to resources in the Subsequent System; this loss is either sustained (while the attacker continues to deliver the attack) or persistent (the condition persists even after the attack has completed). Alternatively, the attacker has the ability to deny some availability, but the loss of availability presents a direct, serious consequence to the Subsequent System (e.g., the attacker cannot disrupt existing connections, but can prevent new connections; the attacker can repeatedly exploit a vulnerability that, in each instance of a successful attack, leaks a only small amount of memory, but after repeated exploitation causes a service to become completely unavailable). |
| Low (L) | Performance is reduced or there are interruptions in resource availability. Even if repeated exploitation of the vulnerability is possible, the attacker does not have the ability to completely deny service to legitimate users. The resources in the Subsequent System are either partially available all of the time, or fully available only some of the time, but overall there is no direct, serious consequence to the Subsequent System. |
| None (N) | There is no impact to availability within the Subsequent System or all availability impact is constrained to the Vulnerable System. |

## Threat Metrics

The Threat metrics measure the characteristics of a vulnerability that may change over time related to the availability and effectiveness of exploit code, techniques, and the probability of discovery or disclosure of the vulnerability.

## Environmental Metrics

The Environmental metrics represent characteristics that are specific to the operating environment or user organization and are not intrinsic to the vulnerability itself.

## Supplemental Metrics

The Supplemental metrics provide additional context and attributes about the vulnerability but do not affect the CVSS score itself.
