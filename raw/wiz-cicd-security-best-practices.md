# CI/CD Pipeline Security Best Practices 2026

## CI/CD security main takeaways:

* **CI/CD pipelines have become high-value targets for attackers**—compromised pipelines enable malicious code injection, data theft, and production system access.
* **Effective CI/CD security requires protection at each pipeline stage** (source, build, test, and deploy) with specific security controls tailored to each component's unique risks.
* **Key security practices** include implementing automated security scanning with runtime monitoring, managing secrets effectively, using immutable infrastructure, establishing role-based access control, and educating development teams on security best practices.
* **To continuously improve your security stance**,track metrics like vulnerability detection rate, mean time to remediate, policy compliance, security test coverage, and security-related build failures.
* **Organizations are responsible for securing code, access, and sensitive data** within the CI/CD stack, not cloud providers.

CI/CD pipelines are the backbone of software delivery, helping teams deploy code quickly and reliably. But with that speed and efficiency comes serious security risks. If you have compromised pipelines, attackers can inject malicious code, steal sensitive data, or even access production systems.

As companies ramp up their digital transformation efforts, securing CI/CD pipelines has gone from a nice-to-have to an absolute must when it comes to protecting the entire software development process. Now, CI/CD security is more critical than ever. For instance, Wiz's State of Code Security Report 2025 found that 35% of enterprises rely on self-hosted runners with weaker configurations, which expose them to lateral movement attacks. Because of this, prioritizing CI/CD security is urgent, not optional.

That's why you're here: to learn more about how you can secure your own CI/CD pipeline and best practices for CI/CD security—all without slowing down your teams' workflows or innovation.

## CI/CD security: A refresher

CI/CD pipelines not only streamline software deployment but also create multiple security vulnerabilities throughout the development lifecycle. Since these pipelines have direct access to source code, production environments, and sensitive credentials, they've become high-value targets for attackers.

A single compromised component can allow for the distribution of malicious code to all your users, which leads to data breaches, service disruptions, or compliance violations. As such, it's important to understand the greatest security risks in CI/CD infrastructure so you can put the right protections in place.

### Components at risk

In a CI/CD pipeline, these components are susceptible to attacks:

* **Source code repositories:** These are where developers store and manage code.
* **Build servers and workers:** Teams compile code into executable artifacts using these.
* **Artifact repositories:** Teams store build artifacts for deployment in these.
* **Deployment environments:** These are where the application deploys and runs.
* **CI runners (like GitHub-hosted runners):** These components are often over-privileged and under-monitored.
* **Orchestration tools (like ArgoCD or Spinnaker):** Attackers can exploit these for lateral movement.

Each of these components requires specific security measures to prevent unauthorized access and tampering.

### Challenges in CI/CD security

Securing CI/CD pipelines comes with the following challenges:

* **Complexity:** CI/CD pipelines' diverse, interconnected components make securing them complex.
* **Speed:** The fast pace of CI/CD can sometimes outpace security measures, leaving room for vulnerabilities.
* **Automation:** While automation is one of CI/CD's strengths, it can also be a weakness without automated security checks.
* **Access control:** Granting access to different pipeline components can be tricky, especially when you're dealing with large teams.
* **Secrets sprawl:** CI/CD solutions often hold many secrets—and when access controls aren't up to par, these secrets can easily leak.
* **Supply chain security:** Leveraging SaaS CI/CD tools like GitLab and CircleCI can introduce supply chain security concerns.
* **Unvetted third-party actions and plug-ins**: Reusable CI/CD workflows can introduce trojans.

## Best practices and recommendations for CI/CD security

Securing CI/CD pipelines requires embedding security throughout the development lifecycle, from scanning code and managing secrets to locking down infrastructure and access.

The following best practices help teams protect their pipelines without slowing velocity:

### Automating security scans

Automated security scans are a must for real-time vulnerability detection—especially due to the rise of DevSecOps, which brings security into the development process. These scans make it easier to run continuous security checks, catch vulnerabilities right away, and notify developers quickly, reducing the chances of releasing compromised code.

As such, you should integrate security tools like SonarQube or Checkmarx into your CI/CD pipeline to perform static and dynamic analysis on application code. These tools can identify vulnerabilities like SQL injection, cross-site scripting, and insecure object references.

```
# Example of SonarQube integration in a Jenkins pipeline
pipeline {
    agent any
    stages {
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube Scanner';
                    withSonarQubeEnv('My SonarQube Server') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }
}
```

Once you've selected the appropriate scanning tools, set up automatic triggers in your pipeline. You should configure your CI/CD system to initiate security scans immediately after each code commit—webhook integrations or SCM polling achieve this in real time.

**Pro tip:** Set up your security tools to deliver vulnerability alerts directly to your development team through communication channels like Slack, Microsoft Teams, or email.

