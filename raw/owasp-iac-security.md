# Infrastructure as Code Security Cheatsheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Infrastructure_as_Code_Security_Cheat_Sheet.html

## Introduction

Infrastructure as code (IaC), also known as software-defined infrastructure, allows the configuration and deployment of infrastructure components faster with consistency by allowing them to be defined as code and also enables repeatable deployments across environments.

## Security Best Practices

### Develop and Distribute

- **IDE plugins**: TFLint, Checkov, Docker Linter, docker-vulnerability-extension, Security Scan, Contrast Security — early detection of potential risks
- **Threat modelling**: Build threat model early in development cycle; identify high-risk aspects and ensure security throughout
- **Managing secrets**: Avoid storing secrets in plain text files or SCMs. Use tools like truffleHog, git-secrets, GitGuardian to detect exposed secrets. See Secrets Management Cheat Sheet.
- **Version control**: Track all IaC changes with Git. Infrastructure requirements should be part of the feature branch/MR, not committed separately.
- **Principle of least privilege**:
  - Define who can create/update/run/delete scripts and inventory
  - Limit permissions of authorized IaC users to what is necessary
  - IaC scripts should grant only the permissions required for resources to perform their work
- **Static analysis**: Analyze code in isolation for risks, misconfigurations, and compliance faults. Tools: kubescan, Snyk, Coverity
- **Open source dependency check**: Analyze OS packages, libraries, etc. for potential risks. Tools: BlackDuck, Snyk, WhiteSource Bolt
- **Container image scan**: Analyze container image contents and build process for security issues. Tools: Dagda, Clair, Trivy, Anchore
- **CI/CD pipeline and consolidated reporting**: Enable security checks in CI/CD for each code change. Tools: Jenkins (pipelines), DefectDojo + OWASP Glue (consolidated dashboard)
- **Artifact signing**: Digitally sign artifacts at build time; validate before use. Protects against tampering between build and runtime. Tools: TUF

### Deploy

- **Inventory management**:
  - *Commissioning*: Label, track, and log each resource on deployment
  - *Decommissioning*: Erase configurations, securely delete data, remove from inventory completely
  - *Tagging*: Untagged cloud assets become ghost resources — hard to detect, can cause billing issues, reliability problems, and posture drift
- **Dynamic analysis**: Evaluate existing environments and interoperability risks. Tools: ZAP, Burp, GVM

### Runtime

- **Immutability of infrastructure**: Build infrastructure to exact specifications. No deviation, no changes. To change a spec, provision new infrastructure from updated requirements; retire old infrastructure.
- **Logging**: Enable security logs and audit logs during provisioning. Helps assess risks, analyze incident root cause, identify threats. Tools: ELK stack
- **Monitoring**: Continuous monitoring for security/compliance violations, attack identification, alerts. Tools: Prometheus, Grafana
- **Runtime threat detection**: Detect unexpected application behavior and alert on threats at runtime. Tools: Falco, Contrast (also blocks OWASP Top 10 attacks)

## References

- Securing Infrastructure as code: https://www.opcito.com/blogs/securing-infrastructure-as-code
- Infrastructure as code security: https://dzone.com/articles/infrastructure-as-code-security
- Shifting cloud security left with infrastructure as code: https://securityboulevard.com/2020/04/shifting-cloud-security-left-with-infrastructure-as-code/
