# Publish & Deploy Packages with OCI

## Overview

This tutorial explains how to publish Zarf packages to OCI-compliant registries, enabling users to pull and deploy packages without local builds or manual transfers.

## Key Requirements

- Internet connectivity for resource downloads and package uploads
- Access to an OCI Distribution Spec-compatible registry (Docker Hub is used in examples)
- Zarf binary installed and accessible
- An initialized Kubernetes cluster

## Core Workflow

**Publishing**: After creating a package with a `metadata.version` field in `zarf.yaml`, use `zarf package create` to build it locally, then `zarf package publish` to upload to your registry. The artifact name derives from package metadata (e.g., `helm-oci-chart:0.0.1-arm64`).

**Inspecting**: Use `zarf package inspect` with the same flags as local packages to examine registry-stored packages.

**Deploying**: The `zarf package deploy` command works nearly identically for registry-hosted packages as local ones.

**Pulling**: Use `zarf package pull` to download packages locally for repeated deployments without fetching each time.

## Common Issues

The tutorial addresses several troubleshooting scenarios:

- Missing version metadata prevents publishing
- HTTP registries require the `--plain-http` flag
- Uninitialized clusters produce "zarf-state" secret errors
- Unreachable clusters need kubectl configuration verification