### Focusing on runtime

You can also extend your security approach beyond static scanning using runtime monitoring and incident response tools. Here are a few examples:

* **SIEM/SOAR tools:** Connect your CI/CD pipeline logs and events to security information and event management (SIEM) or security orchestration, automation, and response (SOAR) platforms like Splunk or IBM QRadar to detect suspicious activities and trigger automated responses.
* **Anomaly detection:** Deploy machine learning–based anomaly detection systems that establish baseline behavior for your CI/CD operations and alert security teams when unusual patterns emerge, such as off-hours commits, unusual pipeline configurations, or atypical resource utilization.
* **Incident response playbooks:** Create detailed CI/CD-specific incident response playbooks that outline exact steps for security teams to take when potential breaches occur. You should include procedures for isolating compromised components, rolling back suspicious deployments, and conducting forensic analysis.
* **Automated containment measures:** Configure your pipeline to automatically quarantine suspicious builds and trigger additional security checks when your system detects anomalous behavior. That way, you can prevent potentially compromised code from reaching production.

**Pro tip:** Integrate dynamic application security testing (DAST) into your pipeline to automatically scan running applications for runtime vulnerabilities that static analysis might miss before code reaches production.

### Managing secrets effectively

Organizations that use CI/CD pipelines must implement effective secrets management for API keys, credentials, and configuration secrets to guard your organization's sensitive data against unauthorized access.

Implementing good secrets management solutions also prevents leaked credentials from causing breaches. Secrets management tools like HashiCorp Vault or AWS Secrets Manager provide features like dynamic secrets, secret revocation, and detailed audit logs that enhance your organization's security posture by protecting sensitive data. Additionally, pre-commit hooks and secret scanning tools enforce coding standards and prevent hardcoding of secrets in your codebase.

**Pro tip:** Regularly rotate secrets and keys using automated rotation policies with APIs from secrets management tools. This reduces the window of opportunity for malicious actors.

### Implementing immutable infrastructure

Be sure to structure your code repositories with clear security boundaries, implement rigorous validation pipelines that scan for vulnerabilities, and secure your state files and sensitive variables. Regular drift detection helps you identify unauthorized changes, while GitOps practices ensure that all infrastructure modifications undergo proper security reviews and maintain complete audit trails. These practices collectively change infrastructure management into a secure, repeatable process that reduces human error and strengthens your security posture.

To accomplish this, try containerization tools like Docker and orchestration platforms like Kubernetes to achieve uniform, unchangeable deployments across different environments. Infrastructure as code (IaC) tools like Terraform or AWS CloudFormation also ensure consistent, secure infrastructure deployments.

**Pro tip:** Design rollback strategies that recreate entire environments from IaC definitions to return systems to a known, secure state when issues arise.

### Establishing RBAC

A comprehensive role-based access control (RBAC) approach begins with clearly defining organizational roles and carefully scoping permissions to follow least privilege principles. Organizations that implement effective RBAC typically create tiered permission structures in platforms like Jenkins and secure automation service accounts through regular credential rotation and IP restrictions. Many successful security implementations also include separating approval and deployment authorities so no one person can control the entire code release process.

Additionally, multiple security layers often incorporate the four-eyed principle for critical operations, where independent approvals are necessary for sensitive actions. Well-secured CI/CD environments also feature automation accounts with strict privilege boundaries and centralized audit logging systems that monitor for unusual activities. This layered security architecture addresses potential insider threats while maintaining the development team's workflow efficiency.

**Pro tip:** Use scheduled access reviews to confirm appropriate permission assignments, as well as automated dormant account detection, manager certifications for access requirements, and streamlined workflows for rapid access adjustments during role changes. These layered defenses protect CI/CD infrastructure while preserving development velocity and operational effectiveness.

### Educating and training teams

Instead of treating security as a separate function, make developers an integral part of your security team. Security works best when you involve developers early and often in the security process rather than treating security as merely a final step.

To accomplish this, invest in security training that empowers development and operations teams to identify risks as they build. Creating security champions within development teams will also help you establish a culture where security is everyone's responsibility rather than just the security team's domain.

In addition to automated scanning, conduct regular security assessments and penetration tests with your development teams present. This collaborative approach identifies potential vulnerabilities in your pipelines and serves as a practical learning opportunity that ultimately strengthens developers' security awareness.

**Pro tip:** Create clear security guidelines and documentation that teams can easily reference when building and maintaining CI/CD pipelines or implementing inline feedback in pull requests.

## The different types of CI/CD pipelines

Each CI/CD pipeline brings its own security challenges as they grow alongside development workflows. But if your security teams know how different pipeline setups work, they can better customize their defenses and apply best practices more effectively.

Here are five different types to be aware of:

### 1. Traditional CI/CD pipelines

