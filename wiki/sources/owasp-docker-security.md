---
title: "OWASP Docker Security Cheat Sheet"
tags: [docker, containers, security, owasp, hardening]
sources: [owasp-docker-security.md]
updated: 2026-04-15
---

# OWASP Docker Security Cheat Sheet

Summary of the 13 rules from the OWASP Docker Security Cheat Sheet.

## Key Takeaways

Docker enhances security vs. bare-metal when configured correctly — but misconfigurations introduce new attack surfaces. The cheat sheet provides 13 rules covering host hardening, runtime security, and supply chain.

## The 13 Rules

| #   | Rule                                 | Key Action                                                                |
| --- | ------------------------------------ | ------------------------------------------------------------------------- |
| 0   | Keep host and Docker up to date      | Patch kernel + Docker Engine; containers share host kernel                |
| 1   | Don't expose Docker socket           | `/var/run/docker.sock` = root access; never mount it in containers        |
| 2   | Set a user                           | Run as non-root via `-u`, `USER` in Dockerfile, or `--userns-remap`       |
| 3   | Limit capabilities                   | `--cap-drop all --cap-add <NEEDED>`; never use `--privileged`             |
| 4   | Prevent privilege escalation         | Always use `--security-opt=no-new-privileges`                             |
| 5   | Control inter-container connectivity | Use custom networks instead of `--icc=false`; use K8s NetworkPolicies     |
| 5a  | Port binding + firewalls (UFW)       | Docker bypasses UFW; bind to `127.0.0.1:port:port` or use `ufw-docker`    |
| 6   | Use Linux Security Modules           | seccomp, AppArmor, or SELinux; don't disable defaults; add Falco/Tetragon |
| 7   | Limit resources                      | `--memory`, `--cpus`, `--ulimit` to prevent DoS                           |
| 8   | Read-only filesystem                 | `--read-only` + `--tmpfs /tmp`; mount volumes `:ro`                       |
| 9   | Container scanning in CI/CD          | Trivy, Clair, Snyk, Docker Bench for Security                             |
| 10  | Logging at `info` level              | Don't run daemon at `debug` in production                                 |
| 11  | Rootless mode                        | Daemon itself runs unprivileged; stronger than userns-remap               |
| 12  | Docker Secrets                       | Manage sensitive data via `docker secret`; avoid env vars / image embeds  |
| 13  | Supply chain security                | SBOM (CycloneDX), image signing (Notary), SLSA provenance, OPA policies   |

## Podman as Alternative

[Podman](../entities/podman.md) offers rootless-by-default, daemonless (fork-exec) architecture with SELinux integration — stronger secure defaults than Docker.

## Concepts Referenced

- [Container Security](../concepts/container-security.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Secrets Management](../concepts/secrets-management.md)

## Related Entities

- [OWASP](../entities/owasp.md)
- [Docker](../entities/docker.md)
- [Podman](../entities/podman.md)
