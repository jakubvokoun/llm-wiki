# Secure Code Review Cheat Sheet

## Introduction

**Secure Code Review** is the process of manually examining source code to identify security vulnerabilities that automated tools often miss. It involves analyzing application logic, data flow, and implementation details to detect security flaws requiring human expertise and contextual understanding.

**Manual Code Review** complements automated security testing tools (SAST/DAST) by focusing on areas where human analysis provides the most value: business logic validation, complex security implementations, and context-specific vulnerabilities.

**Security-Focused Review** differs from functional code review by specifically targeting security concerns such as input validation, authentication mechanisms, authorization controls, cryptographic implementations, and potential attack vectors.

### Review Types

**Baseline Reviews** — examine the entire codebase comprehensively. Use for:
- New applications or major releases
- Legacy system onboarding
- Compliance requirements
- Post-incident analysis

**Diff-Based Reviews** — focus on code changes only. Use for:
- Pull requests and commits
- Daily development workflow
- Feature completion
- Continuous security validation

## Review Methodology

### Preparation

**For All Reviews:**
- Understand application architecture and business requirements
- Gather threat models and previous security findings
- Identify critical assets and high-risk functions
- Review security requirements and documentation

**Additional for Baseline Reviews:**
- Map complete application boundaries and dependencies
- Analyze overall security architecture
- Audit all third-party libraries

**Additional for Diff-Based Reviews:**
- Identify modified files and affected components
- Assess impact on existing security controls
- Prioritize high-risk modifications

### Review Process

**Baseline Review Steps:**
1. Architecture review for security anti-patterns
2. Entry point analysis and input validation
3. Authentication and authorization verification
4. Data flow tracing
5. Business logic analysis
6. Cryptographic implementation review
7. Error handling verification
8. Configuration and deployment review

**Diff-Based Review Steps:**
1. Analyze impact on existing security controls
2. Identify new attack vectors
3. Verify security at modified trust boundaries
4. Check new integrations
5. Ensure no security regression
6. Apply relevant security patterns

## Common Vulnerability Patterns

### Input Validation Vulnerabilities
Check for missing server-side validation, improper sanitization, and weak input filtering.

### Injection Vulnerabilities
- **SQL Injection** — string concatenation in database queries, unsafe query construction.
- **XSS** — output encoding, DOM manipulation, user input rendering.
- **Path Traversal** — unsafe file path construction, directory traversal.
- **Command Injection** — direct command execution with user input, unsafe system calls.
- **NoSQL Injection** — NoSQL query construction and parameter binding.

### Authentication & Session Management Vulnerabilities
Review authentication mechanisms, session token generation, and user credential handling.

### Access Control Vulnerabilities
Examine authorization checks, role-based access controls, and privilege escalation prevention.

### Deserialization Vulnerabilities
- **Insecure Deserialization** — unsafe deserialization of untrusted data, object injection.
- **XXE** — XML parsing configurations and external entity processing.

### Cryptographic Implementation Flaws
Examine encryption algorithms, key management, and cryptographic implementations.

## Review Techniques

### Code Pattern Analysis

Focus on high-risk code patterns:
- Input processing and validation functions
- Database query construction and ORM usage
- File operations and path handling
- Authentication and session management logic
- Authorization and access control checks
- Cryptographic operations and key management
- Error handling and logging mechanisms
- Configuration loading and environment variables

### Data Flow Analysis

1. **Identify Sources**: User inputs, file uploads, API calls, database reads, environment variables
2. **Follow Processing**: Validation, transformation, business logic, caching
3. **Check Sinks**: Database queries, file writes, output rendering, logging, external APIs
4. **Validate Boundaries**: Input validation and output encoding at trust boundaries
5. **Trust Zones**: Verify security controls at each trust boundary crossing

### Threat-Based Review

- **OWASP Top 10** — focus on prevalent web application risks
- **STRIDE Model** — Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege
- **Attack Trees** — map potential attack paths through the application
- **Abuse Cases** — consider how features could be misused by attackers

### Business Logic Review

Analyze application workflows for:
- State management and transition validation
- Race conditions and concurrency issues
- Transaction integrity and rollback mechanisms
- Resource limits and quota enforcement
- Authorization at each workflow step
- Workflow bypass opportunities

## Review Checklists

### Input Validation
- [ ] Server-side validation on all inputs (regardless of client-side checks)
- [ ] Allowlist validation rather than blocklist
- [ ] Context-appropriate output encoding (HTML, JavaScript, CSS, URL, SQL)
- [ ] File upload security (content-based validation, size limits, safe storage)
- [ ] SQL injection prevention (parameterized queries or stored procedures)
- [ ] Input length restrictions enforced
- [ ] Special characters and Unicode properly processed
- [ ] No sensitive information in error responses

