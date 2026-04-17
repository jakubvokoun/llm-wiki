---
title: "ABAC / ReBAC (Attribute and Relationship Based Access Control)"
tags: [abac, rebac, access-control, authorization, attributes, relationships]
sources: [owasp-authorization.md]
updated: 2026-04-16
---

# ABAC / ReBAC

## Attribute-Based Access Control (ABAC)

ABAC is an access control model where "subject requests to perform operations on objects are granted or denied based on assigned attributes of the subject, assigned attributes of the object, environment conditions, and a set of policies that are specified in terms of those attributes and conditions" (NIST SP 800-162).

**Key components:**

- **Subject attributes**: user role, department, clearance level, employment status
- **Object attributes**: data classification, owner, creation date, project
- **Environment conditions**: time of day, network location, device type, geographic region
- **Policies**: logical expressions combining the above (e.g., "Sales rep can read customer records from the internal network during business hours")

## Relationship-Based Access Control (ReBAC)

ReBAC grants access based on the relationships between resources and users. Rather than assigning roles, the system queries: "does user X have relationship Y with object Z?"

Examples:

- "Allow only the user who created this post to edit it"
- "Allow members of this team to see this document"
- "Allow users who have been shared this item to view it"

ReBAC also supports algebraic operators: "if user has relationship X but NOT relationship Y with the object."

**Google Zanzibar** is the canonical large-scale ReBAC system (used for Google Docs sharing, YouTube, etc.). Open-source equivalents: Ory Keto, OpenFGA.

## Comparison with RBAC

| Dimension        | RBAC                        | ABAC                 | ReBAC                  |
| ---------------- | --------------------------- | -------------------- | ---------------------- |
| Access based on  | Assigned roles              | Attribute policies   | Resource relationships |
| Fine-grained?    | Low                         | High                 | High                   |
| Dynamic context? | No                          | Yes (env attributes) | Partial                |
| Multi-tenancy    | Poor                        | Good                 | Good                   |
| Setup complexity | Low                         | High                 | Medium                 |
| Scale            | Degrades ("role explosion") | Scales well          | Scales well (graph)    |
| Audit complexity | Grows with roles            | Policy-driven        | Relationship-driven    |

## Standards and Implementations

- **XACML v3.0** — OASIS standard for ABAC policy language and enforcement
- **NIST SP 800-162** — ABAC definition and guidance
- **NIST SP 800-205** — Attribute considerations for access control systems
- **Google Zanzibar** — canonical ReBAC; see zanzibar.academy
- **Cedar** — Amazon's policy language for ABAC (used in AWS Verified Permissions)
- **OPA (Open Policy Agent)** — general-purpose policy engine, commonly used for ABAC

## When to Use

Use ABAC when:

- Access depends on multiple attributes simultaneously (user type AND time AND location)
- Fine-grained control per-object is required
- Multi-tenancy needs to be handled cleanly
- Access rules change frequently and need centralized policy management

Use ReBAC when:

- Access is inherently tied to ownership/sharing relationships (e.g., file sharing, social features)
- You need to query "who can access this?" efficiently

## Related Pages

- [RBAC](rbac.md)
- [Authorization](authorization.md)
- [OWASP Authorization Cheat Sheet](../sources/owasp-authorization.md)
