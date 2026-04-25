# Software Engineering in SRE

Written by Dave Helstroom and Trisha Weir with Evan Leonard and Kurt Delimon
Edited by Kavita Guliani

Ask someone to name a Google software engineering effort and they'll likely list a consumer-facing product like Gmail or Maps; some might even mention underlying infrastructure such as Bigtable or Colossus. But in truth, there is a massive amount of behind-the-scenes software engineering that consumers never see. A number of those products are developed within SRE.

Google's production environment is—by some measures—one of the most complex machines humanity has ever built. SREs have firsthand experience with the intricacies of production, making them uniquely well suited to develop the appropriate tools to solve internal problems and use cases related to keeping production running. The majority of these tools are related to the overall directive of maintaining uptime and keeping latency low, but take many forms: examples include binary rollout mechanisms, monitoring, or a development environment built on dynamic server composition. Overall, these SRE-developed tools are full-fledged software engineering projects, distinct from one-off solutions and quick hacks, and the SREs who develop them have adopted a product-based mindset that takes both internal customers and a roadmap for future plans into account.

## Why Is Software Engineering Within SRE Important?

In many ways, the vast scale of Google production has necessitated internal software development, because few third-party tools are designed at sufficient scale for Google's needs.

SREs are in a unique position to effectively develop internal software for a number of reasons:

* The breadth and depth of Google-specific production knowledge within the SRE organization allows its engineers to design and create software with the appropriate considerations for dimensions such as scalability, graceful degradation during failure, and the ability to easily interface with other infrastructure or tools.
* Because SREs are embedded in the subject matter, they easily understand the needs and requirements of the tool being developed.
* A direct relationship with the intended user—fellow SREs—results in frank and high-signal user feedback. Releasing a tool to an internal audience with high familiarity with the problem space means that a development team can launch and iterate more quickly.

From a purely pragmatic standpoint, Google clearly benefits from having engineers with SRE experience developing software. By deliberate design, the growth rate of SRE-supported services exceeds the growth rate of the SRE organization; one of SRE's guiding principles is that "team size should not scale directly with service growth." Achieving linear team growth in the face of exponential service growth requires perpetual automation work and efforts to streamline tools, processes, and other aspects of a service that introduce inefficiency into the day-to-day operation of production.

Fully fledged software development projects within SRE provide career development opportunities for SREs, as well as an outlet for engineers who don't want their coding skills to get rusty. Long-term project work provides much-needed balance to interrupts and on-call work, and can provide job satisfaction for engineers who want their careers to maintain a balance between software engineering and systems engineering.

Beyond the design of automation tools and other efforts to reduce the workload for engineers in SRE, software development projects can further benefit the SRE organization by attracting and helping to retain engineers with a broad variety of skills. To this end, Google always strives to staff its SRE teams with a mix of engineers with traditional software development experience and engineers with systems engineering experience.

## Auxon Case Study: Project Background and Problem Space

This case study examines Auxon, a powerful tool developed within SRE to automate capacity planning for services running in Google production.

### Traditional Capacity Planning

There are myriad tactics for capacity planning of compute resources, but the majority of these approaches boil down to a *cycle* that can be approximated as follows:

1. Collect demand forecasts — how many resources are needed, when and where?
2. Devise build and allocation plans — given this forecasted outlook, what's the best way to meet this demand?
3. Review and sign off on plan.
4. Deploy and configure resources.

Capacity planning is a neverending *cycle*: assumptions change, deployments slip, and budgets are cut, resulting in revision upon revision of The Plan.

**Brittle by nature:** Traditional capacity planning produces a resource allocation plan that can be disrupted by any seemingly minor change (efficiency decreases, adoption rate increases, delivery slippage, product decision changes). Minor changes require cross-checking the entire allocation plan; larger changes potentially require re-creating the plan from scratch.

**Laborious and imprecise:** The process of collecting the data necessary to generate demand forecasts is slow and error-prone. Mapping constrained resource requests into allocations of actual resources from available capacity is equally slow. Bin packing is an NP-hard problem that is difficult for human beings to compute by hand. The net result is a massive expenditure of human effort to come up with a bin packing that is approximate, at best.

## Our Solution: Intent-Based Capacity Planning

*Specify the requirements, not the implementation.*

At Google, many teams have moved to an approach called *Intent-based Capacity Planning*. The basic premise is to programmatically encode the dependencies and parameters (*intent*) of a service's needs, and use that encoding to autogenerate an allocation plan. If demand, supply, or service requirements change, we can simply autogenerate a new plan in response to the changed parameters.

With a service's true requirements and flexibility captured, the capacity plan is now dramatically more nimble in the face of change, and we can reach an optimal solution that meets as many parameters as possible. With bin packing delegated to computers, human toil is drastically reduced.

## Intent-Based Capacity Planning

*Intent* is the rationale for how a service owner wants to run their service. Moving from concrete resource demands to motivating reasons in order to arrive at the true capacity planning intent often requires several layers of abstraction:

1. "I want 50 cores in clusters X, Y, and Z for service Foo." — explicit resource request
2. "I want a 50-core footprint in any 3 clusters in geographic region YYY." — introduces more degrees of freedom
3. "I want to meet service Foo's demand in each geographic region, and have N + 2 redundancy." — greater flexibility, understandable rationale
4. "I want to run service Foo at 5 nines of reliability." — most abstract, maximum flexibility

In Google's experience, services tend to achieve the best wins as they cross to step 3: good degrees of flexibility are available, and the ramifications of this request are in higher-level and understandable terms.

### Precursors to Intent

**Dependencies:** Services at Google depend on many other infrastructure and user-facing services, and these dependencies heavily influence where a service can be placed. Production dependencies are nested: to serve Foo, you need Bar which needs Baz and Qux.

