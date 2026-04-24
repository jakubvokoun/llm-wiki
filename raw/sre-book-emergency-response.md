# Chapter 13 — Emergency Response

Written by Corey Adam Baye  
Edited by Diane Bates

Things break; that's life.

Regardless of the stakes involved or the size of an organization, one trait that's vital to the long-term health of an organization, and that consequently sets that organization apart from others, is how the people involved respond to an emergency. Few of us naturally respond well during an emergency. A proper response takes preparation and periodic, pertinent, hands-on training.

This chapter provides concrete examples of emergency incidents and the lessons learned from them.

## What to Do When Systems Break

First of all, don't panic! You aren't alone, and the sky isn't falling. You're a professional and trained to handle this sort of situation. Typically, no one is in physical danger—only those poor electrons are in peril.

If you feel overwhelmed, pull in more people. Sometimes it may even be necessary to page the entire company. If your company has an incident response process, make sure that you're familiar with it and follow that process.

## Case Study 1: Test-Induced Emergency

Google has adopted a proactive approach to disaster and emergency testing. SREs break our systems, watch how they fail, and make changes to improve reliability and prevent the failures from recurring. However, sometimes assumptions and actual results are worlds apart.

### Details

The goal was to flush out hidden dependencies on a test database within one of their larger distributed MySQL databases. The plan was to block all access to just one database out of a hundred. No one foresaw the results that would unfold.

### Response

Within minutes of commencing the test, numerous dependent services reported that both external and internal users were unable to access key systems. Some systems were intermittently or only partially accessible.

Assuming that the test was responsible, SRE immediately aborted the exercise. Attempted rollback of the permissions change was unsuccessful. Instead of panicking, they immediately brainstormed how to restore proper access. Using an already tested approach, they restored permissions to the replicas and failovers. In a parallel effort, they reached out to key developers to correct the flaw in the database application layer library.

Within an hour, all access was fully restored.

### Findings

**What went well:**
- Dependent services immediately escalated the issues
- Correctly assumed the controlled experiment had gotten out of hand and immediately aborted
- Parallel efforts to restore service helped speed recovery
- Follow-up action items were resolved quickly and thoroughly

**What we learned:**
- Insufficient understanding of dependent system interactions, despite thorough review
- Failed to follow the incident response process (put in place only a few weeks before, not yet disseminated)
- Rollback procedures hadn't been tested in a test environment; they were flawed, lengthening the outage

**Key takeaways:**
- Require thorough testing of rollback procedures before large-scale tests
- Ensure incident management procedures are clearly communicated to all relevant parties
- Continually refine and test incident response tools and processes

## Case Study 2: Change-Induced Emergency

A configuration change to the infrastructure protecting services from abuse was pushed globally on a Friday. This infrastructure interacts with essentially all externally facing systems. The change triggered a crash-loop bug, causing the entire fleet to begin crash-looping almost simultaneously. Because Google's internal infrastructure also depends upon its own services, many internal applications suddenly became unavailable.

### Response

Within seconds, monitoring alerts started firing. Some on-call engineers simultaneously experienced what they believed to be a failure of the corporate network and relocated to dedicated secure rooms (panic rooms) with backup access to the production environment.

Within five minutes of the first configuration push, the engineer responsible for the push—aware of the corporate outage but not the broader outage—pushed another configuration change to roll back the first. Services began to recover.

Within 10 minutes, on-call engineers declared an incident and proceeded to follow internal procedures for incident response, notifying the rest of the company. Some services experienced unrelated bugs or misconfigurations triggered by the original event and didn't fully recover for up to an hour.

### Findings

**What went well:**
- Monitoring almost immediately detected and alerted on the problem
- Incident management generally went well; updates were communicated often and clearly
- Out-of-band communications systems kept everyone connected
- Command-line tools and alternative access methods enabled updates and rollback even when other interfaces were inaccessible
- The affected system rate-limited how quickly it provided full updates to new clients, possibly throttling the crash-loop

