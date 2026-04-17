---
title: "Secure by Default"
tags: [secure-by-default, security-design, configuration, defense-in-depth]
sources: [owasp-secure-product-design.md]
updated: 2026-04-16
---

# Secure by Default

Systems and software should ship and operate in the most secure configuration without requiring manual hardening steps from the operator.

## Core Principle

The default state is the secure state. Users and operators who don't customize configuration should still be protected. Insecure modes require explicit opt-in, not opt-out.

## Applied to Configuration

Per the Secure Product Design framework:

1. **Minimal permissions by default** — Least Privilege applies to initial install, not just after hardening
2. **Secure communications on** — HTTPS/TLS enabled out of the box, not as an option
3. **Fail securely** — When things go wrong, the system fails closed (denies access), not open
4. **Secrets not bundled** — No default passwords or hardcoded credentials; force user-provided secrets at setup
5. **Logging on** — Security-relevant events logged without requiring configuration
6. **Patching easy** — Update mechanisms included and default-on, not manual

## Fail Securely

A critical corollary: systems must be designed so failures result in a secure state.

- Exception handlers should deny access, not grant it
- Network failures should block traffic, not bypass controls
- Service crashes should not expose raw errors or credentials

## Contrast: Secure by Configuration

The opposite anti-pattern: ships open/insecure, relies on operators to harden. Problems:

- Operators forget steps
- Documentation lags actual hardening requirements
- Staging/dev environments remain insecure and get promoted

## Related Concepts

- [defense-in-depth](defense-in-depth.md)
- [iac-security](iac-security.md)
- [secrets-management](secrets-management.md)

## Sources

- [OWASP Secure Product Design Cheat Sheet](../sources/owasp-secure-product-design.md)