### Authentication & Session Management
- [ ] Strong hashing algorithms with salt for passwords
- [ ] Account lockout mechanisms with appropriate thresholds
- [ ] Secure token generation (≥128 bits entropy)
- [ ] Proper session invalidation on logout/timeout
- [ ] Re-authentication for sensitive operations
- [ ] MFA implementation for high-risk accounts
- [ ] Secure, time-limited password reset mechanisms
- [ ] HttpOnly, Secure, SameSite cookie attributes
- [ ] Appropriate limits on concurrent sessions

### Authorization
- [ ] All access controls enforced server-side
- [ ] Default deny access policy
- [ ] Proper authorization for resource access (IDOR prevention)
- [ ] Administrative functions properly protected
- [ ] Role assignments cannot be manipulated
- [ ] Horizontal and vertical privilege escalation prevented
- [ ] Access control logic centralized
- [ ] Authorization verified after authentication

### Cryptography
- [ ] Modern algorithms (AES-256, RSA-2048+, ECDSA P-256+)
- [ ] Proper key generation, storage, and rotation
- [ ] Proper certificate validation including hostname verification
- [ ] Cryptographically secure random number generation
- [ ] Encryption at rest and in transit
- [ ] Unique and unpredictable initialization vectors (IV/Nonce)
- [ ] Up-to-date cryptographic libraries
- [ ] Consideration of timing and other side-channel attacks

### Business Logic
- [ ] Proper state validation in multi-step processes
- [ ] Synchronization in concurrent operations
- [ ] Proper rollback and consistency mechanisms
- [ ] Rate limiting and resource quotas implemented
- [ ] Business rules cannot be bypassed through direct API access

### Configuration & Deployment
- [ ] Security-focused default configurations
- [ ] Proper isolation between environments
- [ ] No hardcoded secrets; proper secret storage and rotation
- [ ] Graceful error handling without information disclosure
- [ ] Sensitive data not logged; proper log protection
- [ ] Appropriate HTTP security headers configured
- [ ] Strong cipher suites and TLS protocol versions
- [ ] Up-to-date libraries without known vulnerabilities

### Security Monitoring
- [ ] Authentication failures and authorization violations logged
- [ ] Unusual patterns and behaviors monitored
- [ ] Complete audit logs for sensitive operations
- [ ] Critical security events trigger immediate notifications
- [ ] Logs protected from tampering and unauthorized access
- [ ] Clear procedures for security incident handling

## Tools and Techniques

### Command-Line Pattern Detection

```bash
# Find hardcoded secrets
grep -ri "password\s*=\|api_key\s*=\|secret\s*=" source/

# Find unsafe functions
grep -r "eval(\|exec(\|innerHTML\|document\.write" source/

# Find potential injections
grep -r "SELECT.*+\|executeQuery.*+" source/
```

### Manual Review Focus Areas (Human Advantage)

- **Business Logic Flaws** — complex workflows requiring domain understanding
- **Context-Specific Vulnerabilities** — depend on application-specific business rules
- **Authorization Logic** — complex permission models
- **Race Conditions** — timing-based vulnerabilities in concurrent operations
- **Cryptographic Misuse** — proper implementation of cryptographic primitives
- **Architecture Security** — high-level design flaws and security anti-patterns

### Automated Tool Integration

- **SAST Tool Triage** — use automated findings to prioritize manual review areas
- **Pre-Review Scanning** — run automated tools before manual review
- **Complementary Analysis** — use tool findings to guide deeper manual investigation
- **False Positive Filtering** — apply human judgment to validate automated findings

## Integration with SDLC

### Review Timing

**Baseline Review Integration:**
- Project initiation, major releases, architecture changes, compliance cycles, post-incidents

**Diff-Based Review Integration:**
- Pull requests, pre-commit hooks, feature completion, sprint reviews, hotfixes, CI triggers

**Hybrid Approach:**
- Risk-based scheduling: baseline for high-risk components, diff-based for routine changes
- Escalate from diff-based to baseline when significant security concerns are identified

### Team Collaboration

**Roles:** Security reviewers (conduct analysis), Developers (implement fixes), Security champions (bridge security and development)

**Best Practices:**
- Use standardized checklists and templates
- Maintain a knowledge base of common issues
- Track metrics on review effectiveness
- Provide regular security training

## Advanced Techniques

### Race Condition Analysis
Focus on Time-of-Check vs Time-of-Use (TOCTOU) vulnerabilities and ensure atomic operations.

### Business Logic Analysis
Analyze workflows for state transitions, bypass opportunities, validation at each step, rollback mechanisms, concurrent access behavior, and boundary conditions.

### Security Architecture Review
Review architecture patterns for consistent security enforcement and proper API security controls.

### Memory Safety
Review buffer management, integer overflow protection, and resource limits.
