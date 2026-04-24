# Prometheus Metric and Label Naming Practices

## Overview

Prometheus metric naming conventions serve as style guidelines and best practices, though they're not strictly required. Organizations may adapt these recommendations to their specific needs.

## Metric Name Requirements

Metric names must follow these principles:

**Core Rules:**
- Comply with the data model's valid character specifications
- Include a single-word application prefix relevant to the metric's domain (e.g., `prometheus_`, `process_`, `http_`)
- Reference only a single unit and quantity—don't mix seconds with milliseconds or combine unrelated measurements

**Formatting Standards:**
- Use base units (seconds, bytes, meters) rather than derived units
- Include a suffix describing the unit in plural form
- Accumulating counts should have `total` as a suffix
- Ensure the metric represents the same logical measurement across all label dimensions

**Examples of proper naming:**
- `http_request_duration_seconds`
- `node_memory_usage_bytes`
- `http_requests_total`
- `process_cpu_seconds_total`

## Why Unit and Type Information Matters

Including units and types in metric names ensures reliability during incident response. Most metric consumption happens through plain YAML configuration files for alerting, recording, and dashboards—contexts where rich UI assistance isn't available. Additionally, unit information prevents naming collisions as metrics evolve.

## Label Guidelines

Labels differentiate characteristics of measured items. Avoid redundancy by not duplicating label names in the metric name itself. Critically, prevent high-cardinality labels (user IDs, email addresses) that dramatically increase stored data volume.

## Base Units Table

Common metric families use standardized base units: Time (seconds), Temperature (celsius), Length (meters), Bytes (bytes), Percent (ratio as 0–1), Voltage (volts), and Mass (grams).
