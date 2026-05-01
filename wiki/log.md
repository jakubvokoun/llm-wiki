# Wiki Log

Append-only record of ingests, queries, and lint passes.

Parse with: `grep "^## \[" wiki/log.md | tail -10`

---

## [Archive: 2026-04-15 → 2026-04-24]

Cumulative totals from the first 10 days:

- **sources ingested (128):** OWASP cheat sheets (41), K8s/Docker/Linux (13), OSTree (16), JUnit/Nix/Zarf (17), GitLab CI (5), CI/CD best practices (5), Prometheus (9), monitoring (5), SRE Book Ch. 1–21 (17)
- **concepts created (106):** container-security, iac-security, supply-chain-security, immutable-infrastructure, secrets-management, cicd-security, cloud-architecture-security, shared-responsibility-model, web-application-firewall, trust-boundaries, kubernetes-security, rbac, network-policy, pod-security, admission-controllers, service-mesh, microservices-security, zero-trust, ai-agent-security, prompt-injection, human-in-the-loop, multi-agent-systems, denial-of-wallet, input-validation, file-upload-security, mcp-security, tool-poisoning, defense-in-depth, secure-by-default, tabnabbing, browser-storage-security, gitops, kubernetes-observability, authentication, password-security, mfa, adaptive-authentication, authorization, abac, idor, security-logging, content-security-policy, dom-xss, database-security, http-security-headers, hsts, php-security, rest-api-security, secure-code-review, key-management, perfect-forward-secrecy, npm-security, dependency-confusion, nodejs-security, redos, encoding-and-escaping, cryptographic-primitives, federated-identity, css-security, serverless-security, session-management, tls, certificate-management, vulnerability-disclosure, websocket-security, xxe, xml-security, linux-capabilities, apparmor-profiles, mandatory-access-control, seccomp, atomic-linux, junit-xml, nix-language, zarf-packages, gitlab-ci-variables, gitlab-ci-components, gitlab-ci-pipeline-security, continuous-integration, progressive-delivery, dora-metrics, prometheus-alerting, prometheus-recording-rules, prometheus-pushgateway, prometheus-remote-write, prometheus-zen, prometheus-instrumentation, prometheus-histograms, observability, application-performance-monitoring, alert-severity, distributed-tracing, runbooks, alertmanager, site-reliability-engineering, error-budgets, toil, service-level-objectives, four-golden-signals, automation-hierarchy, release-engineering, software-simplicity, borgmon, troubleshooting, incident-response, service-reliability-hierarchy, postmortem-culture, outage-tracking, sre-testing, intent-based-capacity-planning, load-balancing, overload-protection
- **entities created (18):** owasp, docker, podman, kubernetes, anthropic, apparmor, ostree, fedora, flatpak, distrobox, nix, zarf, gitlab, prometheus, suse, datadog, grafana, victoriametrics

## [2026-04-25]

- **queue (5):** sre-addressing-cascading-failures, sre-managing-critical-state, sre-data-processing-pipelines, sre-data-integrity, sre-reliable-product-launches
- **concepts (5):** cascading-failures, distributed-consensus, data-pipelines, data-integrity, launch-coordination

## [2026-05-01]

- **queue (46):** hacktricks-linux-basics, hacktricks-privilege-escalation, hacktricks-linux-capabilities, hacktricks-container-security, hacktricks-container-runtimes, hacktricks-runtime-api-daemon-exposure, hacktricks-authorization-plugins, hacktricks-image-security-and-secrets, hacktricks-assessment-and-hardening, hacktricks-sensitive-host-mounts, hacktricks-privileged-containers, hacktricks-distroless, hacktricks-container-apparmor, hacktricks-container-capabilities, hacktricks-container-cgroups, hacktricks-masked-paths, hacktricks-no-new-privileges, hacktricks-read-only-paths, hacktricks-container-seccomp, hacktricks-container-selinux, hacktricks-namespaces-index, hacktricks-cgroup-namespace, hacktricks-ipc-namespace, hacktricks-pid-namespace, hacktricks-mount-namespace, hacktricks-network-namespace, hacktricks-time-namespace, hacktricks-user-namespace, hacktricks-uts-namespace, hacktricks-pam, hacktricks-bypass-bash-restrictions, hacktricks-bypass-fs-protections, hacktricks-privilege-escalation-checklist, hacktricks-euid-ruid-suid, hacktricks-escaping-limited-bash, hacktricks-ssh-forward-agent, hacktricks-nfs-no-root-squash, hacktricks-write-to-root, hacktricks-dbus-enumeration, hacktricks-containerd-ctr-privilege-escalation, hacktricks-runc-privilege-escalation, hacktricks-interesting-groups-linux-pe, hacktricks-wildcards-spare-tricks, hacktricks-socket-command-injection, hacktricks-electron-cef-chromium-debugger-abuse, hacktricks-ld-so-conf-example
- **concepts:** linux-privilege-escalation, linux-namespaces, wildcard-injection, shared-library-hijacking
- **entities:** hacktricks
- **updated:** container-security, secrets-management
