# Wiki Log

Append-only record of ingests, queries, and lint passes.

**Conventions:** Section headers use `## [YYYY-MM]` format. Bullet lists only — no prose, no cumulative notes. Compact day-level entries into the current month's block at end of month.

Parse with: `grep "^## \[" wiki/log.md | tail -10`

---

## [2026-04]

- **sources ingested (179):** OWASP cheat sheets (41), K8s/Docker/Linux (13), OSTree (16), JUnit/Nix/Zarf (17), GitLab CI (5), CI/CD best practices (5), Prometheus (9), monitoring (5), SRE Book Ch. 1–27 (22), HackTricks Linux/containers/namespaces/privesc (46)
- **concepts created (115):** container-security, iac-security, supply-chain-security, immutable-infrastructure, secrets-management, cicd-security, cloud-architecture-security, shared-responsibility-model, web-application-firewall, trust-boundaries, kubernetes-security, rbac, network-policy, pod-security, admission-controllers, service-mesh, microservices-security, zero-trust, ai-agent-security, prompt-injection, human-in-the-loop, multi-agent-systems, denial-of-wallet, input-validation, file-upload-security, mcp-security, tool-poisoning, defense-in-depth, secure-by-default, tabnabbing, browser-storage-security, gitops, kubernetes-observability, authentication, password-security, mfa, adaptive-authentication, authorization, abac, idor, security-logging, content-security-policy, dom-xss, database-security, http-security-headers, hsts, php-security, rest-api-security, secure-code-review, key-management, perfect-forward-secrecy, npm-security, dependency-confusion, nodejs-security, redos, encoding-and-escaping, cryptographic-primitives, federated-identity, css-security, serverless-security, session-management, tls, certificate-management, vulnerability-disclosure, websocket-security, xxe, xml-security, linux-capabilities, apparmor-profiles, mandatory-access-control, seccomp, atomic-linux, junit-xml, nix-language, zarf-packages, gitlab-ci-variables, gitlab-ci-components, gitlab-ci-pipeline-security, continuous-integration, progressive-delivery, dora-metrics, prometheus-alerting, prometheus-recording-rules, prometheus-pushgateway, prometheus-remote-write, prometheus-zen, prometheus-instrumentation, prometheus-histograms, observability, application-performance-monitoring, alert-severity, distributed-tracing, runbooks, alertmanager, site-reliability-engineering, error-budgets, toil, service-level-objectives, four-golden-signals, automation-hierarchy, release-engineering, software-simplicity, borgmon, troubleshooting, incident-response, service-reliability-hierarchy, postmortem-culture, outage-tracking, sre-testing, intent-based-capacity-planning, load-balancing, overload-protection, cascading-failures, distributed-consensus, data-pipelines, data-integrity, launch-coordination, linux-privilege-escalation, linux-namespaces, wildcard-injection, shared-library-hijacking
- **entities created (20):** owasp, docker, podman, kubernetes, anthropic, apparmor, ostree, fedora, flatpak, distrobox, nix, zarf, gitlab, prometheus, suse, datadog, grafana, victoriametrics, hacktricks
- **updated:** container-security, secrets-management

## [2026-05-07]

- **queue (36):** slsa-v1.2-about, slsa-v1.2-threats-overview, slsa-v1.2-use-cases, slsa-v1.2-principles, slsa-v1.2-tracks, slsa-v1.2-terminology, slsa-v1.2-build-track-basics, slsa-v1.2-build-requirements, slsa-v1.2-distributing-provenance, slsa-v1.2-verifying-artifacts, slsa-v1.2-assessing-build-platforms, slsa-v1.2-source-requirements, slsa-v1.2-verifying-source, slsa-v1.2-threats, slsa-v1.2-verified-properties, slsa-v1.2-attestation-model, slsa-v1.2-provenance, slsa-v1.2-build-provenance, slsa-v1.2-verification-summary, openssf-baseline-2026-02-19, uds-core-concepts-overview, uds-core-features-overview, uds-core-networking, uds-core-identity-authorization, uds-core-monitoring-observability, uds-core-logging, uds-core-runtime-security, uds-core-policy-compliance, uds-core-platform-overview, uds-core-platform-functional-layers, uds-core-platform-security, uds-core-configuration-packaging-overview, uds-core-crd-overviews, uds-core-package-requirements, uds-core-policy-engine, uds-core-security-policy
- **concepts:** slsa, slsa-build-track, slsa-source-track, slsa-provenance, verification-summary-attestation, software-attestation, openssf-baseline, uds-operator, uds-package-cr
- **entities:** slsa, openssf, in-toto, defense-unicorns, uds-core, pepr, istio, keycloak, falco
- **updated:** supply-chain-security

## [2026-05-22]

- **queue (19):** prometheus-recording-rules, prometheus-alerting-rules, prometheus-alertmanager-config, prometheus-alertmanager-notifications, victoriametrics-metricsql, victoriametrics-vmalert, victoriametrics-vmalert-tool, victorialogs-vmalert, awesome-prometheus-alerts, sre-alerting-on-slos, vmanomaly-vmalert-guide, openscap-getting-started, openscap-security-compliance, openscap-vulnerability-assessment, openscap-choosing-policy, openscap-scap-security-guide, openscap-customization, openscap-base-tool, openscap-user-manual
- **entities:** openscap
- **updated:** awesome-prometheus-alerts (full alert names per service, 8 PromQL pattern examples, rules YAML saved to raw/assets/awesome-prometheus-alerts-rules.yml)

## [2026-06-05]

- **queue (14):** kroah-linux-is-a-cna, kroah-linux-kernel-security-work, kroah-linux-cve-assignment-process, kroah-linux-cves-overview, kroah-tracking-kernel-commits, kroah-linux-kernel-version-numbers, eu-cra-overview, eu-cra-reporting, orcwg-cra, cra-vulnerability-management, first-psirt-services-framework, gcve-vulnerability-handling-disclosure, intel-psirt-vulnerability-handling, cisa-coordinated-vulnerability-disclosure
- **concepts:** cve, cve-numbering-authority, cvss, psirt, vulnerability-handling, cyber-resilience-act, linux-kernel-release-model
- **entities:** greg-kroah-hartman, enisa, cisa, first, gcve, orcwg, intel
- **updated:** vulnerability-disclosure (CVD standards/coordinators, handling vs disclosure split, CRA overlay)
