---
title: "Falco"
tags: [product, runtime-security, ebpf, cncf, threat-detection, kubernetes]
sources: [uds-core-runtime-security.md]
updated: 2026-05-07
---

# Falco

Falco is an open-source runtime security tool, a CNCF graduated project. It monitors system-level behavior inside containerized workloads using eBPF probes, detecting malicious activity that static configuration controls cannot catch.

## How it works

Falco attaches eBPF probes to the Linux kernel to observe all syscalls made by processes on a node — including processes inside containers — without modifying the containers or requiring application changes.

| Component      | Role                                                            |
| -------------- | --------------------------------------------------------------- |
| eBPF probe     | Observes syscalls at the kernel level                           |
| Falco engine   | Evaluates event stream against rules; generates alerts on match |
| Falco Sidekick | Fan-out alert forwarder to Alertmanager, SIEM, Slack, etc.      |

## Default detections

- Shell execution in containers (common indicator of compromise)
- Sensitive file access (`/etc/shadow`, `/proc/[pid]/mem`, credential files)
- Privilege escalation (`setuid` execution, capability changes)
- Network scanning and unexpected outbound connections
- Cryptomining patterns (process names, connection patterns)

## Alert routing

Falco Sidekick fans out alerts to multiple destinations: Loki, Alertmanager, SIEM platforms (HTTP webhooks), Slack/Teams/Mattermost, Elasticsearch, and others.

## Role in UDS Core

Falco is the runtime security layer in [UDS Core](uds-core.md) (`core-runtime-security` layer). It represents the innermost defense layer: detecting malicious behavior inside containers that have already passed all other controls.

## Related pages

- [UDS Core — Runtime Security](../sources/uds-core-runtime-security.md)
- [Defense-in-Depth](../concepts/defense-in-depth.md)
- [Container Security](../concepts/container-security.md)
- [UDS Core](uds-core.md)
