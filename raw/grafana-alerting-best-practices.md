# Grafana Alerting Best Practices

## Overview

This guide provides best practices for setting up and managing alerts in Grafana to ensure reliable, maintainable, and effective alert systems.

## Table of Contents

- Define clear alert rules
- Organize alerts with folders and groups
- Use descriptive names and labels
- Set appropriate severity levels
- Configure notification channels
- Test your alerts
- Document alert rules
- Review and maintain alerts regularly

## Define Clear Alert Rules

### Best Practices

- Keep alert conditions simple and understandable
- Use meaningful threshold values based on your service levels
- Test thresholds in development environments first
- Document why you chose specific thresholds
- Avoid creating alerts that are too sensitive or too lenient
- Use relative thresholds when appropriate (e.g., increase > 20% from baseline)

### Example

Instead of:
```
alert when CPU > 80%
```

Use:
```
alert when CPU > 85% for 5 minutes (sustained high usage)
Reason: Based on service SLA requirements
```

## Organize Alerts with Folders and Groups

### File Structure Best Practices

- Create folders by team or service
- Group related alerts together
- Use consistent naming conventions
- Document the purpose of each folder

### Naming Convention

```
/teams/
  /platform/
    database-alerts.yml
    kubernetes-alerts.yml
  /security/
    access-control-alerts.yml
```

## Use Descriptive Names and Labels

### Alert Names

- Use clear, descriptive names that indicate what they monitor
- Include the metric and condition in the name
- Make names searchable and filterable

### Example Names

Good:
- `PostgresHighConnectionCount`
- `KubernetesNodeCPUHigh`
- `ResponseTimeP99Elevated`

Avoid:
- `alert1`
- `cpu_alert`
- `error`

### Labels

- Add labels to group and filter alerts
- Use labels to route alerts to appropriate teams
- Include context labels like environment, service, and component

Example labels:
```yaml
labels:
  severity: critical
  team: platform
  service: api
  environment: production
```

## Set Appropriate Severity Levels

### Common Severity Levels

1. **Critical** - Immediate action required, service down or severely degraded
2. **Warning** - Issue detected, may impact service, investigation needed
3. **Info** - Informational alert, no immediate action needed

### Guidelines

- Use critical sparingly - only for issues requiring immediate action
- Ensure warning alerts have clear remediation steps
- Include runbooks or links to documentation in alert descriptions
- Match severity to actual business impact

## Configure Notification Channels

### Channel Selection

- Choose channels appropriate for severity level
- Critical alerts → PagerDuty, SMS, Slack with @channel
- Warning alerts → Slack, email
- Info alerts → Email digest

### Best Practices

- Test all notification channels regularly
- Ensure on-call rotation is configured
- Use alert grouping to reduce noise
- Set up escalation policies for critical alerts
- Monitor notification delivery

## Test Your Alerts

### Testing Strategy

1. **Unit Testing** - Test alert rules in isolation
   - Verify threshold triggers correctly
   - Test query performance
   - Validate label generation

2. **Integration Testing** - Test end-to-end flow
   - Verify notifications are sent
   - Check message formatting
   - Test routing logic

3. **Load Testing** - Test under production load
   - Verify alert evaluation performance
   - Monitor resource usage
   - Test with realistic data volumes

### Testing Tools

- Use Grafana's built-in testing features
- Create test datasources with synthetic data
- Set up staging environments
- Use alert simulation features

## Document Alert Rules

### What to Document

For each alert rule, include:

1. **What** - What is being monitored
2. **Why** - Business reason for the alert
3. **When** - Conditions that trigger it
4. **How** - How to respond to it (runbook)
5. **Who** - Responsible team
6. **Links** - Related documentation, runbooks, dashboards

### Documentation Format

```yaml
# PostgreSQL High Connection Count
# WHAT: Monitors active database connections
# WHY: High connections indicate potential connection leak
# WHEN: Triggers when >500 connections for 5 minutes
# HOW: See runbook: https://wiki.example.com/postgres-connections
# WHO: Database team
# LINKS: https://grafana.example.com/d/postgres-dashboard
```

### Runbook Template

```markdown
# PostgreSQL High Connection Count

## Alert
Triggers when PostgreSQL has >500 active connections for 5 minutes.

## Impact
- New connection attempts may fail
- Application response times may degrade
- Risk of database being unable to accept new connections

## Diagnosis
1. Check active connections: `SELECT count(*) FROM pg_stat_activity;`
2. Identify long-running queries: `SELECT * FROM pg_stat_activity WHERE state != 'idle';`
3. Check connection pool settings in applications

## Remediation
1. Close idle connections
2. Terminate long-running queries if safe
3. Scale database resources if needed
4. Review application connection pool settings

## Escalation
- If connections remain high after remediation, page database oncall
```

## Review and Maintain Alerts Regularly

### Maintenance Schedule

- **Weekly** - Review alert firing patterns, look for noisy alerts
- **Monthly** - Review documentation and runbooks
- **Quarterly** - Evaluate thresholds based on actual behavior
- **Annually** - Full audit of all alert rules

### Metrics to Track

- Alert firing frequency
- Mean time to resolution (MTTR)
- False positive rate
- Alert to ticket/incident ratio

### Improvement Actions

- Disable or silence consistently false positive alerts
- Adjust thresholds based on actual data distribution
- Update runbooks based on incident learnings
- Add new alerts for gaps identified in incidents
- Remove alerts no longer relevant to your service

## Common Pitfalls to Avoid

1. **Alert Fatigue** - Too many alerts reduces response effectiveness
   - Monitor false positive rate
   - Adjust thresholds to reduce noise
   - Combine related alerts when appropriate

2. **Lack of Context** - Alerts without explanation are hard to respond to
   - Always include runbook links
   - Add examples of what triggers the alert
   - Document the customer impact

3. **Poor Routing** - Alerts going to wrong teams
   - Use clear labeling
   - Set up routing rules properly
   - Test notification delivery

4. **Static Thresholds** - Same threshold for all times
   - Consider time-of-day variations
   - Use dynamic thresholds based on baselines
   - Adjust for seasonal patterns

5. **No Escalation** - Alerts without escalation paths
   - Define escalation policies
   - Ensure on-call coverage
   - Set time-based escalations

## Summary

Effective alerting requires:

- Clear, well-understood alert rules
- Proper organization and naming
- Appropriate severity levels
- Reliable notification channels
- Regular testing and validation
- Clear documentation and runbooks
- Ongoing maintenance and improvement

By following these best practices, you'll build a more reliable and maintainable alert system that helps your team respond quickly and effectively to issues.
