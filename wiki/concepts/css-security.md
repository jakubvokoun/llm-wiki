---
title: "CSS Security"
tags: [css, frontend, information-disclosure, access-control, obfuscation]
sources: [owasp-css-security.md]
updated: 2026-04-16
---

# CSS Security

## The Problem

CSS files are served publicly and viewable via browser dev tools or View Source — even to unauthenticated users. A single "global" stylesheet containing selectors for all user roles and features leaks:

- What roles exist (`.studentView`, `.adminPanel`, `.superUserControls`)
- What features each role has (`.deleteUsers`, `.exportData`, `.addNewAdmin`)
- Application structure and business logic hints

This enables **pre-authentication reconnaissance** before any login attempt.

## Defenses

### 1. Role-Isolated CSS Files

- Separate CSS file per access control level
- Enforce server-side access control on each CSS file
- Alert on forced-browsing attempts (student requesting admin CSS)

### 2. Selector Obfuscation

Tools that obscure class names at build time:

- **JSS** (`minify` option) → `.c001`, `.c002`
- **CSS Modules** (`localIdentName`) → hashed class names
- **.Net Blazor CSS Isolation** → `button.add[b-3xxtam6d07]`
- Using utility frameworks (Bootstrap, Tailwind) reduces need for custom semantic selectors
- Use structural selectors instead of named classes: `header button:first-of-type` instead of `.addUserButton`

### 3. Restrict User-Submitted Styles

When users can submit HTML/CSS content:

- Sanitize or strip style attributes
- Use CSP to restrict inline styles
- Prevent CSS-based clickjacking (LinkedIn example: user CSS caused full-page clickjack)

## Related Pages

- [Content Security Policy](content-security-policy.md)
- [Authorization](authorization.md)
- [RBAC](rbac.md)
- [OWASP CSS Security Cheat Sheet](../sources/owasp-css-security.md)
