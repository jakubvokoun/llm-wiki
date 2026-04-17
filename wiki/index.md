# Wiki Index

## Sources

| Page                                                                                                    | Summary                                                                                                                            | Date       |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| [OWASP Docker Security Cheat Sheet](sources/owasp-docker-security.md)                                   | 13 rules for hardening Docker containers: least privilege, rootless mode, supply chain                                             | 2026-04-15 |
| [OWASP IaC Security Cheat Sheet](sources/owasp-iac-security.md)                                         | IaC security across Develop/Deploy/Runtime phases: shift-left, immutability, secret detection                                      | 2026-04-15 |
| [OWASP CI/CD Security Cheat Sheet](sources/owasp-cicd-security.md)                                      | OWASP Top 10 CI/CD risks: SCM hardening, secrets, dependency chain abuse, pipeline integrity                                       | 2026-04-15 |
| [OWASP Secure Cloud Architecture Cheat Sheet](sources/owasp-secure-cloud-architecture.md)               | VPC/subnet design, trust boundaries, WAF, shared responsibility model                                                              | 2026-04-15 |
| [OWASP Kubernetes Security Cheat Sheet](sources/owasp-kubernetes-security.md)                           | Full K8s lifecycle security: control plane, RBAC, pod security, network policies, runtime                                          | 2026-04-15 |
| [OWASP Microservices Security Cheat Sheet](sources/owasp-microservices-security.md)                     | Auth patterns for microservices: embedded PDP, signed identity propagation, mTLS, logging                                          | 2026-04-15 |
| [OWASP AI Agent Security Cheat Sheet](sources/owasp-ai-agent-security.md)                               | AI agent security: tool least privilege, prompt injection, HITL, multi-agent trust, DoW                                            | 2026-04-15 |
| [OWASP MCP Security Cheat Sheet](sources/owasp-mcp-security.md)                                         | MCP attack surface: tool poisoning, rug pulls, tool shadowing, message signing, confused deputy                                    | 2026-04-16 |
| [OWASP Input Validation Cheat Sheet](sources/owasp-input-validation.md)                                 | Allowlist vs denylist, syntactic/semantic validation, file upload security, email validation                                       | 2026-04-16 |
| [OWASP Authentication Cheat Sheet](sources/owasp-authentication.md)                                     | Password strength, error messages, MFA, OAuth/OIDC/SAML/FIDO2, adaptive authentication                                             | 2026-04-16 |
| [OWASP Authorization Cheat Sheet](sources/owasp-authorization.md)                                       | Least privilege, deny-by-default, ABAC/ReBAC vs RBAC, IDOR prevention, server-side enforcement                                     | 2026-04-16 |
| [OWASP Logging Cheat Sheet](sources/owasp-logging.md)                                                   | Security event logging: what to log, event attributes, log injection prevention, SIEM architecture                                 | 2026-04-16 |
| [OWASP Content Security Policy Cheat Sheet](sources/owasp-content-security-policy.md)                   | CSP strict policy (nonce/hash), XSS defense, clickjacking prevention, frame-ancestors                                              | 2026-04-16 |
| [OWASP DOM based XSS Prevention Cheat Sheet](sources/owasp-dom-xss.md)                                  | Client-side XSS via dangerous sinks; context-aware encoding rules; safe sinks; DOMPurify                                           | 2026-04-16 |
| [OWASP Database Security Cheat Sheet](sources/owasp-database-security.md)                               | DB isolation, TLS, least privilege, credential storage, hardening for MSSQL/MySQL/PostgreSQL                                       | 2026-04-16 |
| [OWASP HTTP Security Response Headers Cheat Sheet](sources/owasp-http-headers.md)                       | 20+ security headers: CSP, HSTS, COOP/COEP/CORP, Permissions-Policy, deprecations                                                  | 2026-04-16 |
| [OWASP HTTP Strict Transport Security Cheat Sheet](sources/owasp-hsts.md)                               | HSTS: max-age, includeSubDomains, preload list, risks, HSTS super-cookie                                                           | 2026-04-16 |
| [OWASP Key Management Cheat Sheet](sources/owasp-key-management.md)                                     | Key lifecycle: FIPS 140-2/3, HSM storage, KEK wrapping, audit, compromise recovery, PFS                                            | 2026-04-16 |
| [OWASP NPM Security Cheat Sheet](sources/owasp-npm-security.md)                                         | 12 npm best practices: lockfile, run-scripts, typosquatting, slopsquatting, trusted publishing, dependency confusion               | 2026-04-16 |
| [OWASP Node.js Docker Cheat Sheet](sources/owasp-nodejs-docker.md)                                      | Node.js Docker: pinned alpine image, dumb-init, non-root, multi-stage builds, build secrets                                        | 2026-04-16 |
| [OWASP Node.js Security Cheat Sheet](sources/owasp-nodejs-security.md)                                  | Node.js security: event loop, HPP, brute-force, helmet, ReDoS, Permission Model, dangerous functions                               | 2026-04-16 |
| [OWASP PHP Configuration Cheat Sheet](sources/owasp-php-configuration.md)                               | Secure php.ini: expose_php, disable_functions, session hardening, Snuffleupagus                                                    | 2026-04-16 |
| [OWASP REST Assessment Cheat Sheet](sources/owasp-rest-assessment.md)                                   | REST pentest: hidden attack surface discovery, proxy collection, parameter identification, fuzzing                                 | 2026-04-16 |
| [OWASP REST Security Cheat Sheet](sources/owasp-rest-security.md)                                       | REST API security: HTTPS, JWT (alg confusion), API keys, method allowlist, out-of-order prevention, CORS                           | 2026-04-16 |
| [OWASP Secure Code Review Cheat Sheet](sources/owasp-secure-code-review.md)                             | Manual code review: baseline vs diff, data flow analysis, vulnerability patterns, 7 checklists, SAST integration                   | 2026-04-16 |
| [OWASP Secure Product Design Cheat Sheet](sources/owasp-secure-product-design.md)                       | 4 security principles + 5 Cs framework (Context/Components/Connections/Code/Configuration) for product security                    | 2026-04-16 |
| [OWASP HTML5 Security Cheat Sheet](sources/owasp-html5-security.md)                                     | postMessage, CORS, localStorage, Web Workers, tabnabbing, sandboxed iframes, PII input protection                                  | 2026-04-16 |
| [OWASP Security Terminology Cheat Sheet](sources/owasp-security-terminology.md)                         | Precise definitions: encoding/escaping/sanitization, encryption/hashing/signatures, AuthN vs AuthZ, federated identity             | 2026-04-16 |
| [OWASP CSS Security Cheat Sheet](sources/owasp-css-security.md)                                         | CSS info disclosure: global stylesheets reveal roles/features; role-isolated files, selector obfuscation                           | 2026-04-16 |
| [OWASP Serverless / FaaS Security Cheat Sheet](sources/owasp-serverless-security.md)                    | FaaS security: IAM least privilege, event validation, cold start safety, secrets from vault not env vars                           | 2026-04-16 |
| [OWASP Session Management Cheat Sheet](sources/owasp-session-management.md)                             | Session IDs: 64-bit entropy, cookie attributes, session fixation, expiration, storage alternatives, attack detection               | 2026-04-16 |
| [OWASP Transport Layer Security Cheat Sheet](sources/owasp-tls-security.md)                             | TLS 1.3 best practices: cipher suites, DH groups, certificate types, mTLS, HSTS integration                                        | 2026-04-16 |
| [OWASP Vulnerability Disclosure Cheat Sheet](sources/owasp-vulnerability-disclosure.md)                 | Disclosure models (private/full/responsible), researcher legal checklist, bug bounty, CVE advisories                               | 2026-04-16 |
| [OWASP Vulnerable Dependency Management Cheat Sheet](sources/owasp-vulnerable-dependency-management.md) | 4-case response process for vulnerable deps: patch/delay/won't-fix/external; SCA tooling guide                                     | 2026-04-16 |
| [OWASP WebSocket Security Cheat Sheet](sources/owasp-websocket-security.md)                             | CSWSH attack and defenses, origin allowlist, per-message authz, DoS limits, WS logging gaps                                        | 2026-04-16 |
| [OWASP Web Service Security Cheat Sheet](sources/owasp-web-service-security.md)                         | SOAP/XML service security: mTLS, XML digital signatures, XXE/XML Bomb protection, resource limits                                  | 2026-04-16 |
| [OWASP XML External Entity Prevention Cheat Sheet](sources/owasp-xxe-prevention.md)                     | XXE via DTD entities: disable DTDs entirely; per-language guidance for Java, .NET, PHP, Python, C++                                | 2026-04-16 |
| [OWASP XML Security Cheat Sheet](sources/owasp-xml-security.md)                                         | XML attack surface: malformed docs, schema injection, entity expansion (Billion Laughs), SSRF via XXE                              | 2026-04-16 |
| [OWASP XSS Filter Evasion Cheat Sheet](sources/owasp-xss-filter-evasion.md)                             | XSS evasion techniques proving filter-based defense fails; encoding tricks, WAF bypass, event handlers                             | 2026-04-16 |
| [OWASP Zero Trust Architecture Cheat Sheet](sources/owasp-zero-trust.md)                                | NIST SP 800-207 principles, Policy Engine/Admin/Enforcement model, PaC+verification+telemetry loop                                 | 2026-04-16 |
| [OWASP gRPC Security Cheat Sheet](sources/owasp-grpc-security.md)                                       | gRPC-specific security: mTLS, interceptor auth/authz, message size limits, reflection disable in prod                              | 2026-04-16 |
| [Kubernetes Best Practices 101](sources/k8s-best-practices-readme.md)                                   | Full K8s production checklist: cluster, RBAC, probes, HPA, PDB, graceful shutdown, secrets, observability, GitOps                  | 2026-04-16 |
| [Kubernetes Best Practices — Container Guide](sources/k8s-best-practices-container.md)                  | Container deep-dive: base image selection (scratch/distroless), Dockerfile patterns, PID 1/tini, graceful shutdown, Cosign signing | 2026-04-16 |
| [Docker Build Best Practices (Official)](sources/docker-build-best-practices.md)                        | Official Docker guidance: multi-stage, base image pinning, ENV layer security, ENTRYPOINT/exec, Docker Scout automation            | 2026-04-16 |
| [Linux capabilities(7) Man Page](sources/linux-capabilities-man7.md)                                    | Definitive kernel reference: ~40 capability units, 5 thread sets, file caps, execve transformation, securebits, namespaced caps    | 2026-04-16 |
| [Linux Capabilities — Arch Wiki](sources/linux-capabilities-archwiki.md)                                | Practical admin guide: xattr implementation, setcap/getcap usage, capsh temporary caps, systemd integration                        | 2026-04-16 |
| [Linux Capabilities — Privilege Escalation](sources/linux-capabilities-juggernaut.md)                   | Pentest guide: enumerating and exploiting misconfigured binary capabilities; 6 dangerous caps with worked examples                 | 2026-04-16 |
| [setcap(8) Man Page](sources/linux-setcap-man7.md)                                                      | setcap tool reference: set/verify/remove file capabilities; capability string syntax; remove vs empty cap distinction              | 2026-04-16 |
| [getcap(8) Man Page](sources/linux-getcap-man7.md)                                                      | getcap tool reference: examine file capabilities, recursive search, namespace root UID display                                     | 2026-04-16 |
| [Linux AppArmor — Arch Wiki](sources/apparmor-archwiki.md)                                              | AppArmor installation, profile management, profile authoring, complain/enforce modes, troubleshooting                              | 2026-04-16 |
| [AppArmor Security Profiles for Docker](sources/docker-apparmor.md)                                     | docker-default profile, custom profiles, Nginx example, dmesg/aa-status debugging                                                  | 2026-04-16 |
| [AppArmor Core Policy Reference (Draft)](sources/apparmor-core-policy-reference.md)                     | Profile language reference: globbing syntax, access modes, deny rules, variables, v2 vs v3 language versions                       | 2026-04-16 |
| [Seccomp Security Profiles for Docker](sources/docker-seccomp.md)                                       | Docker seccomp allowlist; 44 blocked syscalls with rationale; relationship to capabilities and AppArmor                            | 2026-04-16 |
| [Awesome Atomic](sources/awesome-atomic.md)                                                             | Curated resource list: atomic/immutable Linux distros, OSTree, Flatpak, Distrobox, Universal Blue ecosystem                        | 2026-04-17 |
| [OSTree Introduction](sources/ostree-introduction.md)                                                   | OSTree = git for OS binaries; content-addressed trees; /etc 3-way merge; hardlink dedup; vs package managers                       | 2026-04-17 |
| [Anatomy of an OSTree Repository](sources/ostree-repo.md)                                               | Object model: commit/dirtree/dirmeta/content; no timestamps; 5 repo modes; refs; GPG-signed summary file                           | 2026-04-17 |
| [OSTree Deployments](sources/ostree-deployment.md)                                                      | Deployment path/stateroot/var sharing; 3-way /etc merge; staged deployments; BLS bootloader integration                            | 2026-04-17 |
| [OSTree Atomic Upgrades](sources/ostree-atomic-upgrades.md)                                             | Power-cut safe upgrades; delta HTTP pull; symlink-swap boot atomicity; kernel dedup; /etc merge semantics                          | 2026-04-17 |
| [OSTree Atomic Rollbacks](sources/ostree-atomic-rollbacks.md)                                           | Bootloader dual-entry rollback; greenboot auto-rollback; alternate systemd rescue.target technique                                 | 2026-04-17 |
| [OSTree /var Handling](sources/ostree-var.md)                                                           | /var as shared mutable state; one-time-copy semantics; drift pitfalls; /opt solutions via composefs/transient                      | 2026-04-17 |
| [OSTree Data Formats](sources/ostree-formats.md)                                                        | archive/bare/bare-user/bare-split-xattrs repo formats; static deltas; bsdiff per-file diffs; fallback objects                      | 2026-04-17 |
| [OSTree Buildsystem and Repository Management](sources/ostree-buildsystem-and-repos.md)                 | Two-repo build pattern (bare-user + archive); union checkout; rofiles-fuse; pull-local; static delta generation                    | 2026-04-17 |
| [OSTree Authenticated Remote Repositories](sources/ostree-authenticated-repos.md)                       | mTLS per-device certs, basic auth, cookie-based CDN auth (CloudFront signed cookies); generic HTTP model                           | 2026-04-17 |
| [OSTree Repository Management](sources/ostree-repository-management.md)                                 | Dev/prod repo split, branch promotion pipeline, cross-repo pull-local, static deltas, pruning, scratch deltas                      | 2026-04-17 |
| [OSTree Static Deltas for Offline Updates](sources/ostree-copying-deltas.md)                            | Self-contained delta files for air-gap/USB transfer; apply-offline command; --min-fallback-size=0                                  | 2026-04-17 |
| [Using composefs with OSTree](sources/ostree-composefs.md)                                              | Experimental FS integrity via fsverity; unsigned/verity/signed modes; transient key pattern; composefs vs IMA                      | 2026-04-17 |
| [Using Linux IMA with OSTree](sources/ostree-ima.md)                                                    | Per-file signing via security.ima xattr; ostree-ext-cli ima-sign; disk duplication caveat; EVM portability issues                  | 2026-04-17 |
| [OSTree Related Projects](sources/ostree-related-projects.md)                                           | OSTree vs BTRFS/rpm, ChromiumOS, casync, NixOS, Docker; two-camp taxonomy; rpm-ostree hybrid model                                 | 2026-04-17 |
| [OSTree Bootloader Integration](sources/ostree-bootloaders.md)                                          | BLS entries + GRUB blscfg happy path; legacy ostree-grub2 fallback; aboot A/B slots; bootupd static config                         | 2026-04-17 |

