# Authorization Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html

## Introduction

Authorization may be defined as "the process of verifying that a requested action or service is approved for a specific entity" (NIST). Authorization is distinct from authentication which is the process of verifying an entity's identity.

Broken Access Control was ranked as the most concerning web security vulnerability in OWASP's 2021 Top 10 and asserted to have a "High" likelihood of exploit by MITRE's CWE program.

## Recommendations

### Enforce Least Privileges

Least Privileges refers to the principle of assigning users only the minimum privileges necessary to complete their job. Must be applied both horizontally and vertically.

* During the design phase, ensure trust boundaries are defined. Enumerate the types of users that will be accessing the system, the resources exposed and the operations that might be performed on those resources.
* Create tests that validate that the permissions mapped out in the design phase are being correctly enforced.
* After the app has been deployed, periodically review permissions in the system for "privilege creep".
* It is easier to grant users additional permissions rather than to take away some they previously enjoyed.

### Deny by Default

The application must always make a decision to either deny or permit the requested access. For security purposes an application should be configured to deny access by default.

* Adopt a "deny-by-default" mentality both during initial development and whenever new functionality or resources are exposed.
* Explicit configuration should be preferred over relying on framework or library defaults.

### Validate the Permissions on Every Request

Permission should be validated correctly on every request, regardless of whether the request was initiated by an AJAX script, server-side, or any other source. The technology used to perform such checks should allow for global, application-wide configuration rather than needing to be applied individually to every method or class.

Technologies that help with consistent permission checks:
* Java/Jakarta EE Filters including Spring Security
* Middleware in the Django Framework
* .NET Core Filters
* Middleware in the Laravel PHP Framework

### Thoroughly Review the Authorization Logic of Chosen Tools and Technologies

* Create, maintain, and follow processes for detecting and responding to vulnerable components.
* Incorporate tools such as Dependency Check into the SDLC.
* Implement defense in depth. Do not depend on any single framework, library, technology, or control.
* Do not let the capabilities of any library, platform, or framework guide your authorization requirements.
* Do not rely on default configurations.
* Test configuration.

### Prefer Attribute and Relationship Based Access Control over RBAC

Three basic forms of access control:
* **RBAC (Role-Based Access Control)** — access is granted or denied based upon the roles assigned to a user. Permissions are associated with a role and the entity inherits the permissions of any roles assigned to it.
* **ABAC (Attribute-Based Access Control)** — subject requests to perform operations on objects are granted or denied based on assigned attributes of the subject, assigned attributes of the object, environment conditions, and a set of policies.
* **ReBAC (Relationship-Based Access Control)** — grants access based on the relationships between resources (e.g., allowing only the user who created a post to edit it).

Advantages of ABAC/ReBAC over RBAC:
* **Fine-grained, complex Boolean logic** — ABAC can incorporate environmental and dynamic attributes (time of day, device type, geographic location).
* **Robustness** — In large projects, easy to miss or improperly perform role checks with RBAC.
* **Speed** — In RBAC, "role explosion" can occur when a system defines too many roles.
* **Supports Multi-Tenancy and Cross-Organizational Requests** — RBAC is poorly suited for distinct organizations needing access to the same protected resources.
* **Ease of Management** — ABAC and ReBAC are far more expressive and easier to update when access-control needs change.

### Ensure Lookup IDs are Not Accessible Even When Guessed or Cannot Be Tampered With

Applications often expose internal object identifiers (account number or Primary Key) used to locate and reference an object. This can lead to CWE 639: Authorization Bypass Through User-Controlled Key (IDOR).

Recommended mitigations:
* Avoid exposing identifiers to the user when possible.
* Implement user/session specific indirect references using a tool such as OWASP ESAPI.
* Perform access control checks on every request for the specific object or functionality being accessed.

### Enforce Authorization Checks on Static Resources

* Ensure that static resources are incorporated into access control policies.
* Ensure any cloud based services used to store static resources are secured using the configuration options and tools provided by the vendor.
* Protect static resources using the same access control logic and mechanisms as other application resources.

### Verify that Authorization Checks are Performed in the Right Location

Developers must never rely on client-side access control checks. Access control checks must be performed server-side, at the gateway, or using serverless function (see OWASP ASVS 4.0.3, V1.4.1 and V4.1.1).

### Exit Safely when Authorization Checks Fail

* Ensure all exception and failed access control checks are handled no matter how unlikely they seem.
* Centralize the logic for handling failed access control checks.
* Verify the handling of exception and authorization failures.
* Ensure sensitive information, such as system logs or debugging output, is not exposed in error messages.

### Implement Appropriate Logging

Insufficient logging and monitoring is recognized as among the most critical security risks in OWASP's Top Ten 2021. Recommendations:
* Log using consistent, well-defined formats that can be readily parsed for analysis.
* Carefully determine the amount of information to log (both too much and too little can be security weaknesses).
* Ensure clocks and timezones are synchronized across systems.
* Consider incorporating application logs into a centralized log server or SIEM.

### Create Unit and Integration Test Cases for Authorization Logic

* Unit and integration testing of access control logic can help reduce the number of security flaws that make it into production.
* Tests are good at catching "low-hanging fruit" of security issues.
* Tests should aim to incorporate: is access being denied by default? Does the application terminate safely when an access control check fails?

## References

* ABAC: NIST Special Publication 800-162
* General: OWASP Application Security Verification Standard 4.0
* Least Privilege: US-CERT BSI article
* RBAC: NIST Role-Based Access Controls
* ReBAC: Google Zanzibar
