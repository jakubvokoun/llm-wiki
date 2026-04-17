# Cloud Architecture Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Secure_Cloud_Architecture_Cheat_Sheet.html

## Introduction

Common and necessary security patterns for creating and reviewing cloud architectures. Written for medium to large enterprise systems.

## Risk Analysis, Threat Modeling, and Attack Surface Assessments

Before designing architecture, identify:
- What threats the application might face
- Likelihood of threats actualizing
- Attack surface
- Business impact of data/functionality loss

Key resources: Threat Modeling Cheat Sheet, Attack Surface Analysis Cheat Sheet, CISA Cyber Risk Assessment.

## Public and Private Components

### Secure Object Storage

Three access methods:
1. **IAM Access** — Indirect access via managed service with IAM credentials. Best for hiding storage, suitable for sensitive data. Risk: broad IAM policy, hardcoded credentials.
2. **Signed URLs** — Cryptographically signed URLs for direct file access. Best for non-sensitive user data direct downloads. Risk: anonymous access, injection if custom URL generation.
3. **Public Object Storage** — Not recommended except for public, non-sensitive generic resources. Any data stored this way must be assumed publicly accessed.

### VPCs and Subnets

- **VPCs**: Create network boundaries (like physical networks). Separate apps, components, or customer environments.
- **Public Subnets**: Internet-facing resources — load balancers, front-end web apps, bastion hosts.
- **Private Subnets**: Databases, backend servers, sensitive resources — no direct internet access.

Typical flow: Internet → API/Internet Gateway → Load Balancer (public subnet) → Backend/Database (private subnet).

## Trust Boundaries

Trust boundaries are connection points between components with potentially different trust levels.

### Trust Configurations

1. **No Trust**: Every component verifies every other. For highest-risk applications (financial, military, critical infrastructure). High assurance but slow, complex, expensive.
2. **Full Trust**: Everything trusted — dangerous except for simplest/lowest risk apps. Never trust user input.
3. **Some Trust** (most common): Risk-based approach — trust low-risk components, verify high-risk interactions. Balances security overhead with efficiency.

Note: "No Trust" approach relates to Zero Trust architecture — see CISA Zero Trust Maturity Model.

## Security Tooling

### Web Application Firewall (WAF)

- Attach to entry points (load balancers, API gateways) as first line of defense
- Use provider-managed rule sets (AWS Managed Rules, GCP WAF Rules, Azure Core Rule Sets)
- Add custom rules: route filtering, rate limiting, technology-specific protections

### Logging & Monitoring

Logging considerations:
- Log all L7 HTTP calls with headers, caller metadata, responses (exclude pre-TLS-termination payloads)
- Log internal actions with actor and permission info
- Use trace IDs throughout request lifecycle
- Mask/remove sensitive data (SSN, PII) from logs

Monitoring alerts for:
- HTTP 4xx/5xx error rates above baseline
- Memory/storage/CPU anomalies
- Database read/write rate anomalies
- Serverless invocation spikes
- Failed health checks, deployment errors
- Cost limit alerts

### DDoS Protection

- Basic: WAF rate limits and route blocking
- Advanced: AWS Shield, GCP Cloud Armor Managed Protection, Azure DDoS Protection

Decision based on risk, business criticality, and cost.

## Shared Responsibility Model

| Model | Developer Controls | CSP Controls | Notes |
|-------|-------------------|--------------|-------|
| IaaS | Auth, data, networking, app | Hardware, data center | Most control, highest cost/complexity |
| PaaS | App auth, app code, external data | OS, containers, some networking | Balanced; easier onboarding |
| SaaS | Configuration, admin, some integrations | Full stack | Lowest maintenance, least control |

### Self-managed Tooling

Automate minor version updates and AMI/image refreshes. Schedule dev cycle time for stale resource upgrades.

### Developer responsibilities even in managed services:
- Authentication and authorization
- Logging and monitoring
- Code security (OWASP Top 10)
- Third-party library patching

When evaluating SaaS vendors, ask for ISO 27001 attestation records.

## References

- Secure Product Design Cheat Sheet
- CISA Security Technical Reference Architecture
- CISA Zero Trust Maturity Model