## Entities

| Page                                 | Type    | Summary                                                                                   |
| ------------------------------------ | ------- | ----------------------------------------------------------------------------------------- |
| [AppArmor](entities/apparmor.md)     | product | Linux MAC security module; path-based profiles; default on Ubuntu; Docker docker-default  |
| [OSTree](entities/ostree.md)         | product | Content-addressed OS tree versioning; foundational layer for Fedora Atomic and others     |
| [Fedora](entities/fedora.md)         | product | Fedora Atomic family: Silverblue, Kinoite, CoreOS; Universal Blue derivative images       |
| [Flatpak](entities/flatpak.md)       | product | Sandboxed Linux app packaging; canonical delivery for immutable/atomic desktop distros    |
| [Distrobox](entities/distrobox.md)   | product | Mutable container environments on immutable hosts; wraps Podman/Docker transparently      |
| [OWASP](entities/owasp.md)           | org     | Open source security foundation; Cheat Sheet Series, Top 10, Docker Top 10                |
| [Docker](entities/docker.md)         | product | Leading container runtime; daemon-based, many hardening options available                 |
| [Podman](entities/podman.md)         | product | Rootless, daemonless Docker alternative by Red Hat with SELinux integration               |
| [Kubernetes](entities/kubernetes.md) | product | Container orchestration platform; RBAC, network policies, pod security, admission control |
| [Anthropic](entities/anthropic.md)   | org     | AI safety company; creator of Claude models and Model Context Protocol (MCP)              |

