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

## [2026-04-23]

- **queue (28):** junitxml-testmoapp, nix-language-tutorial, nix-best-practices, awesome-nix, zarf-creating-package, zarf-initializing-k8s-cluster, zarf-deploying-packages, zarf-retro-arcade, zarf-creating-k8s-cluster, zarf-package-signing, zarf-publish-and-deploy, zarf-custom-init-packages, zarf-resource-adoption, zarf-package-create-differential, zarf-schema-v1alpha1-package, zarf-airgap-demos, zarf-data-injections-migration, zarf-upgrading-zarf, gitlab-ci-predefined-variables, gitlab-ci-components, gitlab-ci-components-examples, gitlab-ci-pipeline-security, gitlab-ci-debugging, 42coffeecups-ci-best-practices, wiz-cicd-security-best-practices, launchdarkly-cicd-best-practices, harness-cicd-best-practices, zenika-gitlab-ci-best-practices
- **concepts:** junit-xml, nix-language, zarf-packages, gitlab-ci-variables, gitlab-ci-components, gitlab-ci-pipeline-security, continuous-integration, progressive-delivery, dora-metrics
- **entities:** nix, zarf, gitlab
- **updated:** zarf, zarf-packages (dataInjections deprecation, upgrade section, new source links)

## [2026-04-24]

- **ingest (5):** suse-observability-monitoring-strategies, devto-web-app-monitoring-best-practices, datadog-monitoring-101-alerting, group107-infrastructure-monitoring-best-practices, grafana-alerting-best-practices
- **queue (20):** wonderment-cicd-best-practices, prometheus-naming, prometheus-consoles, prometheus-instrumentation, prometheus-histograms, prometheus-alerting, prometheus-rules, prometheus-pushing, prometheus-remote-write, prometheus-the-zen, victoriametrics-alerting-best-practices, victoriametrics-alerting-recording-rules-alertmanager, sre-book-introduction, sre-book-part-ii-principles, sre-book-embracing-risk, sre-book-service-level-objectives, sre-book-eliminating-toil, sre-book-monitoring-distributed-systems, sre-book-automation-at-google, sre-book-release-engineering
- **entities:** prometheus, suse, datadog, grafana, victoriametrics
- **concepts:** prometheus-alerting, prometheus-recording-rules, prometheus-pushgateway, prometheus-remote-write, prometheus-zen, prometheus-instrumentation, prometheus-histograms, observability, application-performance-monitoring, alert-severity, distributed-tracing, runbooks, alertmanager, site-reliability-engineering, error-budgets, toil, service-level-objectives, four-golden-signals, automation-hierarchy, release-engineering
- **updated:** prometheus (entity), prometheus-instrumentation (Pushgateway pitfalls), prometheus-alerting (for/keep_firing_for/lookbehind guidance), observability (Google SRE monitoring output types), runbooks (MTTR playbook stat), error-budgets (ISP noise floor, request success rate, quarterly mechanics, cost model), toil (6-attribute table, not-toil distinctions, engineering vs overhead table)