**Performance metrics:** Demand for one service trickles down to result in demand for one or more other services. Performance metrics are the glue between dependencies. They convert from one or more higher-level resource type(s) to one or more lower-level resource type(s).

**Prioritization:** Inevitably, resource constraints result in trade-offs. Intent-driven planning forces these decisions to be made transparently, openly, and consistently.

## Introduction to Auxon

Auxon is Google's implementation of an intent-based capacity planning and resource allocation solution, built by a small group of software engineers and a technical program manager within SRE over the course of two years. Auxon is actively used to plan the use of many millions of dollars of machine resources at Google.

As a product, Auxon provides the means to collect intent-based descriptions of a service's resource requirements and dependencies. Requirements might be specified as a request like, "My service must be N + 2 per continent" or "The frontend servers must be no more than 50 ms away from the backend servers." These requirements—the intent—are ultimately represented internally as a giant mixed-integer or linear program.

Major components of Auxon:

* **Performance Data** — describes how a service scales
* **Per-Service Demand Forecast Data** — describes usage trend for forecasted demand signals
* **Resource Supply** — data about the availability of base-level resources
* **Resource Pricing** — data about cost of base-level resources
* **Intent Config** — key configuration layer that defines services and how they relate
* **Configuration Language Engine** — formulates machine-readable optimization request from Intent Config
* **Auxon Solver** — the brain; formulates the giant mixed-integer or linear program, designed to run in parallel upon hundreds or thousands of machines
* **Allocation Plan** — the output; prescribes which resources should be allocated to which services

### Requirements and Implementation: Successes and Lessons Learned

Throughout Auxon's development, the SRE team behind the product continued to be deeply involved in the production world. They maintained a role in on-call rotations for several of Google's services. When the product failed, the team was directly impacted. Feature requests were informed through the team's own firsthand experiences.

**Approximation:** Don't focus on perfection and purity of solution, especially if the bounds of the problem aren't well known. Launch and iterate. The team built a simplified "Stupid Solver" that applied simple heuristics as to how services should be arranged—it would never yield a truly optimal solution, but it gave the team confidence that their vision was achievable. Eventually, as confidence in a unified linear programming model grew, it was a simple operation to switch out the Stupid Solver for something smarter.

**Agnosticism:** Writing the software to be generalized to allow myriad data sources as input. Customers weren't required to commit to any one tool in order to use the Auxon framework. This approach allowed Auxon to remain of sufficient general utility even as teams with divergent use cases began to use it.

### Raising Awareness and Driving Adoption

Don't underestimate the effort required to raise awareness and interest in your software product—a single presentation or email announcement isn't enough. Socializing internal software tools demands:

* A consistent and coherent approach
* User advocacy
* The sponsorship of senior engineers and management

**Set expectations:** Differentiate aspirational goals from minimum success criteria (Minimum Viable Product). Projects can lose credibility by promising too much, too soon. Demonstrating steady, incremental progress via small releases raises user confidence.

**Identify appropriate customers:** The initial versions of Auxon intentionally targeted teams that had no existing capacity planning processes in place. The early successes with these teams demonstrated the utility of the project, and turned the customers themselves into advocates.

**Customer service:** Provide white glove customer support for early adopters. Working one-on-one with early users can address fears about automation replacing jobs, demonstrating instead that the team owns the configurations, processes, and ultimate results.

## Team Dynamics

Creating a seed team that combines generalists with engineers possessing a breadth of knowledge and experience covers blind spots. During the initial phases, the team presented their design document to Google's in-house teams that specialize in Operations Research and Quantitative Analysis to bootstrap knowledge about capacity planning.

## Fostering Software Engineering in SRE

Strong positive signals for a project to become a fully fledged software engineering effort:

* Engineers with firsthand experience in the relative domain who are interested in working on the project
* A target user base that is highly technical
* The project provides noticeable benefits (reducing toil, improving infrastructure, streamlining complex processes)
* The project fits into the overall set of objectives for the organization

Poor candidate indicators:
* Software that touches many moving parts at once
* Software design that requires an all-or-nothing approach
* Overly specific work that only benefits a small percentage of the organization
* Overly generic frameworks that don't quite fit any use case

### Successfully Building a Software Engineering Culture in SRE

**Staffing:** SREs are often generalists. Partnering with engineers, TPMs, or PMs who are familiar with user-facing software development can help build a team software development culture that brings together the best of both worlds.

**Dedicated time:** Dedicated, noninterrupted project work time is essential to any software development effort. Such time must be aggressively defended.

Guidelines from Google's experience for introducing a software development model to SRE:

1. **Create and communicate a clear message** — Make a compelling case for how this strategy will help SRE (consistent solutions speed ramp-up for new SREs; reducing the number of ways to perform the same task makes knowledge portable).

2. **Evaluate your organization's capabilities** — Fill gaps by taking advantage of the skills already present in your company. Ask your product development team to help establish agile practices via training or coaching.

3. **Launch and iterate** — Establish credibility by delivering some product of value in a reasonable amount of time. Target relatively straightforward and achievable targets for first products. Pair with a six-month rhythm of product update releases.

4. **Don't lower your standards** — Hold yourself to the same standards to which your product development teams are held. Do you have proper code review practices? End-to-end or integration testing? Production readiness reviews?

## Conclusions

Software engineering projects within Google SRE have flourished as the organization has grown. The unique hands-on production experience that SREs bring to developing tools can lead to innovative approaches to age-old problems. SRE-driven software projects are also noticeably beneficial to the company in developing a sustainable model for supporting services at scale—because SREs often develop software to streamline inefficient processes or automate common tasks, these projects mean that the SRE team doesn't have to scale linearly with the size of the services they support.