## Concepts

| Page                                                                   | Summary                                                                                                        |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [Container Security](concepts/container-security.md)                   | Hardening containers: least privilege, isolation, image scanning, K8s security context                         |
| [IaC Security](concepts/iac-security.md)                               | Shift-left security across IaC SDLC: IDE plugins, CI/CD scanning, tagging, runtime detection                   |
| [Supply Chain Security](concepts/supply-chain-security.md)             | SBOM, image signing, SLSA provenance, trusted registry, deployment-time verification                           |
| [Immutable Infrastructure](concepts/immutable-infrastructure.md)       | Replace don't patch; eliminates drift, improves audit clarity, forces declarative security                     |
| [Secrets Management](concepts/secrets-management.md)                   | Secure storage and distribution of credentials; Docker Secrets, detection tools, IaC patterns                  |
| [CI/CD Security](concepts/cicd-security.md)                            | OWASP Top 10 CI/CD risks; SCM hardening, dependency chain abuse, poisoned pipeline execution                   |
| [Cloud Architecture Security](concepts/cloud-architecture-security.md) | VPC/subnet patterns, object storage access, trust boundaries, WAF, monitoring                                  |
| [Shared Responsibility Model](concepts/shared-responsibility-model.md) | IaaS/PaaS/SaaS security responsibility split between CSP and customer                                          |
| [Web Application Firewall](concepts/web-application-firewall.md)       | WAF: traffic filtering at entry points; provider rulesets + custom rules; DDoS mitigation                      |
| [Trust Boundaries](concepts/trust-boundaries.md)                       | Architectural points where trust decisions must be made; no-trust vs. risk-based models                        |
| [Kubernetes Security](concepts/kubernetes-security.md)                 | Multi-layered K8s security: control plane, RBAC, pod security, network policies, runtime                       |
| [RBAC](concepts/rbac.md)                                               | Role-based access control: least privilege via roles+bindings; applies to K8s, cloud IAM, APIs                 |
| [Network Policy](concepts/network-policy.md)                           | K8s NetworkPolicy: deny-all default + explicit whitelist; L3/L4 traffic control                                |
| [Pod Security](concepts/pod-security.md)                               | K8s pod security contexts and Pod Security Standards (Privileged/Baseline/Restricted)                          |
| [Admission Controllers](concepts/admission-controllers.md)             | K8s admission control: built-in controllers + OPA/Gatekeeper for policy-as-code                                |
| [Service Mesh](concepts/service-mesh.md)                               | Sidecar-based infrastructure: automatic mTLS, L7 policy, observability (Istio, Linkerd)                        |
| [Microservices Security](concepts/microservices-security.md)           | Authorization patterns (embedded PDP), identity propagation, mTLS, distributed logging                         |
| [Zero Trust Architecture](concepts/zero-trust.md)                      | Never trust, always verify; cryptographic identity; no implicit network-based trust                            |
| [AI Agent Security](concepts/ai-agent-security.md)                     | LLM agent threats: tool abuse, prompt injection, memory poisoning, multi-agent cascades                        |
| [Prompt Injection](concepts/prompt-injection.md)                       | Direct/indirect injection attacks against LLMs and agents; mitigations and delimiters                          |
| [Human-in-the-Loop](concepts/human-in-the-loop.md)                     | Risk-tiered human approval for agent actions; prevents autonomous high-impact mistakes                         |
| [Multi-Agent Systems Security](concepts/multi-agent-systems.md)        | Trust tiers, message signing, circuit breakers for multi-agent AI pipelines                                    |
| [Denial of Wallet](concepts/denial-of-wallet.md)                       | AI attack that causes excessive API costs via unbounded loops; cost limits and rate limiting                   |
| [MCP Security](concepts/mcp-security.md)                               | Protocol-level AI security: tool poisoning, rug pulls, shadowing, message signing, confused deputy             |
| [Tool Poisoning](concepts/tool-poisoning.md)                           | Malicious content in MCP tool definitions/schemas/responses that hijacks LLM behavior; includes rug pull       |
| [Input Validation](concepts/input-validation.md)                       | Allowlist-first defense layer; syntactic+semantic levels; Unicode normalization; client-side is UX only        |
| [File Upload Security](concepts/file-upload-security.md)               | Secure file uploads: allowlist extensions, random rename, malware scan, image rewriting                        |
| [Authentication](concepts/authentication.md)                           | AuthN concepts: password strength, MFA, OIDC/SAML/FIDO2, re-auth, adaptive auth, error messages                |
| [Password Security](concepts/password-security.md)                     | NIST password rules, secure hashing (Argon2/bcrypt), constant-time comparison, breached password detection     |
| [Multi-Factor Authentication](concepts/mfa.md)                         | TOTP, U2F, FIDO2/Passkeys, push notifications; factor categories; phishing resistance                          |
| [Adaptive Authentication](concepts/adaptive-authentication.md)         | Risk-based auth: geolocation, device, behavioral signals; step-up; continuous session risk assessment          |
| [Authorization](concepts/authorization.md)                             | AuthZ principles: least privilege, deny-by-default, server-side checks, ABAC vs RBAC, IDOR                     |
| [ABAC](concepts/abac.md)                                               | Attribute/Relationship Based Access Control: NIST SP 800-162, XACML, Zanzibar/ReBAC                            |
| [IDOR](concepts/idor.md)                                               | Insecure Direct Object Reference: horizontal privilege escalation via exposed IDs (CWE-639)                    |
| [Security Logging](concepts/security-logging.md)                       | OWASP A09: what/where/who/what attributes, log injection prevention, centralized SIEM architecture             |
| [Content Security Policy](concepts/content-security-policy.md)         | CSP nonce/hash strict policy, directives reference, XSS and clickjacking defense                               |
| [DOM-based XSS](concepts/dom-xss.md)                                   | Client-side XSS; dangerous sinks vs safe sinks; context-aware encoding; DOMPurify                              |
| [Database Security](concepts/database-security.md)                     | DB isolation, TLS, least privilege, credential mgmt, OS/DB hardening                                           |
| [HTTP Security Headers](concepts/http-security-headers.md)             | Browser security headers: CSP, HSTS, COOP/COEP/CORP, Permissions-Policy, CORS                                  |
| [HSTS](concepts/hsts.md)                                               | HTTP Strict Transport Security: forces HTTPS, preload list, risks, super-cookie                                |
| [Key Management](concepts/key-management.md)                           | Key lifecycle: FIPS-compliant generation, HSM storage, KEK wrapping, audit, compromise recovery                |
| [Perfect Forward Secrecy](concepts/perfect-forward-secrecy.md)         | Ephemeral keys (ECDHE/DHE) protect past sessions from long-term key compromise                                 |
| [NPM Security](concepts/npm-security.md)                               | npm threat landscape: secrets leakage, run-scripts, typosquatting, slopsquatting, trusted publishers           |
| [Dependency Confusion](concepts/dependency-confusion.md)               | Supply chain attack: public package with same name as internal package but higher version                      |
| [Node.js Security](concepts/nodejs-security.md)                        | Node.js: event loop, HPP, helmet headers, Permission Model, dumb-init, dangerous functions, ReDoS              |
| [ReDoS](concepts/redos.md)                                             | Regex Denial of Service via catastrophic backtracking; evil patterns; RE2 engine as mitigation                 |
| [PHP Security](concepts/php-security.md)                               | Secure php.ini: expose_php, allow_url_include, disable_functions, session hardening, Snuffleupagus             |
| [REST API Security](concepts/rest-api-security.md)                     | REST design+testing: JWT alg confusion, out-of-order workflows, content-type validation, hidden attack surface |
| [Secure Code Review](concepts/secure-code-review.md)                   | Manual code review methodology: baseline vs diff, data flow, threat modeling, SAST integration, SDLC           |
| [Defense-in-Depth](concepts/defense-in-depth.md)                       | Layered security controls: physical, network, host, application, data, identity, monitoring                    |
| [Secure by Default](concepts/secure-by-default.md)                     | Systems ship in secure config; insecure modes require explicit opt-in; fail securely                           |
| [Tabnabbing](concepts/tabnabbing.md)                                   | Phishing via window.opener; child tab redirects parent page; mitigated by rel="noopener noreferrer"            |
| [Browser Storage Security](concepts/browser-storage-security.md)       | localStorage/sessionStorage/IndexedDB risks: XSS exfiltration, no session tokens, same-origin isolation        |
| [Encoding and Escaping](concepts/encoding-and-escaping.md)             | Encoding vs escaping vs sanitization vs serialization; context-aware output encoding for injection defense     |
| [Cryptographic Primitives](concepts/cryptographic-primitives.md)       | Encryption (confidentiality), hashing (integrity), digital signatures (authenticity + non-repudiation)         |
| [Federated Identity](concepts/federated-identity.md)                   | IdP/RP/SP/Principal roles; OAuth2, OIDC, SAML protocols; JWT security                                          |
| [CSS Security](concepts/css-security.md)                               | CSS info disclosure; role-isolated stylesheets; selector obfuscation; user-submitted CSS risks                 |
| [Serverless Security](concepts/serverless-security.md)                 | FaaS threat model: IAM, cold start leakage, event trust, secrets in env vars, network isolation                |
| [Session Management](concepts/session-management.md)                   | Session ID entropy, cookie attributes, session fixation/hijacking, expiration, storage, attack detection       |
| [TLS](concepts/tls.md)                                                 | TLS versions, cipher suites, DH groups, mTLS, public key pinning, HTTPS enforcement                            |
| [Certificate Management](concepts/certificate-management.md)           | DV/OV/EV cert types, wildcard risks, CAA records, ACME automation, key requirements                            |
| [Vulnerability Disclosure](concepts/vulnerability-disclosure.md)       | Private/full/responsible disclosure models, security.txt, CVE, bug bounty, safe harbor                         |
| [WebSocket Security](concepts/websocket-security.md)                   | CSWSH, origin allowlist, session drift, per-message authz, DoS, monitoring gaps                                |
| [XXE](concepts/xxe.md)                                                 | XML External Entity injection: file read, SSRF, port scan, Billion Laughs; language risk matrix                |
| [XML Security](concepts/xml-security.md)                               | Full XML threat landscape: entity expansion, schema poisoning, malformed doc DoS, SSRF                         |
| [GitOps](concepts/gitops.md)                                           | Git as single source of truth for K8s; Argo CD / Flux; audit trail, self-healing, rollback via git revert      |
| [Kubernetes Observability](concepts/kubernetes-observability.md)       | Three pillars: Prometheus metrics, Loki/ELK logs, Jaeger traces; OpenTelemetry instrumentation                 |
| [Linux Capabilities](concepts/linux-capabilities.md)                   | POSIX caps split root into ~40 units; file caps via xattr; privilege escalation vector; container hardening    |
| [AppArmor Profiles](concepts/apparmor-profiles.md)                     | Per-application MAC policy: access modes, deny rules, globbing, profile modes, Docker integration              |
| [Mandatory Access Control](concepts/mandatory-access-control.md)       | DAC vs MAC; LSM framework; AppArmor vs SELinux comparison; container security role                             |
| [Seccomp](concepts/seccomp.md)                                         | Syscall-level allowlisting via BPF; Docker default profile; 44 blocked syscalls; defense-in-depth with caps    |
| [Atomic Linux](concepts/atomic-linux.md)                               | Immutable root + atomic updates + rollback; OSTree/Nix/btrfs variants; Flatpak + Distrobox app layer           |

## Analyses

| Page | Summary | Date |
| ---- | ------- | ---- |
