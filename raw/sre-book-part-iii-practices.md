# Part III — Practices

Put simply, SREs run services—a set of related systems, operated for users, who may be internal or external—and are ultimately responsible for the health of these services. Successfully operating a service entails a wide range of activities: developing monitoring systems, planning capacity, responding to incidents, ensuring the root causes of outages are addressed, and so on. This section addresses the theory and practice of an SRE's day-to-day activity: building and operating large distributed computing systems.

We can characterize the health of a service—in much the same way that Abraham Maslow categorized human needs—from the most basic requirements needed for a system to function as a service at all to the higher levels of function—permitting self-actualization and taking active control of the direction of the service rather than reactively fighting fires. This understanding is so fundamental to how we evaluate services at Google that it wasn't explicitly developed until a number of Google SREs, including Mikey Dickerson, temporarily joined the radically different culture of the United States government to help with the launch of healthcare.gov in late 2013 and early 2014: they needed a way to explain how to increase systems' reliability.

## Service Reliability Hierarchy

### Monitoring

Without monitoring, you have no way to tell whether the service is even working; absent a thoughtfully designed monitoring infrastructure, you're flying blind. Maybe everyone who tries to use the website gets an error, maybe not—but you want to be aware of problems before your users notice them.

### Incident Response

SREs don't go on-call merely for the sake of it: rather, on-call support is a tool we use to achieve our larger mission and remain in touch with how distributed computing systems actually work (and fail!). If we could find a way to relieve ourselves of carrying a pager, we would.

Once you're aware that there is a problem, how do you make it go away? That doesn't necessarily mean fixing it once and for all—maybe you can stop the bleeding by reducing the system's precision or turning off some features temporarily, allowing it to gracefully degrade, or maybe you can direct traffic to another instance of the service that's working properly. The details of the solution you choose to implement are necessarily specific to your service and your organization. Responding effectively to incidents, however, is something applicable to all teams.

Figuring out what's wrong is the first step; a structured approach to effective troubleshooting is foundational. During an incident, it's often tempting to give in to adrenalin and start responding ad hoc. Managing incidents effectively should reduce their impact and limit outage-induced anxiety.

### Postmortem and Root-Cause Analysis

We aim to be alerted on and manually solve only new and exciting problems presented by our service; it's woefully boring to "fix" the same issue over and over. In fact, this mindset is one of the key differentiators between the SRE philosophy and some more traditional operations-focused environments.

Building a blameless postmortem culture is the first step in understanding what went wrong (and what went right!). An outage tracker allows SRE teams to keep track of recent production incidents, their causes, and actions taken in response to them.

### Testing

Once we understand what tends to go wrong, our next step is attempting to prevent it, because an ounce of prevention is worth a pound of cure. Test suites offer some assurance that our software isn't making certain classes of errors before it's released to production.

### Capacity Planning

Capacity planning is vital, and you don't actually need a crystal ball to do it right. Naturally following capacity planning, load balancing ensures we're properly using the capacity we've built. Handling overload and addressing cascading failures are both essential for ensuring service reliability.

### Development

One of the key aspects of Google's approach to Site Reliability Engineering is that we do significant large-scale system design and software engineering work within the organization. Distributed consensus (Paxos), distributed cron, data processing pipelines, and data integrity are all key areas of SRE development work.

### Product

Finally, having made our way up the reliability pyramid, we find ourselves at the point of having a workable product. Reliable product launches at scale try to give users the best possible experience starting from Day Zero.

## Key Themes

- The hierarchy mirrors Maslow's hierarchy of needs: from basic (monitoring) to advanced (product reliability)
- Each layer depends on the layers below it being solid
- SREs must be proactive, not just reactive
- Blameless culture and learning from failure are foundational
- Capacity planning and load management are as important as incident response
- Testing resilience proactively (chaos engineering mindset) is essential