These pipelines use a sequence of automated steps to build, test, and deploy applications. They're often present in tools like Jenkins or Atlassian Bamboo.

Key security concerns include:

* **Controlling access** to pipeline triggers and secrets
* **Securing the build environment** from tampering or unauthorized changes
* **Ensuring the integrity of artifacts** as they move through the pipeline (such as through checksums or digital signing)

### 2. GitOps pipelines

GitOps pipelines use Git repositories as their go-to source for managing application and infrastructure setups, usually in a declarative way with tools like ArgoCD or Flux. These come with some great security perks, like version-controlled changes and clear audit trails.

However, there are risks if the following are true:

* Teams store secrets or credentials directly in Git (like in plain YAML files).
* Access controls on repositories and GitOps agents are too permissive.

Compromised GitOps agents can allow attackers to deploy malicious infrastructure directly into production. However, using tools like Sealed Secrets, HashiCorp Vault, or SOPS can help you manage your sensitive data more securely.

### 3. Container-based pipelines

These pipelines use containerization tools like Docker and Kubernetes to keep builds and deployments consistent across different environments.

Key security focus areas include the following:

* **Scanning container images** for vulnerabilities
* **Hardening container registries** and enforcing least privilege access
* **Monitoring for runtime threats** in deployed containers

### 4. Serverless pipelines

Serverless CI/CD pipelines rely on fully managed services like GitHub Actions, AWS CodeBuild, or Google Cloud Build to handle workflows without the hassle of managing infrastructure. They're scalable, cut down on operational overhead, and make life easier.

However, they also come with these security considerations:

* **Managing**fine-grained IAM policies
* **Understanding** the shared responsibility model
* **Preventing** privilege escalation within workflows and across accounts

Execution environments don't last forever, though—so having strong logging and monitoring in place is important for keeping everything visible.

### 5. Hybrid pipelines

Many organizations mix different approaches, like using GitOps for infrastructure, containers for applications, and serverless tools for orchestration. The result is a complicated security ecosystem that stretches across clouds, platforms, and pipelines.

Because of this, security teams with hybrid pipelines need to do the following:

* **Maintain visibility** across toolchains
* **Apply consistent policies** for secrets management, access, and compliance
* **Standardize how to identify and remediate** **risks** across environments

Security policies must span code, containers, infrastructure, and cloud to maintain their effectiveness.

## The stages of CI/CD pipelines

CI/CD pipelines have four connected stages, each with its own security needs. Here's a breakdown of what each involves:

**Source stage:**

* Developers write code in various programming environments.
* Security focuses on repository access controls.
* Static code analysis identifies basic vulnerabilities early.
* Branch protection rules prevent unauthorized modifications.

**Build stage:**

* Source code combines with dependencies and libraries.
* Teams create executable files and artifacts.
* Teams verify dependencies and validate scripts.
* Third-party components require special scrutiny to prevent supply chain attacks.

**Test stage:**

* Builds undergo thorough dynamic testing.
* Specialized security checks detect vulnerabilities that static analysis might miss.
* Interactive application security testing simulates real-world attacks.
* Testing environments mirror production configurations.

**Deploy stage:**

* Teams prepare validated builds for production release.
* Tight environment security controls protect production assets.
* Access controls limit deployment capabilities.
* Configuration validation ensures secure release parameters.
* Post-deployment monitoring identifies potential security issues.

The takeaway here is that by embedding security into every stage, organizations can keep development moving smoothly while minimizing the risk of breaches.

## CI/CD security: What are your responsibilities?

The shared responsibility model breaks down who's in charge of what at different stages of the pipeline—either the cloud service provider or the customer organization.

While providers maintain physical infrastructure security, ensure platform availability, and manage core security updates, it's your organization that bears responsibility for overall security posture. For instance, you're responsible for configuring secure pipelines, managing code and dependency security, implementing proper access controls, and protecting sensitive data across all environments.

Building on the CI/CD stages above, here are specific security responsibilities within the shared responsibility model at each pipeline phase:

* **Source stage responsibilities:**

  + Enforce secure coding practices across development teams.
  + Implement robust repository protections including branch policies.
  + Establish mandatory code review processes with security checkpoints.
  + Maintain secure access controls for source code repositories.
* **Build stage responsibilities:**

  + Secure build environments from unauthorized access.
  + Scan dependencies and third-party components for vulnerabilities.
  + Protect build artifacts from tampering or unauthorized modification.
  + Validate build scripts and automation tools for security issues.
* **Test stage responsibilities:**

  + Integrate comprehensive security testing tools into test workflows.
  + Ensure appropriate coverage of potential vulnerability classes.
  + Address identified security issues before allowing code progression.
  + Document security test results for compliance and audit purposes.
