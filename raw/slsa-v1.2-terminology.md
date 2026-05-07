# Build: Terminology

Status: Approved

Before diving into the Build Track, we need to
establish a core set of terminology and models to describe what we're
protecting.

## Software supply chain

SLSA's framework addresses every step of the software supply chain - the
sequence of steps resulting in the creation of an artifact. We represent a
supply chain as a directed acyclic graph of sources, builds, dependencies, and
packages.

| Term | Description | Example |
| --- | --- | --- |
| Artifact | An immutable blob of data; primarily refers to software, but SLSA can be used for any artifact. | A file, a git commit, a directory of files (serialized in some way), a container image, a firmware image. |
| Attestation | An authenticated statement (metadata) about a software artifact or collection of software artifacts. | A signed SLSA Provenance file. |
| Source | Artifact that was directly authored or reviewed by persons, without modification. It is the beginning of the supply chain; we do not trace the provenance back any further. | Git commit (source) hosted on GitHub (platform). |
| Build | Process that transforms a set of input artifacts into a set of output artifacts. The inputs may be sources, dependencies, or ephemeral build outputs. | .travis.yml (process) run by Travis CI (platform). |
| Distribution | The channel through which artifacts are "published" for use by others. | A registry like DockerHub or npm. |
| Package | Artifact that is distributed. In the model, it is always the output of a build process, though that build process can be a no-op. | Docker image (package) distributed on DockerHub (distribution). |
| Dependency | Artifact that is an input to a build process but that is not a source. In the model, it is always a package. | Alpine package (package) distributed on Alpine Linux (platform). |

### Roles

| Role | Description | Examples |
| --- | --- | --- |
| Producer | A party who creates software and provides it to others. Producers are often also consumers. | An open source project's maintainers. A software vendor. |
| Verifier | A party who inspect an artifact's provenance to determine the artifact's authenticity. | A business's software ingestion system. A programming language ecosystem's package registry. |
| Consumer | A party who uses software provided by a producer. The consumer may verify provenance for software they consume or delegate that responsibility to a separate verifier. | A developer who uses open source software distributions. |
| Infrastructure provider | A party who provides software or services to other roles. | A package registry's maintainers. A build platform's maintainers. |

### Build model

We model a build as running on a multi-tenant *build platform*, where each
execution is independent.

1. A tenant invokes the build by specifying *external parameters* through an
   *interface*, either directly or via some trigger.
2. The build platform's *control plane* interprets these external parameters,
   fetches an initial set of dependencies, initializes a *build environment*,
   and then starts the execution within that environment.
3. The build then performs arbitrary steps, which might include fetching
   additional dependencies, and then produces one or more *output* artifacts.
   The build platform isolates build environments from one another to some
   degree (which is measured by the SLSA Build Level).
4. Finally, for SLSA Build L2+, the control plane outputs *provenance*
   describing this whole process.

| Primary Term | Description |
| --- | --- |
| Platform | System that allows tenants to run builds. |
| Admin | A privileged user with administrative access to the platform. |
| Tenant | An untrusted user that builds an artifact on the platform. |
| Control plane | Build platform component that orchestrates each independent build execution and produces provenance. |
| Build | Process that converts input sources and dependencies into output artifacts. |
| Build environment | The independent execution context in which the build runs. |
| External parameters | The set of top-level, independent inputs to the build, specified by a tenant. |
| Dependencies | Artifacts fetched during initialization or execution of the build process. |
| Outputs | Collection of artifacts produced by the build. |
| Provenance | Attestation (metadata) describing how the outputs were produced. |

### Distribution model

Software is distributed in identifiable units called packages
according to the rules and conventions of a package ecosystem.

The package name is the primary security boundary within a package ecosystem.
**The package name is the primary unit being protected in SLSA.**

| Term | Description |
| --- | --- |
| Distribution platform | An entity responsible for mapping package names to immutable package artifacts. |
| Package name | The primary identifier for a mutable collection of artifacts. |
| Package registry | A specific type of "distribution platform" used within a packaging ecosystem. |

### Verification model

Verification in SLSA is performed in two ways:
1. The build platform is certified to ensure conformance with the requirements at the level claimed.
2. Artifacts are verified to ensure they meet the producer-defined expectations of where the package source code was retrieved from and on what build platform the package was built.

| Term | Description |
| --- | --- |
| Expectations | A set of constraints on the package's provenance metadata. |
| Provenance verification | Artifacts are verified by the package ecosystem to ensure that the package's expectations are met before the package is used. |
| Build platform assessment | Build platforms are assessed for their ability to meet SLSA requirements at the stated level. |
