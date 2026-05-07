# Platform

UDS Core turns a Kubernetes cluster into a secure, observable platform. It provides shared services (networking, identity, observability, security, and backup) so application teams can focus on mission logic instead of infrastructure plumbing.

## In This Section

**Functional Layers**

How UDS Core is split into discrete capability packages: layer selection, dependency ordering, and when to use individual layers instead of the full package.

**Supported Distributions**

Kubernetes distributions tested in CI and the current version target for the platform.

**Environments**

How Core adapts its configuration across dev, staging, and production environments.

**Platform vs Application Layer**

The responsibility boundary between the shared platform and the mission workloads that run on it.

**Flavors (Core Variants)**

Choosing between the upstream, registry1, and unicorn image variants and their CVE posture.

**Security**

Layered defense model: supply chain, airgap, identity/SSO, zero-trust networking, admission control, runtime security, observability, compliance readiness.

**Versioning & Releases**

Release cadence, semantic versioning strategy, version support window, and deprecation policy.
