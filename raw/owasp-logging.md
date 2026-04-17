# Logging Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## Introduction

This cheat sheet is focused on providing developers with concentrated guidance on building application logging mechanisms, especially related to security logging.

Many systems enable network device, operating system, web server, mail server and database server logging, but often custom application event logging is missing, disabled or poorly configured. Web application logging is much more than having web server logs enabled.

Application logging should be consistent within the application, consistent across an organization's application portfolio and use industry standards where relevant, so the logged event data can be consumed, correlated, analyzed and managed by a wide variety of systems.

## Purpose

Application logging should always be included for security events. Application logs are invaluable data for both security and operational use cases.

### Operational use cases

* General debugging
* Establishing baselines
* Business process monitoring (e.g. sales process abandonment, transactions, connections)
* Providing information about problems and unusual conditions
* Performance monitoring (e.g. data load time, page timeouts)

### Security use cases

* Anti-automation monitoring
* Identifying security incidents
* Monitoring policy violations
* Assisting non-repudiation controls
* Audit trails (e.g. data addition, modification and deletion, data exports)
* Compliance monitoring
* Data for subsequent requests for information (litigation, police and other regulatory investigations)
* Helping defend against vulnerability identification and exploitation through attack detection

## Design, Implementation, and Testing

### Event Data Sources

The application has the most information about the user (identity, roles, permissions) and the context of the event (target, action, outcomes), and often this data is not available to either infrastructure devices or closely-related applications.

Other sources: client software, embedded instrumentation, network firewalls, NIDS and HIDS, application firewalls (WAFs), database applications, OS.

The degree of confidence in the event information has to be considered when including event data from systems in a different trust zone. Data may be missing, modified, forged, replayed and could be malicious — it must always be treated as untrusted data.

### Where to Record Event Data

* When using the file system, use a separate partition than those used by the operating system and other application files; apply strict permissions concerning which users can access log directories and files.
* In web applications, the logs should not be exposed in web-accessible locations.
* When using a database, use a separate database account that is only used for writing log data with very restrictive permissions.
* Use standard formats over secure protocols (e.g. Common Log File System (CLFS) or Common Event Format (CEF) over syslog).

### Which Events to Log

Where possible, always log:

* Input validation failures (protocol violations, unacceptable encodings, invalid parameter names and values)
* Output validation failures
* Authentication successes and failures
* Authorization (access control) failures
* Session management failures (cookie session identification value modification, suspicious JWT validation failures)
* Application errors and system events
* Application and related systems start-ups and shut-downs, and logging initialization
* Use of higher-risk functionality:
  + User administration actions (addition/deletion of users, changes to privileges)
  + Use of systems administrative privileges
  + Use of default or shared accounts or "break-glass" accounts
  + Access to sensitive data (payment cardholder data)
  + Encryption activities (use or rotation of cryptographic keys)
  + Deserialization failures
* Legal and other opt-ins (permissions for mobile phone capabilities, terms of use, personal data usage consent)
* Suspicious business logic activities (attempts to perform actions out of order, actions which don't make sense in business context)

Optionally consider logging: sequencing failures, excessive use, data changes, fraud, suspicious behavior, configuration modifications.

### Event Attributes

Each log entry needs to include sufficient information for subsequent monitoring and analysis. The application logs must record **"when, where, who and what"** for each event.

**When:**
* Log date and time (international format)
* Event date and time
* Interaction identifier (links all events for a single user interaction)

**Where:**
* Application identifier (name and version)
* Application address (cluster/hostname or server IPv4/IPv6 address and port)
* Service name and protocol
* Geolocation
* Code location (script name, module name)

**Who (human or machine user):**
* Source address (user's device identifier, user's IP address)
* User identity (if authenticated or otherwise known)

**What:**
* Type of event
* Severity of event
* Security relevant event flag
* Description

### Data to Exclude

Never log data unless it is legally sanctioned.

The following should usually not be recorded directly in the logs, but instead should be removed, masked, sanitized, hashed, or encrypted:
* Application source code
* Session identification values (consider replacing with a hashed value)
* Access tokens
* Sensitive personal data and PII (health, government identifiers)
* Authentication passwords
* Database connection strings
* Encryption keys and other primary secrets
* Bank account or payment card holder data
* Commercially-sensitive information
* Information it is illegal to collect in the relevant jurisdictions
* Information a user has opted out of collection

### Customizable Logging

If variable logging levels are implemented:
* The default level must provide sufficient detail for business needs
* It should not be possible to completely deactivate application logging
* Alterations to the level/extent of logging must follow change management processes
* The logging level must be verified periodically

### Event Collection

* Perform input validation on event data from other trust zones
* Perform sanitization on all event data to prevent log injection attacks (carriage return (CR), line feed (LF) and delimiter characters)
* Encode data correctly for the output (logged) format
* Synchronize time across all servers and devices

### Verification

Logging functionality and systems must be included in code review, application testing and security verification processes:
* Ensure logging is working correctly and as specified
* Check that events are being classified consistently
* Test the mechanisms are not susceptible to injection attacks
* Ensure logging cannot be used to deplete system resources (filling up disk space)
* Verify access controls on the event log data

### Network Architecture

A centralized system for collecting logs is recommended. Log collector accepts logs from business applications and saves in log storage. Log loader application downloads log from storage, pre-processes, and transfers to UI. Logs should flow one-way from application segments to centralized storage in a separate network segment.

## Deployment and Operation

### Release
* Provide security configuration information by adding details about the logging mechanisms to release documentation
* Ensure the outputs of the monitoring are integrated with incident response processes

### Protection

The logging mechanisms and collected event data must be protected from misuse such as tampering in transit, and unauthorized access, modification and deletion once stored.

At rest:
* Build in tamper detection
* Store or copy log data to read-only media as soon as possible
* All access to the logs must be recorded and monitored
* Privileges to read log data should be restricted and reviewed periodically

In transit:
* If log data is sent over untrusted networks, use a secure transmission protocol
* Perform due diligence checks before sending event data to third parties

### Monitoring of Events

* Incorporate the application logging into any existing log management systems/infrastructure
* Enable alerting and signal the responsible teams about more serious events immediately
* Share relevant event information with other detection systems

### Disposal of Logs

Log data must not be destroyed before the duration of the required data retention period, and must not be kept beyond this time. Legal, regulatory and contractual obligations may impact on these periods.

## Attacks on Logs

### Confidentiality

* Logs contain PII of users — attackers gather PII for further attacks.
* Logs contain technical secrets such as passwords.

### Integrity

* An attacker with read access to a log uses it to exfiltrate secrets.
* An attack leverages logs to connect with exploitable facets of logging platforms (e.g., log4shell-type payloads).

### Availability

* An attacker floods log files to exhaust disk space available for non-logging facets of system functioning.
* An attacker uses one log entry to destroy other log entries.
* An attacker leverages poor performance of logging code to reduce application performance.

### Accountability

* An attacker prevents writes to cover their tracks.
* An attacker causes the wrong identity to be logged to conceal the responsible party.

## Related Articles

* OWASP ESAPI Documentation
* OWASP Logging Project
* IETF syslog protocol (RFC 5424)
* NIST SP 800-92 Guide to Computer Security Log Management
