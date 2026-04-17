---
title: "OWASP Serverless / FaaS Security Cheat Sheet"
tags: [owasp, serverless, faas, aws-lambda, cloud, iam, secrets]
sources: [owasp-serverless-security.md]
updated: 2026-04-16
---

# OWASP Serverless / FaaS Security Cheat Sheet

Source: `raw/owasp-serverless-security.md`

## Key Takeaways

FaaS (AWS Lambda, Azure Functions, GCP Cloud Functions) introduces unique risks: short-lived ephemeral execution, event-driven triggers, managed environment, and shared multi-tenant infrastructure.

## Key Risks

| Risk                     | Description                                             |
| ------------------------ | ------------------------------------------------------- |
| Over-permissioned IAM    | Broad `*` policies on functions                         |
| Unvalidated event inputs | API Gateway, S3, Pub/Sub, IoT events treated as trusted |
| Cold start data leakage  | Persistent global state between invocations; /tmp reuse |
| Function chaining abuse  | Compromised function invokes other functions            |
| Hardcoded secrets        | In code or environment variables                        |
| Excessive network access | Default outbound internet enabled                       |

## 8 Best Practices

### 1. Principle of Least Privilege

- Role-per-function, not shared high-privilege roles
- Scope IAM to specific actions + specific resources (not `*`)

### 2. Environment Isolation

- Functions in private subnets with restricted egress
- Separate prod/staging with strict boundaries
- Isolate sensitive functions (auth, payment)

### 3. Secure Function Invocation

- Auth/authz on all triggers (API Gateway, S3, Pub/Sub)
- Validate function-to-function calls with signed tokens or workload identities
- Rate limiting and throttling

### 4. Event Data Validation

- All event payloads = untrusted input
- Validate type, length, format; strip unnecessary fields
- Protect against SQLi, XSS, JSON injection, deserialization attacks

### 5. Cold Start & Execution Context Security

- Don't assume clean runtime between invocations
- Avoid secrets or sensitive data in global/static variables
- Clear /tmp data; protect against timing side-channels

### 6. Secrets Management

- Never store secrets in environment variables
- Use secrets manager extensions (AWS Lambda Parameters and Secrets Extension at `localhost:2773`)
- Use ephemeral credentials (STS, workload identity federation)
- Auto-rotate secrets

### 7. Monitoring & Logging

- Centralized logging (CloudWatch, Azure Monitor, GCP Logging)
- Redact secrets and PII from logs

### 8. Supply Chain Security

- Scan dependencies (`npm audit`, `pip-audit`, `safety`)
- Minimal deployment packages
- Checksum-verified layers

## Related Pages

- [Serverless Security](../concepts/serverless-security.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
- [Input Validation](../concepts/input-validation.md)
- [RBAC](../concepts/rbac.md)
- [Security Logging](../concepts/security-logging.md)
