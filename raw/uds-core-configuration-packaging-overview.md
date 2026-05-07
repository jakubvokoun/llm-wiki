# Configuration and Packaging

There are two separate concerns to understand when working with UDS: **delivery** and **platform integration**. Knowing the distinction helps you find where to look when you need to change behavior.

|  | Delivery | Integration |
| --- | --- | --- |
| **Tool** | Zarf | UDS Operator |
| **Artifact** | Zarf package (OCI artifact) | Custom resources (Kubernetes objects) |
| **Solves** | Getting software into disconnected environments | Declaring what applications need from the platform |

In practice, an application's Zarf package typically includes a `Package` CR in one of its Helm charts. When deployed, the CR lands in the cluster and the UDS Operator reconciles it, generating networking, SSO, and monitoring resources automatically. The two systems work together, but they are independent concerns.

## In this section

**Bundles**

How Zarf packages are grouped into a single deployable artifact using the UDS CLI, including bundle structure, overrides, and deploy-time variables.

**Core CRDs**

The three custom resources (**Package**, **Exemption**, and **ClusterConfig**) that declare platform intent at runtime. The operator reconciles them into Kubernetes, Istio, and Keycloak resources.

**UDS Package Requirements**

The standards a UDS Package must meet to be secure, maintainable, and compatible with UDS Core, with RFC-2119 requirement levels for each.
