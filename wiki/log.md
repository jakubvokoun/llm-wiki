# Wiki Log

Append-only record of ingests, queries, and lint passes.

Parse with: `grep "^## \[" wiki/log.md | tail -10`

---

## [2026-04-15]

- **init:** Wiki bootstrapped. Schema in CLAUDE.md.
- **queue (7):** owasp-docker-security, owasp-iac-security, owasp-cicd-security, owasp-secure-cloud-architecture, owasp-kubernetes-security, owasp-microservices-security, owasp-ai-agent-security
- **concepts:** container-security, iac-security, supply-chain-security, immutable-infrastructure, secrets-management, cicd-security, cloud-architecture-security, shared-responsibility-model, web-application-firewall, trust-boundaries, kubernetes-security, rbac, network-policy, pod-security, admission-controllers, service-mesh, microservices-security, zero-trust, ai-agent-security, prompt-injection, human-in-the-loop, multi-agent-systems, denial-of-wallet
- **entities:** owasp, docker, podman, kubernetes

## [2026-04-16]

- **ingest (6):** owasp-input-validation, owasp-mcp-security, owasp-secure-product-design, owasp-html5-security, k8s-best-practices-readme, k8s-best-practices-container
- **queue (38):** owasp-authentication, owasp-authorization, owasp-logging, owasp-content-security-policy, owasp-dom-xss, owasp-database-security, owasp-http-headers, owasp-hsts, owasp-php-configuration, owasp-rest-assessment, owasp-rest-security, owasp-secure-code-review, owasp-key-management, owasp-npm-security, owasp-nodejs-docker, owasp-nodejs-security, owasp-security-terminology, owasp-css-security, owasp-serverless-security, owasp-session-management, owasp-tls-security, owasp-vulnerability-disclosure, owasp-vulnerable-dependency-management, owasp-websocket-security, owasp-web-service-security, owasp-xxe-prevention, owasp-xml-security, owasp-xss-filter-evasion, owasp-zero-trust, owasp-grpc-security, k8s-best-practices-readme, k8s-best-practices-container, docker-build-best-practices, linux-capabilities-archwiki, linux-capabilities-juggernaut, linux-capabilities-man7, linux-setcap-man7, linux-getcap-man7
- **concepts:** input-validation, file-upload-security, mcp-security, tool-poisoning, defense-in-depth, secure-by-default, tabnabbing, browser-storage-security, gitops, kubernetes-observability, authentication, password-security, mfa, adaptive-authentication, authorization, abac, idor, security-logging, content-security-policy, dom-xss, database-security, http-security-headers, hsts, php-security, rest-api-security, secure-code-review, key-management, perfect-forward-secrecy, npm-security, dependency-confusion, nodejs-security, redos, encoding-and-escaping, cryptographic-primitives, federated-identity, css-security, serverless-security, session-management, tls, certificate-management, vulnerability-disclosure, websocket-security, xxe, xml-security, linux-capabilities, apparmor-profiles, mandatory-access-control, seccomp
- **entities:** anthropic, apparmor
- **updated:** rbac, supply-chain-security, container-security, secrets-management, zero-trust, kubernetes, dom-xss, prompt-injection, pod-security

## [2026-04-17]

- **ingest (5):** awesome-atomic, ostree-introduction, ostree-repo, ostree-deployment, ostree-atomic-upgrades
- **queue (11):** ostree-atomic-rollbacks, ostree-var, ostree-formats, ostree-buildsystem-and-repos, ostree-authenticated-repos, ostree-repository-management, ostree-copying-deltas, ostree-composefs, ostree-ima, ostree-related-projects, ostree-bootloaders
- **concepts:** atomic-linux
- **entities:** ostree, fedora, flatpak, distrobox
- **updated:** immutable-infrastructure, ostree, atomic-linux, ostree-formats
