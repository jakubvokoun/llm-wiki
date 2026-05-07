---
title: "UDS Core — Runtime Security"
tags: [uds-core, falco, ebpf, runtime-security, threat-detection, cncf]
sources: [uds-core-runtime-security.md]
updated: 2026-05-07
---

# UDS Core — Runtime Security

UDS Core provides runtime threat detection using [Falco](../entities/falco.md), a CNCF graduated project. Runtime security watches what workloads are _doing_, not just what they are _configured_ to do.

## Why runtime security?

Admission control and network policy prevent known bad configurations. They cannot detect compromise at runtime: a malicious binary executed inside a permitted container, credential theft from a mounted secret, or a process spawning an unexpected shell. Runtime security observes system-level behavior to catch these gaps.

## How Falco works

Falco monitors the Linux kernel via eBPF probes — observing syscalls made by all processes on a node, including those inside containers, without modifying containers or requiring application changes.

| Component | Role |
| --- | --- |
| eBPF probe | Observes all syscalls at the kernel level; no container changes |
| Falco engine | Evaluates event stream against rules; generates alerts on match |
| Falco Sidekick | Fans out alerts to Alertmanager, SIEM, Slack, Elasticsearch, etc. |

## Default detections

The default rule set covers:

- **Shell execution in containers** — unexpected shell spawns (common indicator of compromise)
- **Sensitive file access** — `/etc/shadow`, `/proc/[pid]/mem`, credential files
- **Privilege escalation** — `setuid` execution, capability changes
- **Network scanning / unexpected outbound** — connections from workloads that should not make them
- **Cryptomining patterns** — process names and connection patterns associated with miners

## Alert integration

By default, runtime alerts are sent as events to Loki, making them queryable alongside application logs in Grafana. Falco Sidekick can also route to Alertmanager, SIEM platforms via HTTP webhooks, Slack/Teams/Mattermost, Elasticsearch, and others.

## Defense-in-depth position

| Layer | Role |
| --- | --- |
| Policy engine (Pepr) | Blocks misconfigured workloads at admission |
| Service mesh (Istio) | Blocks unauthorized lateral movement between services |
| Network policy | Blocks unauthorized traffic at the IP level |
| Runtime security (Falco) | Detects malicious behavior inside permitted workloads |

Runtime security specifically catches compromise that the other layers cannot prevent: a legitimate container that has been exploited, or a supply chain attack that introduced a malicious binary into an otherwise-permitted image.

## Related pages

- [Defense-in-Depth](../concepts/defense-in-depth.md)
- [Falco](../entities/falco.md)
- [Container Security](../concepts/container-security.md)
- [Security Logging](../concepts/security-logging.md)
