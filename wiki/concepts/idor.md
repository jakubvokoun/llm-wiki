---
title: "IDOR (Insecure Direct Object Reference)"
tags: [idor, authorization, access-control, broken-access-control, cwe-639]
sources: [owasp-authorization.md]
updated: 2026-04-16
---

# IDOR (Insecure Direct Object Reference)

Insecure Direct Object Reference (IDOR) is an authorization vulnerability where an application exposes internal object identifiers (database IDs, filenames, account numbers) and fails to verify that the requesting user is authorized to access that specific object. It is a subtype of Broken Access Control (OWASP A01:2021, CWE-639).

## Example

```
GET /accountTransactions?acct_id=901
```

If the user changes `901` to `523`, can they see another user's transactions? If yes, the application is vulnerable to IDOR.

## Impact

- **Horizontal privilege escalation**: access another user's data at the same privilege level
- **Vertical privilege escalation** (less common): access data reserved for higher-privilege roles
- Confidentiality, integrity, and availability of resources can all be affected

## Root Cause

The object ID is exposed to the user (via URL param, path variable, hidden form field, API response) and the application:

1. Does not perform an authorization check before serving the object, OR
2. Checks only "is this a valid ID?" not "does this user own/have permission to access this ID?"

## Mitigations

### 1. Avoid Exposing IDs When Possible

Derive object identity from the session or JWT claims instead of accepting it as user input:

```
GET /accountTransactions  # server derives account from authenticated user's session
```

### 2. Use Indirect References

Map user-visible references to internal IDs server-side, scoped to the user's session. If a user sends reference "3", the server maps it to their third resource, not database ID 3.

OWASP ESAPI provides utilities for this pattern.

### 3. Access Check on Every Object Request

Even if a user is authenticated and can generally access objects of a type, verify they can access the _specific_ object being requested:

```python
# WRONG: only checks authentication
if user.is_authenticated:
    return get_account(acct_id)

# RIGHT: checks authorization for the specific object
if user.is_authenticated and user.owns_account(acct_id):
    return get_account(acct_id)
```

### 4. Use Non-Guessable IDs (Defense-in-Depth)

Use UUIDs instead of sequential integers for exposed identifiers. This makes enumeration harder but does **not** substitute for access control checks — security through obscurity is insufficient on its own.

## Testing

- Manually swap IDs in requests across two different test accounts
- Automated scanners (Burp Suite, OWASP ZAP) can detect some IDOR patterns
- OWASP Web Security Testing Guide (WSTG) 4.5 authorization testing

## Related Pages

- [Authorization](authorization.md)
- [RBAC](rbac.md)
- [Input Validation](input-validation.md)
- [OWASP Authorization Cheat Sheet](../sources/owasp-authorization.md)
