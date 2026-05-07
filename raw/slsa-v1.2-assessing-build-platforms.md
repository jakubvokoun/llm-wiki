# Build: Assessing build platforms

Status: Approved

One of SLSA's guiding principles is to "trust platforms, verify artifacts". However, consumers cannot trust platforms to produce Build L3 artifacts and provenance unless they have some proof that the provenance is unforgeable and the builds are isolated.

## Threats

### Adversary goal

The SLSA Build track defends against an adversary whose primary goal is to
inject unofficial behavior into a package artifact while avoiding detection.
To bypass provenance verification, the adversary tries to either:
(a) tamper with a legitimate build whose provenance already matches expectations, or
(b) tamper with an illegitimate build's provenance to make it match expectations.

### Adversary profiles

Build platforms should defend against three categories of adversaries:

1. **Project contributors** can create builds, modify external parameters, alter build environments, read and fork source repos, and build from forks.

2. **Project maintainers** possess all contributor capabilities plus the ability to create new builds under the target project, modify the source repo directly, and adjust build configuration.

3. **Build platform administrators** can perform all previous actions plus execute arbitrary code on the platform, read and modify network traffic, access control plane secrets, and remotely access build environments.

## Build platform components

Consumers SHOULD consider at least five elements when assessing build platforms: external parameters, control plane, build environments, caches, and outputs.

### External parameters

External parameters are the external interface to the builder and include all inputs to the build process (source, build definitions, environment configuration, user-provided strings).

Assessment questions:
- How does the control plane process user-provided external parameters?
- Which external parameters are processed by the control plane vs. the build environment?
- How do you ensure that all external parameters are represented in the provenance?
- How will you ensure future design changes maintain complete parameter documentation?

### Control plane

The control plane orchestrates each independent build execution, sets up and tears down builds, and generates and signs provenance at SLSA Build L2+. Administrators operate it with modification privileges.

Assessment areas:
- Administration: Ways employees can influence builds or provenance; detection/prevention controls; privileged account protection.
- Provenance generation: How control plane observes builds for accuracy; scenarios where provenance isn't generated.
- Development practices: How control plane software/configuration is tracked; supply chain confidence; inter-component security; forensic analysis capability.
- Creating build environments: How control plane shares data with build environments; how it protects cryptographic secrets.
- Managing cryptographic secrets: Storage; access; rotation frequency; compromise remediation.

### Build environment

Build environments are independent execution contexts where builds occur. Each must isolate from the control plane and from all other build environments.

Assessment areas:
- Isolation technologies: VMs, containers, or sandboxed processes; separation between trusted/untrusted; hardening against malicious tenants; update frequency; persistence prevention.
- Creation and destruction: Operating system and utilities available; how long a compromised environment could remain active.
- Network access: Remote execution capabilities; prevention of control plane tampering; network service exposure.

### Cache

Builders may have zero or more caches for frequently used dependencies.

Assessment questions:
- What sorts of caches are available?
- How are caches populated?
- How are cache contents validated before use?

### Output storage

Output Storage holds built artifacts and their provenance.

Assessment questions:
- How are builds prevented from reading or overwriting files that belong to another build?
- What processing does the control plane do on output artifacts?

## Builder evaluation

Organizations can either self-attest to their answers or seek certification from a third-party auditor. Evidence for self-attestation should be published on the internet and can include the security model defined as part of the provenance.
