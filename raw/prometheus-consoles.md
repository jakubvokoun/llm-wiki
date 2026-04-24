# Consoles and Dashboards

> **CAUTION**: Starting with Prometheus 3.0, console templates and libraries are no longer bundled with Prometheus. If you wish to use console templates, you must provide your own templates and libraries by specifying the `--web.console.templates` and `--web.console.libraries` command-line flags. This documentation page is maintained for historical reference and to demonstrate the capabilities of console templates. Please be aware that any referenced console libraries from the Prometheus 2.x branch are no longer maintained and may contain known security vulnerabilities (CVEs).

## Design Philosophy

Dashboards and consoles should resist the urge to display excessive data. When building operational consoles, focus on identifying likely failure modes and how the interface helps users differentiate between them. Leveraging your system's structural organization—such as a service hierarchy—enables more effective troubleshooting. For instance, in online-serving systems where latency in lower-level services frequently causes problems, create separate dashboards for each service showing latency and errors for dependent services. This approach allows operators to start at the top and work downward to pinpoint issues.

## Recommended Guidelines

The documentation suggests adhering to these constraints:

- **Limit graphs**: Include no more than 5 graphs per console
- **Limit plots**: Display no more than 5 lines per graph (more is acceptable for stacked or area graphs)
- **Table entries**: When using console templates, avoid exceeding 20-30 entries in side tables

Exceeding these thresholds warrants demoting less critical information, splitting subsystems into separate consoles, displaying aggregated rather than granular data, moving information to side tables, or removing rarely-used metrics entirely—which remain accessible through the expression browser.

## Multiple Use Cases Require Multiple Dashboards

"What you want to know when oncall (what is broken?) tends to be very different from what you want when developing features." Maintaining separate console sets for on-call and development scenarios proves beneficial, as these roles have fundamentally different information needs.
