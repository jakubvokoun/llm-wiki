---
title: "OWASP Vulnerable Dependency Management Cheat Sheet"
tags: [owasp, dependencies, supply-chain, sca, cve, sbom]
sources: [owasp-vulnerable-dependency-management.md]
updated: 2026-04-16
---

# OWASP Vulnerable Dependency Management Cheat Sheet

Source: `raw/owasp-vulnerable-dependency-management.md`

## Overview

How to handle vulnerable third-party dependencies once detected. Covers four decision cases + tooling. Risk acceptance requires CRO/CISO sign-off based on CVSS score.

## Detection Note

- **Responsible disclosure** → CVE created → picked up by SCA tools
- **Full disclosure** (no CVE) → may not appear in SCA tool results; needs tools with multiple input sources

## Four Cases

### Case 1: Patch Available

1. Update version in test env
2. Run automated tests
3. If tests pass → ship to production
4. If fail: fix API breakage OR raise incompatibility with provider → fall to Case 2

### Case 2: Provider Fix Delayed (months away)

1. Apply provided workaround if available
2. Wrap vulnerable function calls with protective/validation code
3. WAF rules can add runtime protection
4. Add README comment referencing CVE (tool will keep alerting)
5. Add to ignore list scoped to specific CVE only (not whole dependency)

```java
// Example: RCE-vulnerable function wrapped with input validation
public void callFunctionWithRCEIssue(String externalInput){
    if(Pattern.matches("[a-zA-Z0-9]{1,50}", externalInput)){
        functionWithRCEIssue(externalInput);
    } else {
        SecurityLogger.warn("Exploitation of RCE issue XXXXX detected!");
        throw new SecurityException();
    }
}
```

### Case 3: Provider Won't Fix (no patch ever)

1. Find alternative dependency or fork + patch (OSS) + submit PR
2. Identify calls to dependency via IDE/dependency tool
3. Read CVE description to determine vulnerability type (SQLi, RCE, XXE, etc.)
4. Apply protective code as in Case 2
5. Write unit tests that verify the patch prevents exploitation

### Case 4: Vulnerability Discovered Externally (no CVE yet)

- From pentest or full disclosure post

1. Notify provider with full details
2. If provider cooperates → Case 2
3. If provider unresponsive → Case 3

## Transitive Dependencies

If vulnerable dep is transitive, act on the direct dependency. Understanding the full dependency chain is time-consuming but necessary before patching.

## Tooling

| Tool                   | Languages                                     | Type                               |
| ---------------------- | --------------------------------------------- | ---------------------------------- |
| OWASP Dependency Check | Java, .NET, Python, Ruby, PHP, Node, C/C++    | Free                               |
| npm audit              | Node.js / JS                                  | Free                               |
| OWASP Dependency Track | Organization-wide management                  | Free                               |
| ThreatMapper           | Java, Node, Ruby, Python + K8s/Docker/Fargate | Free                               |
| Snyk                   | Many languages                                | Commercial (free tier)             |
| JFrog XRay             | Many languages                                | Commercial                         |
| Renovate               | Many languages                                | Commercial (detects outdated deps) |

## Related Pages

- [Supply Chain Security](../concepts/supply-chain-security.md)
- [NPM Security](../concepts/npm-security.md)
- [Vulnerability Disclosure](../concepts/vulnerability-disclosure.md)
- [Dependency Confusion](../concepts/dependency-confusion.md)