**What we learned:**
- An earlier canary push didn't trigger the bug because it didn't exercise a specific configuration keyword combination with the new feature
- The change wasn't considered risky, so it followed a less stringent canary process—but the untested keyword/feature combination triggered failure
- Alerting was too noisy during the incident: alerts fired repeatedly, overwhelming on-calls and spamming communication channels
- Much of the software stack used for troubleshooting lay behind crash-looping jobs; longer outage would have severely hindered debugging
- The swift rollback was partly luck: the push engineer happened to be monitoring real-time communication channels, which is not a normal part of the release process

**Key takeaway**: Thorough canarying is essential regardless of perceived risk. The push engineer's diligence in monitoring channels was the critical factor in rapid resolution—and cannot be relied upon as a process.

## Case Study 3: Process-Induced Emergency (The Diskerase Incident)

As part of routine automation testing, two consecutive turndown requests for the same soon-to-be-decommissioned server installation were submitted. A subtle bug in the automation sent all machines in all installations globally to the Diskerase queue, where their hard drives were destined to be wiped.

### Response

On-call engineers received a page as the first small server installation was taken offline. Investigation determined that the machines had been transferred to the Diskerase queue. Following normal procedure, engineers drained traffic from the location.

Before long, pagers everywhere were firing for all such server installations around the world. On-call engineers disabled all team automation to prevent further damage. Within an hour, all traffic had been diverted to other locations. Users may have experienced elevated latencies, but their requests were fulfilled.

Recovery was the hard part. Some network links were reporting heavy congestion. A manual reinstall process was devised, dividing the team into three parts, each responsible for one step. Within three days, the vast majority of capacity was back online, with stragglers recovered over the next month or two.

### Findings

**What went well:**
- Large installations (managed differently) were not impacted; traffic was quickly moved from small to large installations
- Turndown process worked efficiently—less than an hour to successfully turn down and securely wipe installations
- On-call engineers promptly reverted monitoring changes to help assess damage extent
- Communication and collaboration were superb; incident management program and training proved effective

**What we learned:**
- **Root cause**: The turndown automation server lacked appropriate sanity checks. When it ran again in response to the initial failed turndown, it received an empty response for the machine rack. Instead of filtering the response, it passed the empty filter to the machine database, telling it to Diskerase all machines. "Sometimes zero does mean all."
- Reinstallations of machines were slow and unreliable due to TFTP at the lowest network QoS from distant locations
- The machine reinstallation infrastructure was unable to handle simultaneous setup of thousands of machines
- **Fix**: Reclassify installation traffic at slightly higher priority; use automation to restart stuck machines; fix the tuning parameters

## Lessons: Learn from the Past. Don't Repeat It.

### Keep a History of Outages

There is no better way to learn than to document what has broken in the past. Be thorough, be honest, but most of all, ask hard questions. Look for specific actions that might prevent such an outage from recurring, not just tactically, but also strategically. Ensure that everyone within the company can learn what you have learned by publishing and organizing postmortems.

Hold yourself and others accountable to following up on the specific actions detailed in these postmortems.

### Ask the Big, Even Improbable, Questions: What If…?

What if the building power fails? What if the primary datacenter suddenly goes dark? What if someone compromises your web server? What do you do? Who do you call? Do you have a plan? Do you know how to react? Do you know how your systems will react?

### Encourage Proactive Testing

When it comes to failures, theory and reality are two very different realms. Until your system has actually failed, you don't truly know how that system, its dependent systems, or your users will react. Don't rely on assumptions or what you can't or haven't tested.

## Common Themes Across All Three Emergencies

1. **Don't panic**: The responders didn't panic
2. **Pull in more people when needed**: All three cases involved escalating to more people
3. **Follow incident response processes**: All three cases showed the value of having documented and practiced processes
4. **Learn and document**: Each emergency led to thorough documentation and follow-up
5. **Proactive testing**: Each outage or test resulted in incremental improvements to both processes and systems
6. **Out-of-band communications**: Reliable backup communication systems are essential
7. **Test rollback procedures**: Don't assume rollback works—test it explicitly

While these case studies are specific to Google, this approach to emergency response can be applied over time to any organization of any size.
