---
title: "Serverless Security"
tags: [serverless, faas, aws-lambda, cloud, iam, cold-start, event-driven]
sources: [owasp-serverless-security.md]
updated: 2026-04-16
---

# Serverless Security

## What Makes Serverless Different

FaaS (Functions as a Service) — AWS Lambda, Azure Functions, GCP Cloud Functions — changes the security model:

- **Ephemeral execution:** Short-lived, may share underlying hardware with other tenants
- **Event-driven:** Any service can trigger a function; trust must be verified per event
- **Managed environment:** OS/runtime patching handled by provider; IAM is the primary control plane
- **Execution context persistence:** Container may be reused between invocations ("warm start")

## Key Threats

| Threat                  | Description                                                                       |
| ----------------------- | --------------------------------------------------------------------------------- |
| Over-permissioned IAM   | `"Action": "*", "Resource": "*"` allows lateral movement throughout cloud account |
| Unvalidated events      | Events from S3, API Gateway, SNS, IoT treated as trusted input                    |
| Cold start leakage      | Global variables, /tmp files persist across invocations                           |
| Function chaining abuse | Compromised function invokes privileged sibling functions                         |
| Secrets in env vars     | Exposed via logging, metadata APIs, or code disclosure                            |
| Excessive egress        | Default outbound internet enables C2 callbacks, data exfiltration                 |

## Mitigations

### IAM Least Privilege

- One IAM role per function, scoped to exact actions and resources needed
- Never use `*` in production function policies

### Cold Start Safety

- Treat execution context as potentially dirty
- Fetch secrets fresh each invocation from secrets manager, not global vars
- Clear /tmp between sensitive operations where possible

### Secrets Handling

- Use secrets manager extensions (not env vars) — AWS Lambda has a local extension at `localhost:2773`
- Use ephemeral credentials (STS AssumeRole, workload identity)
- Auto-rotate all secrets

### Network Isolation

- Deploy in VPC private subnets with restricted security groups
- Restrict outbound to only required destinations

### Event Validation

- All event payloads = untrusted user input
- Validate schema, types, lengths; sanitize before processing

## Related Pages

- [Secrets Management](secrets-management.md)
- [RBAC](rbac.md)
- [Zero Trust Architecture](zero-trust.md)
- [Input Validation](input-validation.md)
- [Security Logging](security-logging.md)
- [Cloud Architecture Security](cloud-architecture-security.md)
- [OWASP Serverless Security Cheat Sheet](../sources/owasp-serverless-security.md)