* **Deploy stage responsibilities:**

  + Validate security configurations before production deployment.
  + Implement secure deployment practices, including approval gates.
  + Control environment access with granular permission boundaries.
  + Monitor deployed applications for security anomalies.

During ongoing operations, you should also maintain in-depth logging, monitor for security anomalies, and establish clear incident response procedures to address emerging threats. This layered approach to responsibility enforces comprehensive security throughout the entire development lifecycle.

## What are the components of CI/CD security?

A comprehensive CI/CD security strategy incorporates the following components:

* **Static application security testing (SAST)** analyzes source code to identify security vulnerabilities like SQL injection, cross-site scripting, and insecure coding patterns before compilation. By integrating SAST into early development stages, organizations can detect and address issues before they reach production.
* **Software composition analysis (SCA)** scans dependencies for known vulnerabilities and license compliance issues. SCA tools also provide visibility into the third-party libraries and software project components, which allows organizations to manage their open source usage securely.
* **DAST** detects runtime vulnerabilities in running applications that static analysis might miss. It can also identify issues like authentication problems, session management flaws, and server configuration errors.
* **IaC scanning** evaluates infrastructure definitions for misconfigurations and security issues. By scanning Terraform, CloudFormation, and other IaC files, businesses can prevent insecure deployments before implementation.
* **Container security scanning** examines container images for vulnerabilities, malware, and misconfigurations. This prevents compromised containers from deploying in production environments.
* **Secrets management** involves securely storing, accessing, and rotating sensitive credentials throughout the pipeline. Good secrets management keeps your API keys, passwords, and other sensitive information safe from exposure.

## How to gauge the strength of your CI/CD security

To effectively measure and improve your CI/CD security posture, focus on these key performance indicators (KPIs):

* **Vulnerability detection rate:** This KPI measures how effectively your security tools identify issues compared to total vulnerabilities present. You can implement this metric by using periodic penetration testing to establish a baseline and comparing vulnerabilities you've discovered against those you've detected automatically. Then, compare detection rates between different tools to identify blind spots in your security scanning approach.
* **Mean time to remediate (MTTR):** This metric indicates how quickly teams resolve security issues after detection. You can implement MTTR tracking by tagging security-related issues in your ticket management system and configuring automated timestamp tracking at each stage. Breaking this KPI down by severity levels also allows you to prioritize critical vulnerabilities while maintaining overall security health.
* **Pipeline security policy compliance:** This metric shows the percentage of pipelines that adhere to security standards across your organization. You can implement it by defining clear security policies in machine-readable formats and integrating compliance checking into your CI/CD systems. Creating dashboards that visualize compliance trends over time will also highlight specific policy violations that require immediate attention.
* **Security test coverage:** This KPI measures how thoroughly your security testing examines your codebase and infrastructure components. To implement coverage tracking, configure your testing tools to generate coverage reports and aggregate these metrics across different testing types. You can also map coverage against your application's threat model to identify high-risk areas that require additional testing.
* **Failed build rate due to security issues:** This metric tracks how often security checks prevent builds from completing, which indicates both security enforcement and developer awareness. It involves categorizing build failures in your CI/CD system and tracking security-related failures separately from functional issues. You can monitor this rate alongside deployment velocity to ensure that security improvements aren't slowing delivery.

## Wiz's approach to CI/CD security

Measuring and improving your CI/CD security posture can feel like shooting in the dark at times. The 2026 Application Security Report validated a lifecycle approach that protects everything from your initial commit to your live environment.

Wiz Code brings award-winning application security directly into the context of your runtime cloud environment. By correlating IaC misconfigurations, code-level vulnerabilities, and cloud risk signals, Wiz empowers teams to prioritize what's actually exploitable, not just what's present.

Struggling with complex CI/CD security challenges? You can leverage Wiz Code to strengthen your security posture while maintaining development velocity, too. Here's how:

* **Simplified security integration:** For teams that are overwhelmed by multiple security tools, Wiz provides a unified security solution that integrates natively with popular CI/CD platforms like Jenkins, GitLab, and CircleCI without disrupting existing workflows.
* **Early vulnerability detection:** Wiz's shift-left approach allows teams to catch security issues before production deployment. They also gain immediate feedback on security risks in code, infrastructure definitions, and dependencies during development stages.
* **Comprehensive protection:** Security teams that need complete visibility across their pipeline can use Wiz's integrated security capabilities, from application code to cloud infrastructure, to create a consistent security approach throughout the entire application lifecycle.

Tools like Wiz's Security Graph also provide comprehensive visibility into your CI/CD security posture with a visual representation of vulnerabilities, their relationships, and potential attack paths. That way, security teams can prioritize remediation efforts based on actual risk instead of generic severity ratings.

By addressing these critical security needs while maintaining development speed, Wiz helps organizations build secure CI/CD pipelines that support their business objectives rather than impeding progress.
