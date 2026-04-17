---
title: "Kubernetes"
tags: [kubernetes, containers, orchestration, cncf, product]
sources: [owasp-kubernetes-security.md]
updated: 2026-04-15
---

# Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform originally developed by Google, now maintained by the CNCF (Cloud Native Computing Foundation).

## Overview

Kubernetes manages containerized workloads across clusters of nodes. It provides:

- Automated deployment, scaling, and rolling updates
- Service discovery and load balancing
- Self-healing (restarts failed containers, reschedules on failed nodes)
- Secret and configuration management
- Storage orchestration

## Architecture

### Control Plane

- **API server** (`kube-apiserver`): Central management endpoint; all cluster operations go through it
- **etcd**: Distributed key-value store; holds all cluster state including secrets
- **Scheduler** (`kube-scheduler`): Assigns pods to nodes based on resource requirements
- **Controller Manager** (`kube-controller-manager`): Runs reconciliation loops (deployments, replicasets, etc.)

### Node Components

- **kubelet**: Agent on each node; manages containers via container runtime
- **kube-proxy**: Manages network rules for service routing
- **Container runtime**: Runs containers (containerd, CRI-O)

## Security Features

- **RBAC**: Role-based access control for API access
- **Pod Security Standards**: Privileged / Baseline / Restricted policy levels
- **NetworkPolicy**: L3/L4 traffic control between pods
- **Secrets**: Base64-encoded (optionally encrypted at rest) credential objects
- **Admission controllers**: Policy enforcement at API request time
- **Audit logging**: Full API server activity log

## Hosted Distributions

- **EKS** (AWS Elastic Kubernetes Service)
- **GKE** (Google Kubernetes Engine)
- **AKS** (Azure Kubernetes Service)
- OpenShift (Red Hat enterprise distribution)

## Related Concepts

- [kubernetes-security](../concepts/kubernetes-security.md)
- [container-security](../concepts/container-security.md)
- [rbac](../concepts/rbac.md)
- [pod-security](../concepts/pod-security.md)
- [network-policy](../concepts/network-policy.md)
- [admission-controllers](../concepts/admission-controllers.md)
- [gitops](../concepts/gitops.md)
- [kubernetes-observability](../concepts/kubernetes-observability.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
- [Kubernetes Best Practices 101](../sources/k8s-best-practices-readme.md)
