# CI/CD Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html

## Introduction

CI/CD pipelines are an appealing target for attackers due to their importance and the high-privileged identities they use. The OWASP Top 10 CI/CD Security Risks:

- CICD-SEC-1: Insufficient Flow Control Mechanisms
- CICD-SEC-2: Inadequate Identity and Access Management
- CICD-SEC-3: Dependency Chain Abuse
- CICD-SEC-4: Poisoned Pipeline Execution (PPE)
- CICD-SEC-5: Insufficient PBAC (Pipeline-Based Access Controls)
- CICD-SEC-6: Insufficient Credential Hygiene
- CICD-SEC-7: Insecure System Configuration
- CICD-SEC-8: Ungoverned Usage of Third-Party Services
- CICD-SEC-9: Improper Artifact Integrity Validation
- CICD-SEC-10: Insufficient Logging and Visibility

## Secure Configuration

### Secure SCM Configuration

- Avoid auto-merge rules
- Require pull request reviews before merging
- Use protected branches
- Require signed commits
- Enable MFA
- Avoid default permissions; manage carefully
- Restrict forking private repositories
- Tools like Legitify can scan SCM assets for misconfigurations

### Pipeline and Execution Environment

- Perform builds in isolated nodes
- Secure SCM-to-CI communication with TLS 1.2+
- Restrict CI/CD access by IP
- Store CI config outside the code repo where possible
- Enable appropriate logging
- Use SAST, DAST, IaC scanning in pipeline
- Require manual approval before production deployment
- Avoid `--privileged` flag in Docker pipeline steps
- Enforce MFA

## IAM

### Secrets Management

- Never hardcode secrets in repositories or CI config files
- Use tools like git-leaks or git-secrets to detect secrets
- Encrypt secrets at rest and in transit
- Never print secrets to console or logs
- Use secrets managers: HashiCorp Vault, AWS Secrets Manager, AKeyless, CyberArk
- Use temporary credentials / OTPs where possible

### Least Privilege

- Apply deny-by-default; justify all access
- Limit pipeline identities to minimum required permissions
- Minimize credential sharing across pipelines
- OS accounts running pipeline should not be root

### Identity Lifecycle Management

- Use centralized IdP; disallow local accounts
- Disallow shared accounts and self-provisioning
- Maintain accurate inventory of identities (owner, IdP, last used, permissions)
- Deprovision identities promptly when no longer needed

## Managing Third-Party Code

### Dependency Management

- Pin package versions using lock files (package-lock.json, Pipfile.lock)
- Verify integrity with hashes/checksums
- Enforce lockfiles in CI
- Prefer private package registries
- Use scoped npm packages / NuGet ID prefixes to prevent dependency confusion
- Commit configuration files (.npmrc) to source control

### Plug-In and Integration Management

- Vet plugins before installation
- Restrict who can install plugins (least privilege)
- Keep plugins up-to-date with security patches
- Remove unused plugins

## Integrity Assurance

- Require signed commits in SCM
- Use hash verification for packages
- Use code signing tools: Sigstore, Signserver
- Consider the in-toto framework for end-to-end supply chain integrity

## Visibility and Monitoring

- Configure logging per organizational policy
- Log in parsable formats (JSON, syslog)
- Avoid logging sensitive data (passwords, tokens, API keys)
- Send logs to centralized log management or SIEM
- Configure SIEM alerts for anomalies and potential attacks

## References

- OWASP Top 10 CI/CD Security Risks: https://owasp.org/www-project-top-10-ci-cd-security-risks/
- CISA Securing the Software Supply Chain: https://www.cisa.gov/sites/default/files/publications/ESF_SECURING_THE_SOFTWARE_SUPPLY_CHAIN_DEVELOPERS.PDF
- HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, CyberArk
- Integrity tools: In-toto, SigStore, SLSA
